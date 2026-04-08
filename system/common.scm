(define-module (common)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system setuid)
  #:use-module (gnu system accounts)                 ;; for 'subid-range'
  #:use-module (gnu services linux)
  #:use-module (gnu services base)
  #:use-module (gnu services mcron)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services dbus)
  #:use-module (gnu services xorg)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services desktop)                ;; gvfs-service-type
  #:use-module (gnu services containers)
  #:use-module (gnu services web)
  #:use-module (gnu services security-token)
  #:use-module (gnu services networking)
  #:use-module (gnu services mail)
  #:use-module (gnu services auditd)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system pam)
  #:use-module (gnu packages admin)                  ;; audit
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages containers)
  #:use-module (gnu packages security-token)         ;; ccid
  #:use-module (gnu packages authentication)         ;; yubico-pam, fprintd

  #:use-module (gnu services authentication)         ;; fprintd-service-type
  #:use-module (nongnu packages firmware)            ;; fwupd-nonfree

  #:use-module (px services unattended-upgrade)
  #:use-module (px system os)
  #:use-module (px services audio)                   ;; rtkit-daemon-service-type
  #:use-module (px services ntp)                     ;; chrony-service-type (NTS)
  #:use-module (px packages security-token)          ;; acsccid
  #:use-module (px packages linux)                   ;; bluez 5.83
  #:use-module (px services security-token)          ;; nitro, coinkite, ledger udev rules

  #:export (%common-os %common-services))

