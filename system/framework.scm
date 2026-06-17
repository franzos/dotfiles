(define-module (framework)
  #:use-module (common)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix gexp)
  #:use-module (guix packages)                ;; package record
  #:use-module (guix build-system trivial)    ;; trivial-build-system
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu services xorg)
  #:use-module (gnu services desktop)         ;; elogind-service-type
  #:use-module (gnu services pm)              ;; power-profiles-daemon-service-type
  #:use-module (gnu services linux)           ;; zram-device-service-type
  #:use-module (gnu services base)            ;; udev-service-type
  #:use-module (gnu services mcron)           ;; mcron-service-type
  #:use-module (gnu system file-systems)      ;; swap-space
  #:use-module (gnu packages admin)           ;; aide, lynis
  #:use-module (gnu packages base)            ;; coreutils, grep, diffutils
  #:use-module (gnu packages bash)            ;; bash
  #:use-module (gnu packages version-control) ;; git
  #:use-module (px packages linux)            ;; wireless-regdb-signed
  #:use-module (px packages networking)       ;; vpnmux
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu system linux-initrd)
  #:use-module (px services networking)       ;; mullvad-daemon-service-type, vpnmux-service-type
  #:use-module (px services usbguard))         ;; usbguard-service-type

(define %aide-conf (local-file "aide-system.conf"))

