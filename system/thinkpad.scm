(define-module (thinkpad)
  #:use-module (common)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (gnu services xorg)
  #:use-module (gnu services pm)             ;; tlp-service-type
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu system linux-initrd))

;; Allow members of the "video" group to change the screen brightness.
(define %backlight-udev-rule
  (udev-rule "90-backlight.rules"
             (string-append
	      "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
	      "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/intel_backlight/brightness\""
	      "\n" "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
	      "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness\"")))

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
  (cons*
   (udev-rules-service 'backlight %backlight-udev-rule)
   (service tlp-service-type
            (tlp-configuration
             (cpu-scaling-governor-on-ac (list "performance"))
             ;; little faster, a lot hotter
             ;; (cpu-boost-on-ac? #t)
             (sched-powersave-on-bat? #t)))
   %common-services)))