(define %iptables-ipv4-rules
  (plain-file "iptables.rules" "*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i tailscale0 -j ACCEPT
-A INPUT -p udp --dport 41641 -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
"))

(define %iptables-ipv6-rules
  (plain-file "ip6tables.rules" "*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
"))

(define %networkmanager-wifi-config
  (plain-file "99-wifi-config.conf"
              "[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.powersave=2
wifi.cloned-mac-address=stable
"))

(define %auditd-rules-file
  (plain-file "audit.rules"
    "-w /home/franz/.ssh -p rwa -k sensitive-files
-w /home/franz/.aws -p rwa -k sensitive-files
-w /home/franz/.gnupg -p rwa -k sensitive-files
-w /home/franz/.config/gh -p rwa -k sensitive-files
-w /home/franz/.config/syncthing -p rwa -k sensitive-files
-w /home/franz/.local/share/keyrings -p rwa -k sensitive-files
"))

(define %common-services
 (append
  (list
   ;; NetworkManager WiFi configuration
   (extra-special-file "/etc/NetworkManager/conf.d/99-wifi-config.conf"
                       %networkmanager-wifi-config)
   (service screen-locker-service-type
            (screen-locker-configuration
             (name "swaylock")
             (program (file-append swaylock-effects "/bin/swaylock"))
             (using-pam? #t)
             (using-setuid? #f)))

   (service greetd-service-type
            (greetd-configuration
             (greeter-supplementary-groups
              (list "video" "input"))
             (terminals
              (list
               (greetd-terminal-configuration
                (terminal-vt "1")
                (terminal-switch #t)
                (default-session-command
                 (greetd-wlgreet-sway-session))
                (initial-session-user "franz")
                (initial-session-command (greetd-user-session)))
               (greetd-terminal-configuration
                (terminal-vt "2"))
               (greetd-terminal-configuration
                (terminal-vt "3"))
               (greetd-terminal-configuration
                (terminal-vt "4"))
               (greetd-terminal-configuration
                (terminal-vt "5"))
               (greetd-terminal-configuration
                (terminal-vt "6"))))))

   (service unattended-upgrade-service-type
            (unattended-upgrade-configuration
             (schedule "0 17 * * *")
             (system-load-paths '("/home/franz/dotfiles/system"))
             (skip-on-battery? #t)
             (channels #~
                       (cons*
                        (channel
                         (name 'pantherx)
                         (branch "master")
                         (url "https://codeberg.org/gofranz/panther.git")
                         (introduction
                          (make-channel-introduction
                           "54b4056ac571611892c743b65f4c47dc298c49da"
                           (openpgp-fingerprint
                            "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
                        %default-channels))))

   (service dovecot-service-type
            (dovecot-configuration
             (listen '("127.0.0.1" "::1"))
             (mail-location "maildir:~/.mail")))

   (simple-service 'fwupd-dbus dbus-root-service-type
                   (list fwupd-nonfree))
   (simple-service 'fwupd-polkit polkit-service-type
                   (list fwupd-nonfree))

   (service pcscd-service-type
            (pcscd-configuration
             (usb-drivers (list acsccid ccid))))

   (simple-service 'pcscd-polkit polkit-service-type
                   (list pcsc-lite))

   ;; Security token udev rules
   (simple-service 'custom-udev-rules udev-service-type
                   (list libu2f-host))
   (udev-rules-service 'nitro %nitro-key-udev-rule #:groups '("plugdev"))
   (udev-rules-service 'fido2 libfido2)
   (udev-rules-service 'yubikey yubikey-personalization)
   (udev-rules-service 'ledger %ledger-udev-rule)

   ;; Audit sensitive file access (query: ausearch -k sensitive-files)
   (service auditd-service-type
            (auditd-configuration
             (configuration-directory
              (computed-file "auditd"
               #~(begin
                   (mkdir #$output)
                   (copy-file #$(plain-file "auditd.conf"
                                 "log_file = /var/log/audit.log
log_format = ENRICHED
freq = 1
max_log_file = 50
max_log_file_action = ROTATE
num_logs = 3
space_left = 5%
space_left_action = syslog
admin_space_left_action = ignore
disk_full_action = ignore
disk_error_action = syslog
")
                              (string-append #$output "/auditd.conf")))))))
   ;; auditd does not load rules itself; auditctl must be run after daemon starts
   (simple-service 'audit-rules shepherd-root-service-type
     (list (shepherd-service
            (provision '(audit-rules))
            (requirement '(auditd))
            (one-shot? #t)
            (start #~(lambda _
                       (zero? (system* (string-append #$audit "/sbin/auditctl")
                                       "-R" #$%auditd-rules-file))))
            (documentation "Load audit rules into the kernel."))))

   (service block-facebook-hosts-service-type)

   ;; Support for trash, ftp, sftp ... in Thunar
   ;; Includes udisks-service-type
   (service gvfs-service-type)

   (service bluetooth-service-type
            (bluetooth-configuration
             (bluez bluez)
             (auto-enable? #t)
             (experimental #t)           ;; Enable experimental features for modern devices
             (multi-profile 'multiple))) ;; Enable multiple profiles (A2DP + HFP/HSP)

   (service earlyoom-service-type)

   (service rtkit-daemon-service-type)

   (service iptables-service-type
         (iptables-configuration
          (ipv4-rules %iptables-ipv4-rules)
          (ipv6-rules %iptables-ipv6-rules)))

   ;; Chrony with NTS (RFC 8915) — authenticated time sync.
   ;; Replaces the default ntpd from %desktop-services
   (service chrony-service-type)

   (service rootless-podman-service-type
            (rootless-podman-configuration
             (subgids
              (list (subid-range (name "franz"))))
             (subuids
              (list (subid-range (name "franz"))))))

   ;; Yubikey challenge-response for sudo (touch only, no password)
   (simple-service 'yubico-pam-sudo
     pam-root-service-type
     (list (pam-extension
            (transformer
             (lambda (pam)
               (if (member (pam-service-name pam) '("sudo"))
                   (pam-service
                    (inherit pam)
                    (auth (cons (pam-entry
                                 (control "sufficient")
                                 (module (file-append yubico-pam "/lib/security/pam_yubico.so"))
                                 (arguments '("mode=challenge-response")))
                                (pam-service-auth pam))))
                   pam))))))

   ;; Fingerprint authentication service
   (service fprintd-service-type)

   ;; Fingerprint login for greetd and swaylock (fallback to password if supported)
   (simple-service 'fprintd-pam-login
     pam-root-service-type
     (list (pam-extension
            (transformer
             (lambda (pam)
               (if (member (pam-service-name pam) '("greetd" "swaylock"))
                   (pam-service
                    (inherit pam)
                    (auth (cons (pam-entry
                                 (control "sufficient")
                                 (module (file-append fprintd "/lib/security/pam_fprintd.so")))
                                (pam-service-auth pam))))
                   pam)))))))

  (modify-services %os-desktop-services-minimal
    (delete ntp-service-type)

    ;; Configure elogind for suspend-then-hibernate
    (elogind-service-type config =>
      (elogind-configuration
        (inherit config)
        (handle-power-key 'ignore)
        (handle-lid-switch 'suspend-then-hibernate)
        (hibernate-delay-seconds 900)))

    ;; https://stackoverflow.com/questions/76830848/redis-warning-memory-overcommit-must-be-enabled
    (sysctl-service-type config => (sysctl-configuration
                                    (inherit config)
                                    (settings (append
                                              (sysctl-configuration-settings config)
                                              '(("vm.overcommit_memory" . "1")
                                               ("net.ipv4.ip_forward" . "1")
                                               ;; TCP BBR congestion control + fair queuing
                                               ("net.core.default_qdisc" . "fq_codel")
                                               ("net.ipv4.tcp_congestion_control" . "bbr")
                                               ;; Kernel hardening
                                               ("kernel.dmesg_restrict" . "1")
                                               ("kernel.unprivileged_bpf_disabled" . "1")
                                               ("kernel.yama.ptrace_scope" . "1")
                                               ("kernel.kexec_load_disabled" . "1")
                                               ("kernel.perf_event_paranoid" . "3")
                                               ;; Network hardening
                                               ("net.ipv4.conf.all.rp_filter" . "1")
                                               ("net.ipv4.conf.default.rp_filter" . "1")
                                               ("net.ipv4.conf.all.accept_redirects" . "0")
                                               ("net.ipv4.conf.default.accept_redirects" . "0")
                                               ("net.ipv6.conf.all.accept_redirects" . "0")
                                               ("net.ipv6.conf.default.accept_redirects" . "0")
                                               ("net.ipv4.conf.all.send_redirects" . "0")
                                               ("net.ipv4.conf.all.accept_source_route" . "0")
                                               ("net.ipv6.conf.all.accept_source_route" . "0")
                                               ("net.ipv4.tcp_syncookies" . "1")
                                               ("net.ipv4.icmp_echo_ignore_broadcasts" . "1")
                                               ;; Filesystem hardening
                                               ("fs.protected_fifos" . "2")
                                               ("fs.protected_regular" . "2")))))))))

(define %common-os
 (operating-system
  (inherit %os-base)
  (host-name "panther")
  (timezone "Europe/Lisbon")
  (locale "en_US.utf8")

  (groups
   (cons (user-group (name "render"))
         %base-groups))

  (users
   (cons
    (user-account
     (name "franz")
     (comment "default")
     (group "users")
     (supplementary-groups '("wheel"
                             "netdev"
                             "cgroup"
                             "kvm"
                             "audio"
                             "video"
                             "render"
                             "plugdev"
                             "input"))
     (home-directory "/home/franz"))
    %base-user-accounts))

  (packages
   (cons* emacs
    sway
    podman
    podman-compose
    buildah
    passt           ;; podman networking: provides pasta binary for rootless networking
    libinput
    neovim
    foot            ;; terminal
    wlr-randr       ;; display
    xsettingsd      ;; xwayland, java
    gvfs            ;; for thunar to show trash, removable media and so on
    udiskie         ;; auto-mounts
    pam-u2f         ;; U2F/FIDO2 PAM module
    libu2f-host     ;; U2F host library
    libu2f-server   ;; U2F server library
    yubico-pam      ;; yubikey challenge-response for sudo
    fprintd         ;; fingerprint reader
    %os-base-packages))

  (services
   %common-services)))
