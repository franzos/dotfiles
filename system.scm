(use-modules (gnu)
             (gnu system)
             (gnu system setuid)

             (gnu services linux)
             (gnu services base)
             (gnu services mcron)
             (gnu services sysctl)
             (gnu services dbus)
             (gnu services xorg)
             (gnu services sound)
             (gnu services desktop)
             (gnu services virtualization)

             (gnu packages emacs)
             (gnu packages docker)
             (gnu packages wm)
             (gnu packages terminals)
             (gnu packages shells)
             (gnu packages xdisorg)
             (gnu packages linux)
             (gnu packages gnome)
             (gnu packages freedesktop)
             (gnu packages vim)
             (gnu packages security-token)

             (nongnu packages linux)
             (nongnu packages firmware)
             (nongnu system linux-initrd)

             (px system config)
             (px packages security-token)
             (px packages throttled)
             (px services networking)
             (gnu services monitoring))

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
             (string-append "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
              "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/intel_backlight/brightness\""
              "\n" "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
              "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness\"")))

(define updatedb-job
  #~(job '(next-hour '(3))
         (lambda ()
           (execl (string-append #$findutils "/bin/updatedb") "updatedb"
                  "--prunepaths=/tmp /var/tmp /gnu/store"))))

(define garbage-collector-job
  #~(job "5 0 * * *" "guix gc -d 4m -F 10G"))

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

(define %custom-desktop-services
  (modify-services %px-desktop-minmal-services
       (nftables-service-type config =>
        (nftables-configuration
         (ruleset %nftables-ruleset)))
		   (sysctl-service-type config =>
        (sysctl-configuration
			  (inherit config)
        (settings
			   (append '(("fs.inotify.max_user_watches" . "524288"))
                                   %default-sysctl-settings))))))

(px-desktop-os
 (operating-system
  (host-name "panther")
  (timezone "Europe/Paris")
  (locale "en_US.utf8")
  
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware i915-firmware))
  
  (initrd-modules (cons* "i915" %base-initrd-modules))
  
  (kernel-arguments (cons* "snd_hda_intel.dmic_detect=0"
                           %default-kernel-arguments))
  
  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets '("/boot/efi"))))
  
  (mapped-devices
   (list (mapped-device
          (source (uuid
                   "bf66bcde-3847-452b-a5e2-1906e5b9766d"))
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
                             "lpadmin"
                             "lp"
                             "plugdev"
                             "input"))
     (home-directory "/home/franz"))
    %base-user-accounts))
  
  (packages (cons* emacs
                   throttled
                   docker
                   containerd
                   docker-cli
                   libinput
                   neovim
                   foot ;terminal
                   wlr-randr ;display
                   xsettingsd ;xwayland, java
                   gvfs ;mounts - probably not needed
                   udiskie ;auto-mounts
                   %px-desktop-minimal-packages))
  
  (services
   (cons*
    (service zram-device-service-type
             (zram-device-configuration
	      (size "8G")
              (priority 0)))
    (service screen-locker-service-type
             (screen-locker-configuration
	      (name
               "swaylock")
              (program (file-append
                        xlockmore
                        "/bin/xlock"))))
    
    (service greetd-service-type
             (greetd-configuration
	      (greeter-supplementary-groups
               (list "video" "input"))
              (terminals
	       (list (greetd-terminal-configuration
                      (terminal-vt
                       "1")
                      (terminal-switch
                       #t)
                      (default-session-command
                        (greetd-wlgreet-sway-session)))
		     
                     (greetd-terminal-configuration
                      (terminal-vt
                       "2"))
                     (greetd-terminal-configuration
                      (terminal-vt
                       "3"))
                     (greetd-terminal-configuration
                      (terminal-vt
                       "4"))
                     (greetd-terminal-configuration
                      (terminal-vt
                       "5"))
                     (greetd-terminal-configuration
                      (terminal-vt
                       "6"))))))
    
    (service unattended-upgrade-service-type
             (unattended-upgrade-configuration
	      (schedule
               "0 12 * * *")
              (channels #~
                        (cons* (channel
                                (name 'pantherx)
                                (branch
                                 "master")
                                (url
                                 "https://channels.pantherx.org/git/panther.git")
                                (introduction
                                 (make-channel-introduction
                                  "54b4056ac571611892c743b65f4c47dc298c49da"   
                                  (openpgp-fingerprint
                                   "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
                               %default-channels))))
    
    (service dovecot-service-type
             (dovecot-configuration
	      (mail-location
               "maildir:~/.mail")))
    
    (service containerd-service-type)
    (service docker-service-type)
    (service nebula-service-type)
    (simple-service 'my-cron-jobs mcron-service-type
                    (list garbage-collector-job
                          updatedb-job))

    ;; https://www.reddit.com/r/GUIX/comments/xjjmtr/comment/iqs6cwe/
    (simple-service 'fwupd-polkit polkit-service-type
                (list fwupd-nonfree))
    
    (udev-rules-service 'backlight %backlight-udev-rule)
    
    (service pcscd-service-type
             (pcscd-configuration
	      (usb-drivers (list acsccid ccid))))
    
    (service block-facebook-hosts-service-type)
    ;; Comes with udisks-service-type
    (service gvfs-service-type)
    
    %custom-desktop-services)))
 
 #:kernel 'custom)
