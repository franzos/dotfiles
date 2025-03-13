(define-module (common)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system setuid)
  #:use-module (gnu services linux)
  #:use-module (gnu services base)
  #:use-module (gnu services mcron)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services dbus)
  #:use-module (gnu services xorg)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services desktop)           ;; gvfs-service-type
  #:use-module (gnu services docker)
  #:use-module (gnu services pm)
  #:use-module (gnu services web)
  #:use-module (gnu services security-token)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services networking)
  #:use-module (gnu services mail)
  #:use-module (gnu services admin)

  #:use-module (gnu packages emacs)
  #:use-module (gnu packages docker)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages security-token)

  #:use-module (nongnu packages firmware)       ;; fwupd-nonfree

  #:use-module (px system panther)
  #:use-module (px packages throttled)
  #:use-module (px packages security-token)     ;; acsccid

  #:export (%common-os %common-services))

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

    # syncthing
    tcp dport 22000 accept

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

(define %common-services
 (append
  (list
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

   (service thermald-service-type))
  %panther-desktop-services-minimal))

(define %common-os
 (operating-system
  (inherit %panther-os)
  (host-name "panther")
  (timezone "Europe/Lisbon")
  (locale "en_US.utf8")
  
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
  
  (packages 
   (cons* emacs
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
   %common-services)))