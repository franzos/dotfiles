(define-module (framework)
  #:use-module (common)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (gnu services xorg)
  #:use-module (gnu services pm)              ;; power-profiles-daemon-service-type
  #:use-module (gnu services linux)           ;; zram-device-service-type
  #:use-module (gnu services base)            ;; udev-service-type
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
  (cons* "amd_pstate=active"                      ;; AMD Ryzen EPP power management
         "pcie_aspm.policy=powersupersave"        ;; Aggressive PCIe power saving
         "amdgpu.ppfeaturemask=0xffffffff"        ;; Enable all GPU power features
         "amdgpu.abmlevel=3"                      ;; Adaptive backlight management
         "nmi_watchdog=0"                         ;; Disable NMI watchdog for power saving
         "modprobe.blacklist=hid_sensor_hub"
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
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"
                                     ;; YubiKey FIDO+CCID
                                     "ACTION==\"add\", SUBSYSTEM==\"usb\", "
                                     "ATTR{idVendor}==\"1050\", "  ;; Yubico
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"))))

   ;; Enable PCI Runtime PM for NVMe SSD
   (simple-service 'nvme-runtime-pm udev-service-type
                   (list (udev-rule "90-nvme-power.rules"
                                    (string-append
                                     "ACTION==\"add\", SUBSYSTEM==\"pci\", "
                                     "ATTR{vendor}==\"0x144d\", "  ;; Samsung
                                     "ATTR{class}==\"0x010802\", "  ;; NVMe controller
                                     "TEST==\"power/control\", ATTR{power/control}=\"auto\"\n"))))

   (service mullvad-daemon-service-type)
   %common-services)))