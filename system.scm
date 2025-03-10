(use-modules (gnu)
             (gnu system)
             (gnu system setuid)

             (gnu services linux)
             (gnu services base)
             (gnu services mcron)
             (gnu services sysctl)
             (gnu services dbus)
             (gnu services xorg)
             (gnu services virtualization)
             ;; gvfs-service-type
             (gnu services desktop)
	     
             (gnu packages emacs)
             (gnu packages docker)
             (gnu packages wm)
             (gnu packages terminals)
             (gnu packages shells)
             (gnu packages xdisorg)
             (gnu packages gnome)
             (gnu packages freedesktop)
             (gnu packages vim)
             (gnu packages security-token)
	     
             (nongnu packages linux)
             (nongnu packages firmware)
             (nongnu system linux-initrd)
	     
             (px system panther)
             (px packages throttled)
             ;; acsccid
             (px packages security-token))

(use-service-modules docker
                     pm
                     web
                     security-token
                     sysctl
                     networking
                     mail
                     admin)

;; Allow members of the "video" group to change the screen brightness.
(define %backlight-udev-rule
  (udev-rule "90-backlight.rules"
             (string-append
	      "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
	      "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/intel_backlight/brightness\""
	      "\n" "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
	      "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness\"")))

;; https://stackoverflow.com/a/77312416
(define %nftables-ruleset
  (plain-file "nftables.conf"
              "# Firewall
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    # early drop of invalid connections
    ct state invalid drop

    # allow established/related connections
    ct state { established, related } accept

    # allow from loopback
    iif lo accept
    # drop connections to lo not coming from lo
    iif != lo ip daddr 127.0.0.1/8 drop
    iif != lo ip6 daddr ::1/128 drop

    # allow icmp
    ip protocol icmp accept
    ip6 nexthdr icmpv6 accept

    # allow ssh
    tcp dport ssh accept

    # allow 4001?
    tcp dport 4001 accept

    # allow 22000?
    tcp dport 22000 accept

    # allow 3000?
    tcp dport 3000 accept

    # reject everything else
    reject with icmpx type port-unreachable
  }
  chain forward {
    type filter hook forward priority 0; policy drop;

    # Allow outgoing traffic, initiated by docker containers
    # This includes container-container and container-world traffic 
    # (assuming interface name is docker0)
    iifname \"docker0\" accept

    # Allow incoming traffic from established connections
    # This includes container-world traffic
    ct state vmap { established: accept, related: accept, invalid: drop }
  }
  chain output {
    type filter hook output priority 0; policy accept;
  }
}
"))

(operating-system
 (inherit %panther-os)
 (host-name "panther")
 (timezone "Europe/Lisbon")
 (locale "en_US.utf8")
 
 (initrd microcode-initrd)
 (firmware (list linux-firmware i915-firmware))
 
 (initrd-modules (cons* "i915" %base-initrd-modules))
 
 (kernel-arguments (cons* "snd_hda_intel.dmic_detect=0"
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
 
 (users
  (cons
   (user-account
    (name "franz")
    (comment "default")
    (group "users")
    (supplementary-groups '("wheel"
                            "netdev"
                            "docker"
                            "kvm"
                            "audio"
                            "video"
                            "plugdev"
                            "input"))
    (home-directory "/home/franz"))
   %base-user-accounts))
 
 (packages (cons* emacs
                  throttled
                  ; docker
                  containerd
                  ; docker-cli
                  libinput
                  neovim
                  foot ;terminal
                  wlr-randr ;display
                  xsettingsd ;xwayland, java
                  gvfs ;for thunar to show trash, removable media and so on
                  udiskie ;auto-mounts
                  %panther-base-packages))
 
 (services
  (cons*
   (service zram-device-service-type
            (zram-device-configuration
             (size "8G")
             (priority 0)))
   
   (service screen-locker-service-type
            (screen-locker-configuration
             (name "swaylock")
             (program (file-append swaylock-effects "/bin/swaylock"))
             (using-pam? #t)
             (using-setuid? #f)))
   
   (service greetd-service-type
            (greetd-configuration
             (greeter-supplementary-groups
              (list "video" "input" "users"))
             (terminals
              (list 
               (greetd-terminal-configuration
                (terminal-vt "1")
                (terminal-switch #t)
                (default-session-command
                  (greetd-wlgreet-sway-session)))
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
             (schedule "0 12 * * *")
             (channels #~
                       (cons* 
			(channel
			 (name 'pantherx)
			 (branch "master")
			 (url "https://channels.pantherx.org/git/panther.git")
			 (introduction
			  (make-channel-introduction
			   "54b4056ac571611892c743b65f4c47dc298c49da"   
			   (openpgp-fingerprint
			    "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
			%default-channels))))
   
   (service dovecot-service-type
            (dovecot-configuration
             (mail-location "maildir:~/.mail")))
   
   (service containerd-service-type)
   (service docker-service-type)
   
   ;; https://www.reddit.com/r/GUIX/comments/xjjmtr/comment/iqs6cwe/
   (simple-service 'fwupd-polkit polkit-service-type
                   (list fwupd-nonfree))
   
   (udev-rules-service 'backlight %backlight-udev-rule)
   
   (service pcscd-service-type
            (pcscd-configuration
             (usb-drivers (list acsccid ccid))))
   
   (service block-facebook-hosts-service-type)
   
   ;; Support for trash, ftp, sftp ... in Thunar
   ;; Includes udisks-service-type
   (service gvfs-service-type)
   
   (service nftables-service-type
    (nftables-configuration
     (ruleset %nftables-ruleset)))

   (service bluetooth-service-type
            (bluetooth-configuration 
             (auto-enable? #t)))

   (service tlp-service-type
            (tlp-configuration
             (cpu-scaling-governor-on-ac (list "performance"))
             ;; little faster, a lot hotter
             ;; (cpu-boost-on-ac? #t)
             (sched-powersave-on-bat? #t)))

   (service thermald-service-type)
   
   %panther-desktop-services-minimal)))
