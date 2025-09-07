(define-module (common)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system setuid)
  #:use-module (gnu system accounts)           ;; for 'subid-range'
  #:use-module (gnu services linux)
  #:use-module (gnu services base)
  #:use-module (gnu services mcron)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services dbus)
  #:use-module (gnu services xorg)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services desktop)           ;; gvfs-service-type
  #:use-module (gnu services containers)
  #:use-module (gnu services pm)
  #:use-module (gnu services web)
  #:use-module (gnu services security-token)
  #:use-module (gnu services networking)
  #:use-module (gnu services mail)
  #:use-module (gnu services admin)

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
  #:use-module (gnu packages security-token)

  #:use-module (nongnu packages firmware)       ;; fwupd-nonfree

  #:use-module (px system panther)
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

    # Allow established/related connections
    ct state {established, related} accept
    
    # Allow all traffic from Docker networks
    iifname \"docker*\" accept
    iifname \"br-*\" accept
    
    # Allow all return traffic to Docker networks
    oifname \"docker*\" accept
    oifname \"br-*\" accept
  }
  chain output {
    type filter hook output priority 0; policy accept;
  }
}

# NAT for Docker
table ip nat {
  chain postrouting {
    type nat hook postrouting priority 100; policy accept;
    
    # Masquerade Docker subnets
    ip saddr 172.17.0.0/16 oifname != \"docker0\" counter masquerade
    ip saddr 172.18.0.0/16 oifname != \"br-*\" counter masquerade
  }
}
"))

(define %iptables-ipv4-rules
  (plain-file "iptables.rules" "*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-port-unreachable
COMMIT
"))

(define %iptables-ipv6-rules
  (plain-file "ip6tables.rules" "*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p tcp --dport 22000 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp6-port-unreachable
COMMIT
"))

(define %common-services
 (append
  (list
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
                        (channel
                         (name 'small-guix)
                         (url "https://gitlab.com/orang3/small-guix")
                         (introduction
                          (make-channel-introduction
                           "f260da13666cd41ae3202270784e61e062a3999c"
                           (openpgp-fingerprint
                            "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2"))))
                        %default-channels))))
   
   (service dovecot-service-type
            (dovecot-configuration
             (mail-location "maildir:~/.mail")))
   
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

   (service bluetooth-service-type
            (bluetooth-configuration 
             (auto-enable? #t)))

   (service thermald-service-type)

   (service iptables-service-type
         (iptables-configuration
          (ipv4-rules %iptables-ipv4-rules)
          (ipv6-rules %iptables-ipv6-rules)))

   (service rootless-podman-service-type
            (rootless-podman-configuration
             (subgids
              (list (subid-range (name "franz"))))
             (subuids
              (list (subid-range (name "franz")))))))

  (modify-services %panther-desktop-services-minimal
    ;; https://stackoverflow.com/questions/76830848/redis-warning-memory-overcommit-must-be-enabled
    (sysctl-service-type config => (sysctl-configuration
                                    (inherit config)
                                    (settings '(("vm.overcommit_memory" . "1"))))))))

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
                             "cgroup"
                             "kvm"
                             "audio"
                             "video"
                             "plugdev"
                             "input"))
     (home-directory "/home/franz"))
    %base-user-accounts))
  
  (packages 
   (cons* emacs
    podman
    podman-compose
    buildah
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
