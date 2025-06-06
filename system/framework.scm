(define-module (framework)
  #:use-module (common)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (gnu services xorg)
  #:use-module (gnu services pm)              ;; tlp-service-type
  #:use-module (gnu services linux)           ;; zram-device-service-type
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu system linux-initrd)
  #:use-module (small-guix services mullvad)) ;; mullvad-daemon-service-type

(operating-system
 (inherit %common-os)
 (host-name "framework")
 
 (initrd microcode-initrd)
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

 (services
  (cons*
   (service zram-device-service-type
            (zram-device-configuration
             (size "24G")
             (priority 0)))
   (service tlp-service-type
            (tlp-configuration
             (cpu-scaling-governor-on-ac (list "balanced" "performance"))
             (cpu-boost-on-ac? #f)
             (cpu-scaling-governor-on-bat (list "low-power"))
             (cpu-boost-on-bat? #f)
             (sched-powersave-on-bat? #t)))
   (service mullvad-daemon-service-type)
   %common-services)))