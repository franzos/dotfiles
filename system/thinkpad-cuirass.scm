(define-module (thinkpad-cuirass)
  #:use-module (common)
  #:use-module (proprietary)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (gnu services xorg)
  #:use-module (gnu services ssh)
  #:use-module (gnu services pm)
  #:use-module (gnu services linux)
  #:use-module (gnu services networking)
  #:use-module (gnu services desktop)
  #:use-module (gnu services cuirass)
  #:use-module (gnu services databases)
  #:use-module (gnu services mcron)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages databases)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu system linux-initrd)
  #:use-module (px services networking))

;; --- Thinkpad hardware definitions (duplicated; thinkpad.scm doesn't export) ---

(define %backlight-udev-rule
  (udev-rule "90-backlight.rules"
             (string-append
	      "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
	      "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/intel_backlight/brightness\""
	      "\n" "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
	      "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness\"")))

(define %franz-ssh-key
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7gcLZzs2JiEx2kWCc8lTHOC0Gqpgcudv0QVJ4QydPg franz")

(define %thinkpad-iptables-ipv4-rules
  (plain-file "iptables.rules" "*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i tailscale0 -j ACCEPT
-A INPUT -p udp --dport 41641 -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A INPUT -p tcp --dport 8081 -j ACCEPT
-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
"))

(define %thinkpad-iptables-ipv6-rules
  (plain-file "ip6tables.rules" "*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A INPUT -p tcp --dport 8081 -j ACCEPT
-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
"))

;; --- Build server configuration ---
;;
;; Workflow:
;; 1. Cuirass pulls channels and builds packages locally
;; 2. guix-publish generates signed narinfo + nar files in /var/cache/publish
;; 3. Cache warmup requests narinfos to trigger caching
;; 4. rsync pushes the cache to a remote static file server
;;
;; First-time setup: generate signing key with
;;   sudo guix archive --generate-key

(define %pantherx-spec
  #~(specification
     (name "pantherx-packages")
     (build '(channels pantherx))
     (channels
      (cons* (channel
              (name 'pantherx)
              (branch "master")
              (url "https://codeberg.org/gofranz/panther.git")
              (introduction
               (make-channel-introduction
                "54b4056ac571611892c743b65f4c47dc298c49da"
                (openpgp-fingerprint
                 "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
             %default-channels))))

(define %cuirass-specs
  #~(list #$%pantherx-spec
          #$%proprietary-spec))

;; Request narinfos from the local guix-publish to trigger cache generation.
;; Drives the warmup from Cuirass's latestbuilds API so the package set stays
;; in sync with whatever Cuirass actually builds.
(define %warmup-publish-cache
  (program-file "warmup-publish-cache"
    #~(begin
        (use-modules (web client)
                     (ice-9 regex)
                     (rnrs bytevectors))

        (define path-rx
          (make-regexp "\"path\":\"(/gnu/store/[^\"]+)\""))

        (define status-rx
          (make-regexp "\"buildstatus\":(-?[0-9]+)"))

        ;; Per object the store path appears before "buildstatus":N, so pair each
        ;; path with the first status after it and keep only succeeded (0) builds.
        (define (fetch-build-paths jobset)
          (call-with-values
              (lambda ()
                (http-get
                 (string-append
                  "http://localhost:8081/api/latestbuilds?nr=1000&jobset="
                  jobset)))
            (lambda (response body)
              (let ((text (if (bytevector? body) (utf8->string body) body)))
                (let loop ((start 0) (acc '()))
                  (let ((m (regexp-exec path-rx text start)))
                    (if m
                        (let ((s (regexp-exec status-rx text (match:end m))))
                          (loop (match:end m)
                                (if (and s (string=? (match:substring s 1) "0"))
                                    (cons (match:substring m 1) acc)
                                    acc)))
                        acc)))))))

        (define (warm-path path)
          (let* ((base (basename path))
                 (hash (substring base 0 (string-index base #\-))))
            (catch #t
              (lambda ()
                (http-get
                 (string-append "http://localhost:3000/" hash ".narinfo")))
              (lambda (key . args)
                (format (current-error-port)
                        "warmup: failed ~a.narinfo: ~a ~a~%"
                        hash key args)))))

        (for-each
         (lambda (jobset)
           (catch #t
             (lambda ()
               (for-each warm-path (fetch-build-paths jobset)))
             (lambda (key . args)
               (format (current-error-port)
                       "warmup: failed jobset ~a: ~a ~a~%"
                       jobset key args))))
         '("pantherx-packages" "proprietary-packages")))))

;; Build a static file layout from the guix-publish cache, then rsync to the
;; remote substitute server.
;;
;;   guix-publish cache: /var/cache/publish/zstd/<hash>-<name>.{narinfo,nar}
;;   clients expect:     /<hash>.narinfo  and  /nar/zstd/<hash>-<name>
(define %sync-substitutes
  (program-file "sync-substitutes"
    #~(begin
        (setenv "PATH"
                (string-append #$coreutils "/bin:"
                               #$rsync "/bin:"
                               #$openssh "/bin"))
        (execl #$(file-append bash "/bin/bash") "bash" "-c" "
set -euo pipefail

CACHE=/var/cache/publish/zstd
STATIC=/var/cache/publish/serve
REMOTE=virt1

if [ ! -d \"$CACHE\" ]; then
    echo \"Cache not found at $CACHE\"
    exit 1
fi

mkdir -p \"$STATIC/nar/zstd\"

if [ -f /etc/guix/signing-key.pub ]; then
    cp -u /etc/guix/signing-key.pub \"$STATIC/signing-key.pub\"
fi

if [ ! -f \"$STATIC/nix-cache-info\" ]; then
    cat > \"$STATIC/nix-cache-info\" <<EOF
StoreDir: /gnu/store
WantMassQuery: 1
Priority: 100
EOF
fi

for narinfo in \"$CACHE\"/*.narinfo; do
    [ -f \"$narinfo\" ] || continue
    name=$(basename \"$narinfo\" .narinfo)
    hash=${name%%-*}

    ln -f \"$narinfo\" \"$STATIC/${hash}.narinfo\" 2>/dev/null \\
      || cp -u \"$narinfo\" \"$STATIC/${hash}.narinfo\"

    nar=\"$CACHE/${name}.nar\"
    if [ -f \"$nar\" ]; then
        ln -f \"$nar\" \"$STATIC/nar/zstd/${name}\" 2>/dev/null \\
          || cp -u \"$nar\" \"$STATIC/nar/zstd/${name}\"
    fi
done

for narinfo in \"$STATIC\"/*.narinfo; do
    [ -f \"$narinfo\" ] || continue
    hash=$(basename \"$narinfo\" .narinfo)
    if ! ls \"$CACHE\"/${hash}-*.narinfo &>/dev/null; then
        rm -f \"$narinfo\"
        for nar in \"$STATIC/nar/zstd/${hash}-\"*; do
            [ -f \"$nar\" ] && rm -f \"$nar\"
        done
    fi
done

echo \"Static layout: $(ls \"$STATIC\"/*.narinfo 2>/dev/null | wc -l) narinfos\"
echo \"Nars: $(ls \"$STATIC/nar/zstd/\" 2>/dev/null | wc -l) files\"
du -sh \"$STATIC\"

rsync -az --delete \"$STATIC/\" \"$REMOTE:/srv/substitutes/\"
"))))

;; Conservative GC — this is a workstation, not a dedicated build server
(define %gc-job
  #~(job "0 4 * * 0"
         "guix gc --free-space=20G"
         #:user "root"))

;; Poll the Cuirass queue and publish substitutes once each build batch settles,
;; rather than on an arbitrary clock. An empty /api/queue means the current batch
;; (including failures) has left the queue, so it is safe to warm + rsync.
(define %substitute-sync-daemon
  (program-file "substitute-sync-daemon"
    #~(begin
        (use-modules (web client)
                     (web response)
                     (rnrs bytevectors)
                     (ice-9 format))

        (define poll-interval 60)
        (define debounce-polls 2)

        (define (log fmt . args)
          (let ((ts (strftime "%Y-%m-%d %H:%M:%S" (localtime (current-time)))))
            (apply format (current-error-port)
                   (string-append "[~a] substitute-sync: " fmt "~%")
                   ts args)
            (force-output (current-error-port))))

        ;; Queue body is "[]" (2 chars) when nothing is pending or running.
        (define (queue-busy?)
          (catch #t
            (lambda ()
              (call-with-values
                  (lambda ()
                    (http-get "http://localhost:8081/api/queue?nr=1"))
                (lambda (response body)
                  (if (>= (response-code response) 300)
                      (begin (log "queue returned HTTP ~a, treating as settled"
                                  (response-code response))
                             #f)
                      (let ((text (string-trim-both
                                   (if (bytevector? body) (utf8->string body) body))))
                        (not (string=? text "[]")))))))
            (lambda (key . args)
              (log "queue poll failed: ~a ~a" key args)
              #f)))

        ;; rsync exit code is the success signal for the whole sync.
        (define (run-sync)
          (catch #t
            (lambda ()
              (log "build batch settled, syncing substitutes")
              (system* #$%warmup-publish-cache)
              (let ((rc (status:exit-val (system* #$%sync-substitutes))))
                (if (eqv? rc 0)
                    (begin (log "sync complete") #t)
                    (begin (log "sync failed (rsync exit ~a)" rc) #f))))
            (lambda (key . args)
              (log "sync errored: ~a ~a" key args)
              #f)))

        (log "starting (poll ~as, debounce ~a)" poll-interval debounce-polls)
        (run-sync)
        (let loop ((idle 0) (dirty #f) (fails 0))
          (sleep (* poll-interval (min 8 (+ 1 fails))))
          (if (queue-busy?)
              (loop 0 #t 0)
              (let ((idle (+ idle 1)))
                (if (and dirty (>= idle debounce-polls))
                    (if (run-sync)
                        (loop idle #f 0)
                        (loop idle #t (+ fails 1)))
                    (loop idle dirty fails))))))))

(define %substitute-sync-service
  (shepherd-service
   (provision '(substitute-sync))
   (requirement '(user-processes networking guix-publish cuirass cuirass-web))
   (documentation "Publish substitutes to the remote after each Cuirass build batch.")
   (start #~(make-forkexec-constructor
             (list #$%substitute-sync-daemon)
             #:environment-variables
             (cons "HOME=/root" (default-environment-variables))
             #:log-file "/var/log/substitute-sync.log"))
   (stop #~(make-kill-destructor))))

(operating-system
 (inherit %common-os)
 (host-name "thinkpad")

 (initrd microcode-initrd)
 (firmware (list linux-firmware
                 i915-firmware
                 wireless-regdb))

 (initrd-modules
  (cons* "i915" %base-initrd-modules))

 (kernel-arguments
  (cons* "cfg80211.ieee80211_regdom=PT"
         "snd_hda_intel.dmic_detect=0"
         "slab_nomerge"
         "randomize_kstack_offset=on"
         "page_alloc.shuffle=1"
         "init_on_free=1"
         "bdev_allow_write_mounted=0"
         "proc_mem.force_override=never"
   %default-kernel-arguments))

 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets '("/boot/efi"))))

 (mapped-devices
  (list (mapped-device
         (source (uuid "bf66bcde-3847-452b-a5e2-1906e5b9766d"))
         (target "cryptroot")
         (type luks-device-mapping))))

 (packages
  (cons* curl rsync
         (operating-system-packages %common-os)))

 (file-systems
  (append
   (list (file-system
          (device "/dev/mapper/cryptroot")
          (mount-point "/")
          (type "ext4")
          (dependencies mapped-devices))
         (file-system
          (device (uuid "14C5-1711"
                        'fat32))
          (mount-point "/boot/efi")
          (type "vfat")))
   %base-file-systems))

 (services
  (modify-services
    (cons*
     (service zram-device-service-type
              (zram-device-configuration
               (size "8G")
               (priority 0)))
     (service openssh-service-type
           (openssh-configuration
             (x11-forwarding? #f)
             (permit-root-login #f)
             (password-authentication? #f)
             (authorized-keys
              `(("franz" ,(plain-file "franz.pub" %franz-ssh-key))))))
     (service thermald-service-type)
     (udev-rules-service 'backlight %backlight-udev-rule)
     (service tlp-service-type
              (tlp-configuration
               (cpu-scaling-governor-on-ac (list "balanced" "performance"))
               (cpu-boost-on-ac? #f)
               (cpu-scaling-governor-on-bat (list "low-power"))
               (cpu-boost-on-bat? #f)
               (sched-powersave-on-bat? #t)))
     (service mullvad-daemon-service-type)
     (service tailscale-service-type)

     ;; Build server services
     (service postgresql-service-type
              (postgresql-configuration
               (postgresql postgresql-15)))
     (service cuirass-service-type
              (cuirass-configuration
               (specifications %cuirass-specs)
               (host "0.0.0.0")
               (fallback? #t)))
     (service guix-publish-service-type
              (guix-publish-configuration
               (host "127.0.0.1")
               (port 3000)
               (compression '(("zstd" 19)))
               (cache "/var/cache/publish")
               (ttl (* 90 24 3600))))
     (simple-service 'build-server-jobs mcron-service-type
                     (list %gc-job))
     (simple-service 'substitute-sync shepherd-root-service-type
                     (list %substitute-sync-service))

     %common-services)
    (iptables-service-type config =>
      (iptables-configuration
       (ipv4-rules %thinkpad-iptables-ipv4-rules)
       (ipv6-rules %thinkpad-iptables-ipv6-rules)))
    ;; Keep running with lid closed so builds and rsync can finish
    (elogind-service-type config =>
      (elogind-configuration
       (inherit config)
       (handle-lid-switch 'ignore)
       (handle-lid-switch-docked 'ignore)
       (handle-lid-switch-external-power 'ignore))))))