(define (security-wrapper name script)
  (program-file name
    #~(begin
        (setenv "PATH"
                (string-append
                 #$(file-append coreutils "/bin") ":"
                 #$(file-append aide "/bin") ":"
                 #$(file-append lynis "/bin") ":"
                 #$(file-append git "/bin") ":"
                 #$(file-append grep "/bin") ":"
                 #$(file-append diffutils "/bin")))
        (setenv "AIDE_CONF" #$%aide-conf)
        (execl #$(file-append bash "/bin/bash") "bash" #$script))))

(define security-aide-system
  (security-wrapper "security-aide-system" (local-file "security-aide-system")))
(define security-aide-accept-program
  (security-wrapper "security-aide-accept" (local-file "security-aide-accept")))
(define security-lynis-weekly
  (security-wrapper "security-lynis-weekly" (local-file "security-lynis-weekly")))

;; Expose `security-aide-accept` on PATH (sudo security-aide-accept)
(define security-cli
  (package
    (name "security-cli")
    (version "1.0")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list #:builder
           #~(begin
               (mkdir #$output)
               (mkdir (string-append #$output "/bin"))
               (symlink #$security-aide-accept-program
                        (string-append #$output "/bin/security-aide-accept")))))
    (home-page "")
    (synopsis "Root-scope security CLI wrappers")
    (description "Provides the @command{security-aide-accept} command for
accepting a new system-scope AIDE baseline.")
    (license license:gpl3+)))

(define mcron-job-security-aide
  #~(job "0 3 * * *" #$security-aide-system))
(define mcron-job-security-lynis
  #~(job "30 3 * * 1" #$security-lynis-weekly))

(operating-system
 (inherit %common-os)
 (host-name "framework")

 (kernel linux-6.19)
 (initrd microcode-initrd)
 (firmware (list linux-firmware
                 amdgpu-firmware
                 amd-microcode
                 wireless-regdb-signed))

 (kernel-arguments
  (cons* "resume=/dev/mapper/cryptroot"           ;; Resume from hibernation
         "resume_offset=317310976"                ;; Swap file offset for hibernation
         "rtc_cmos.use_acpi_alarm=1"              ;; Fix RTC alarm for suspend-then-hibernate on AMD
         "amd_pstate=active"                      ;; AMD Ryzen EPP power management
         "pcie_aspm.policy=powersupersave"        ;; PCIe power saving, includes L1.1/L1.2 substates
         "amdgpu.ppfeaturemask=0xfff5bfff"        ;; Default minus stutter (GFXOFF re-enabled for s2idle)
         "amdgpu.gpu_recovery=1"                  ;; Enable GPU reset after hang
         "snd_hda_intel.power_save=1"             ;; Audio codec sleep after 1s silence
         "nmi_watchdog=0"                         ;; Disable NMI watchdog for power saving
         "modprobe.blacklist=hid_sensor_hub"
         "cfg80211.ieee80211_regdom=PT"           ;; WiFi regulatory domain for Portugal
         ;; Security hardening
         ;; NOTE: unprivileged user namespaces must stay enabled —
         ;; guix-daemon runs unprivileged (system/common.scm) and needs
         ;; them for per-build UID isolation. Don't set
         ;; kernel.unprivileged_userns_clone=0 or user.max_user_namespaces=0.
         "slab_nomerge"                           ;; Prevent slab merging attacks
         "randomize_kstack_offset=on"             ;; Randomize kernel stack offset
         "page_alloc.shuffle=1"                   ;; Memory layout randomization
         "init_on_alloc=1"                        ;; Zero allocated memory (UAF mitigation, lower overhead)
         "bdev_allow_write_mounted=0"             ;; No raw writes to mounted block devs
         "proc_mem.force_override=never"          ;; Close /proc/PID/mem force-write
         ;; LSM stack — include landlock so unprivileged sandboxes
         ;; (Chromium, Firefox renderer) can actually self-restrict.
         ;; Without this dmesg logs "landlock: Disabled but requested by user space".
         "lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
   %default-kernel-arguments))

 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets '("/boot/efi"))))

  (mapped-devices
   (list (mapped-device
          (source (uuid
                   "33d48354-afc2-428f-aa2a-0234984a04d8"))
          (target "cryptroot")
          (type luks-device-mapping))))

  (file-systems
   (cons* (file-system
           (mount-point "/boot/efi")
           (device (uuid "71CB-FDB7"
                         'fat32))
           (type "vfat"))
          (file-system
            (mount-point "/")
            (device "/dev/mapper/cryptroot")
            (type "ext4")
            (dependencies mapped-devices))
           %base-file-systems))

 (swap-devices
  (list
   (swap-space
    (target "/swapfile")
    (dependencies (filter (file-system-mount-point-predicate "/")
                          file-systems))
    (priority 10))))  ;; Low priority - only used for hibernation and overflow

 ;; vpnmux CLI globally available (the service also adds it to the profile).
 (packages
  (cons* vpnmux security-cli
         (operating-system-packages %common-os)))

 (services
  (cons*
   (service zram-device-service-type
            (zram-device-configuration
             (size "24G")
             (priority 100)))  ;; High priority - use zram first for performance
   ;; powerprofilesctl set power-saver
   (service power-profiles-daemon-service-type)
   (simple-service 'amdgpu-power-auto udev-service-type
                   (list (udev-rule "90-amdgpu-power.rules"
                                    (string-append
                                     "KERNEL==\"card[0-9]\", SUBSYSTEM==\"drm\", "
                                     "DRIVERS==\"amdgpu\", "
                                     "ATTR{device/power_dpm_force_performance_level}=\"auto\"\n"))))

   ;; Enable USB autosuspend for Framework HDMI expansion card and YubiKey
   (simple-service 'usb-autosuspend udev-service-type
                   (list (udev-rule "90-usb-autosuspend.rules"
                                    (string-append
                                     ;; Framework HDMI Expansion Card
                                     "ACTION==\"add\", SUBSYSTEM==\"usb\", "
                                     "ATTR{product}==\"HDMI Expansion Card\", "
                                     "ATTR{manufacturer}==\"Framework\", "
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"))))

   ;; Enable PCI Runtime PM for NVMe SSD
   (simple-service 'nvme-runtime-pm udev-service-type
                   (list (udev-rule "90-nvme-power.rules"
                                    (string-append
                                     "ACTION==\"add\", SUBSYSTEM==\"pci\", "
                                     "ATTR{vendor}==\"0x144d\", "  ;; Samsung
                                     "ATTR{class}==\"0x010802\", "  ;; NVMe controller
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"))))

   ;; PCI Runtime PM for WiFi, GPU, and AMD crypto coprocessor.
   ;; No ACTION== match: devices enumerated before udevd loads its
   ;; rules don't get an "add" event, so a rule gated on "add" silently
   ;; skips them. TEST==power/control guards against remove events.
   (simple-service 'pci-runtime-pm udev-service-type
                   (list (udev-rule "90-pci-runtime-pm.rules"
                                    (string-append
                                     ;; MediaTek MT7921 WiFi
                                     "SUBSYSTEM==\"pci\", "
                                     "ATTR{vendor}==\"0x14c3\", "
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"
                                     ;; AMD GPU (amdgpu)
                                     "SUBSYSTEM==\"pci\", "
                                     "ATTR{vendor}==\"0x1002\", "
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"
                                     ;; AMD CCP (crypto coprocessor)
                                     "SUBSYSTEM==\"pci\", "
                                     "ATTR{vendor}==\"0x1022\", ATTR{device}==\"0x15c7\", "
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"))))

   ;; Disable spurious s2idle wakeup sources. Hibernate (S4) is broken on
   ;; this board (kernel snapshots RAM but can't open the swap writer:
   ;; "Cannot get swap writer"), so the lid action is plain suspend and
   ;; only the lid switch and power button should wake it. USB xHCI
   ;; (XHC*), Thunderbolt (NHI*) and the upstream PCIe ports (GPP*/GP*)
   ;; otherwise fire on their own and drain the battery. No ACTION== match
   ;; (devices enumerated before udevd get no "add"); TEST==power/wakeup
   ;; guards devices without the attribute. See SLEEP_DEBUGGING.md.
   (simple-service 'disable-spurious-wakeups udev-service-type
                   (list (udev-rule "90-disable-wakeups.rules"
                                    (string-append
                                     ;; PCIe ports GPP6 / GP11 / GP12
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:00:02.2\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:00:03.1\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:00:04.1\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     ;; USB xHCI controllers XHC0 / XHC1 / XHC3 / XHC4
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:c1:00.3\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:c1:00.4\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:c3:00.3\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:c3:00.4\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     ;; Thunderbolt NHI0 / NHI1
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:c3:00.5\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"
                                     "SUBSYSTEM==\"pci\", KERNEL==\"0000:c3:00.6\", TEST==\"power/wakeup\", ATTR{power/wakeup}=\"disabled\"\n"))))

   ;; AMD NPU accelerator (amdxdna) — allow render group access
   (simple-service 'amdxdna-accel udev-service-type
                   (list (udev-rule "90-amdxdna.rules"
                                    "SUBSYSTEM==\"accel\", KERNEL==\"accel*\", GROUP=\"render\", MODE=\"0660\"\n")))

   ;; Android USB debugging (Pixel: ADB, fastboot, MTP)
   (simple-service 'android-udev udev-service-type
                   (list (udev-rule "51-android.rules"
                                    (string-append
                                     "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4ee2\", MODE=\"0660\", GROUP=\"plugdev\"\n"
                                     "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4ee1\", MODE=\"0660\", GROUP=\"plugdev\"\n"
                                     "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4ee7\", MODE=\"0660\", GROUP=\"plugdev\"\n"))))

   (service mullvad-daemon-service-type)
   (service tailscale-service-type)

   ;; Keep Mullvad and Tailscale from clashing at the netfilter/DNS layer.
   (service vpnmux-service-type)

   ;; Resolve Podman's host-gateway name to localhost on the host itself,
   ;; so tooling hardcoded to host.containers.internal also works outside
   ;; containers. Appends to /etc/hosts alongside block-facebook-hosts.
   (simple-service 'host-containers-internal hosts-service-type
                   (list (host "127.0.0.1" "host.containers.internal")))

   ;; USBGuard — USB device authorization.
   ;;
   ;; Trial mode: 'implicit-policy-target is 'allow, so any device that
   ;; doesn't match a rule falls through to "allow" instead of being
   ;; blocked.
   (service usbguard-service-type
            (usbguard-configuration
             (implicit-policy-target 'allow)     ;; TRIAL: flip to 'block later
             (present-device-policy 'apply-policy)
             (inserted-device-policy 'apply-policy)
             (authorized-default 'all)           ;; no unauthorized window during trial
             (device-rules-with-port? #f)        ;; Yubikey works in any port
             (ipc-allowed-groups '("wheel"))))   ;; run `usbguard` CLI without sudo

   ;; Root-scope security auditing — AIDE file integrity (daily) and Lynis
   ;; (weekly). Results land in /var/log/security-*.log; state is root-only
   ;; under /var/lib. Review an AIDE diff, then `sudo security-aide-accept`.
   (simple-service 'security-audit-cron mcron-service-type
                   (list mcron-job-security-aide mcron-job-security-lynis))

   ;; Hibernate (S4) is broken on this board — the kernel snapshots RAM
   ;; but can't open the swap writer ("Cannot find swap device / Cannot
   ;; get swap writer"), and the failed thaw wedges amdgpu (black screen,
   ;; power LED only). Override the suspend-then-hibernate lid action
   ;; inherited from common.scm and just suspend (s2idle). This platform
   ;; has no S3 either. See SLEEP_DEBUGGING.md.
   (modify-services %common-services
     (elogind-service-type config =>
       (elogind-configuration
        (inherit config)
        (handle-lid-switch 'suspend)
        (handle-lid-switch-external-power 'suspend)))))))
