(define-module (thinkpad)
  #:use-module (common)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (gnu services xorg)
  #:use-module (gnu services ssh)
  #:use-module (gnu services pm)             ;; tlp-service-type
  #:use-module (gnu services linux)          ;; zram-device-service-type
  #:use-module (gnu services networking)     ;; iptables-service-type
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu system linux-initrd)
  #:use-module (small-guix services mullvad)) ;; mullvad-daemon-service-type

;; Allow members of the "video" group to change the screen brightness.
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
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-port-unreachable
COMMIT
"))

(define %thinkpad-iptables-ipv6-rules
  (plain-file "ip6tables.rules" "*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp6-port-unreachable
COMMIT
"))

(operating-system
 (inherit %common-os)
 (host-name "thinkpad")
 
 (initrd microcode-initrd)
 (firmware (list linux-firmware 
                 i915-firmware))
 
 (initrd-modules 
  (cons* "i915" %base-initrd-modules))
 
 (kernel-arguments 
  (cons* "snd_hda_intel.dmic_detect=0"
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
     (udev-rules-service 'backlight %backlight-udev-rule)
     (service tlp-service-type
              (tlp-configuration
               (cpu-scaling-governor-on-ac (list "balanced" "performance"))
               (cpu-boost-on-ac? #f)
               (cpu-scaling-governor-on-bat (list "low-power"))
               (cpu-boost-on-bat? #f)
               (sched-powersave-on-bat? #t)))
     (service mullvad-daemon-service-type)
     %common-services)
    (iptables-service-type config =>
      (iptables-configuration
       (ipv4-rules %thinkpad-iptables-ipv4-rules)
       (ipv6-rules %thinkpad-iptables-ipv6-rules))))))