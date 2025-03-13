(define-module (thinkpad)
  #:use-module (common)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (gnu services xorg)
  #:use-module (gnu services pm)             ;; tlp-service-type
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu system linux-initrd))

;; https://repo.fo.am/zzkt/guix/src/branch/endless/config/framework13-system.scm
(operating-system
 (inherit %common-os)
 (host-name "framework")
 
 ;; (initrd microcode-initrd)
 (initrd (lambda (file-systems . rest)
          (apply microcode-initrd file-systems
                 #:initrd base-initrd
                 #:microcode-packages (list amd-microcode)
                 rest)))
                 
 (firmware (list linux-firmware
                 amdgpu-firmware
                 amd-microcode))
 
 (kernel-arguments 
  (cons* "modprobe.blacklist=hid_sensor_hub"
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
   (service tlp-service-type
            (tlp-configuration
             (cpu-scaling-governor-on-ac (list "performance"))
             ;; little faster, a lot hotter
             ;; (cpu-boost-on-ac? #t)
             (sched-powersave-on-bat? #t)))
   %common-services)))