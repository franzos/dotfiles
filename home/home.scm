(use-modules (gnu home)
             (gnu packages)
             (gnu packages gnupg)
             (gnu services)
             (guix gexp)
             (guix profiles)
             (guix channels)
             (gnu home services)
             (gnu home services guix)
             (gnu home services ssh)
             (gnu home services mail)
             (gnu home services mcron)
             (gnu home services gnupg)
             (gnu home services shells)
             (gnu home services sound)
             (gnu home services desktop)
             (gnu home services syncthing))

(define mcron-job-pimsync
  #~(job '(next-minute '(0 10 20 30 40 50))
         "pimsync sync"
         #:user "franz"))

(home-environment
 (packages
  (specifications->packages
   (list "neovim"                   ;; editor
         "qalculate-gtk"            ;; calculator
         "mousepad"                 ;; text editor
         "logseq"
         "transmission"
         "vscode"
         ;; "signal-desktop"
         "syncthing"
         "trash-cli"
         "gsettings-desktop-schemas"
         "gnome-themes-extra"
         "file"	                    ;; file type guesser
         "google-chrome-stable"
         "librewolf"
         "glib:bin"
         "calibre"                  ;; E-Books
         "gpgme"
        ;  "icedove-wayland"
        ;  "obs-pipewire-audio-capture"
         "xdg-desktop-portal-gtk"
         "xdg-desktop-portal-wlr"
        ;  "obs-wlrobs"
        ;  "obs"
         "wl-clipboard"
         "clipman"
         "grim"                      ;; screenshot editing
         ;; should be replaced by rofi
	       "dmenu"
	       "j4-dmenu-desktop"          ;; flatpak integration
         ;; dmenu replacement
        ;  "rofi-wayland"
        ;  "pinentry-rofi"
	       "recoll"
         "qemu"
         "wireshark"
        ;  "kleopatra"                 ;; pgp
        ;  "quassel"                   ;; irc
        ;  "linphone-desktop"          ;; voip
         "flatpak"
        ;  "nheko"
        ;  "monero"
         "tomb"                      ;; secrets manager
         "steghide"
         "keepassxc"                 ;; password manager
         "vlc"
         "gimp"
         "yt-dlp"
        ;  "seahorse"
         "inkscape"
         "emacs"
         "git"
         "recutils"
         "curl"
         "wget"
         "bind:utils"
         "rsync"
         "ripgrep"                   ;; better grep
         "broot"                     ;; file explorer
         "glances"                   ;; system monitor
         "python"
        ;  "scribus"                   ;; inDesign alternative
        ;  "python:tk"                 ;; for Scribus
         "nmap"
         "shellcheck"
         "emacs-geiser-guile"
         "bmon"
         "htop"
         "unzip"
         "aspell"
         "wireplumber"
         "wireguard-tools"
         "zip"
         "lsof"
         "font-linuxlibertine"
         "net-tools"
         "unrar"
         "libusb"
         "emacs-geiser"
         "font-openmoji"
         "font-google-noto"
         "font-google-noto-emoji"
         "restic"                    ;; backup
         "font-ibm-plex"
         "hunspell-dict-en"
         "hunspell-dict-en-us"
         "aspell-dict-en"
         "aspell-dict-de"
         "unicode-emoji"
         "aspell-dict-uk"
         "qpwgraph"
         "sed"
        ;  "mit-scheme"
         "qtwayland"
         "swappy"
        ;  "wf-recorder"             ;; Screen Recording
        ;  "playerctl"
         "keychain"
         "dconf"
         "libgsf"
         "libreoffice"
         "evince"                    ;; PDF Reader
         "mpv"
         "openssh-sans-x"
         "newsboat"
         "mullvad-vpn-desktop"
         "sway"
         "swayidle"
         "swaylock"
         "swaybg"
         "wlsunset"                  ;; Night light
         "bemenu"
         "slurp"                     ;; screen area selection
         "blueman"
         ;; "j4-dmenu-desktop"          ;; flatpak in bemenu
         "waybar"                    ;; status bar
         "dunst"                     ;; notifications
         "pinentry"                  ;; prompt for pgp, ssh, ...
         "pavucontrol"               ;; audio control
         "pamixer"                   ;; keyboard audio volumne
         "brightnessctl"             ;; keyboard display brightness
         "yaru-theme"
         "hicolor-icon-theme"
         "papirus-icon-theme"
         "adwaita-icon-theme"
         "font-awesome"

         "curlie"                    ;; like curl
         ;; "just"
         ;; "himalaya"               ;; not packaged
         "tealdeer"                  ;; tdlr

         ;; thunar
         "thunar"                    ;; file manager
         "thunar-vcs-plugin"         ;; git integration
         "thunar-archive-plugin"     ;; archive integration
         "xarchiver"                 ;; archive manager
         "thunar-media-tags-plugin"  ;; media tags
         "thunar-volman"             ;; removable media manager
         "xfconf"                    ;; persist thunar changes
         "catfish"                   ;; file search
         "ffmpegthumbnailer"
         "webp-pixbuf-loader"        ;; thunar thumbnails
         "tumbler"                   ;; thunar thumbnails dbus
         "qimgv"                     ;; image viewer
         "kanshi" 			             ;; auto display handling
         "xdg-utils"                 ;; xdg-open
         ;; Emailing
         "aerc"
         "w3m"
         "isync"
         "msmtp"
         "libsecret"
         "pimsync"
         "khal"
         ;; Fan Control
         "fw-fanctrl"
         ;; Polkit
         "lxqt-policykit"
   )))
 
 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (append (list (service home-bash-service-type
                 (home-bash-configuration
                  (aliases '(("grep" . "grep --color=auto") 
                             ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")
                             ("ccs" . "guix shell node pnpm -- pnpm dlx @anthropic-ai/claude-code")
                             ("cc" . "pnpm dlx @anthropic-ai/claude-code")
                             ("pms" . "podman system service --time=0 unix:///tmp/podman.sock")))
                  (bashrc (list (local-file
                                 ".bashrc"
                                 "bashrc")))
                  (bash-profile (list (local-file
                                       ".bash_profile"
                                       "bash_profile")))))
        (service home-files-service-type
                 `((".gtkrc-2.0" ,(local-file "gtkrc-2.0"))
                   (".local/share/applications/vscode.desktop" ,(local-file
                                                                 "apps/vscode.desktop"))
                   (".local/share/applications/vscode_go.desktop" ,(local-file
                                                                    "apps/vscode_go.desktop"))
                   (".local/share/applications/vscode_rust.desktop" ,(local-file
                                                                      "apps/vscode_rust.desktop"))
                   (".local/share/applications/vscode_cpp.desktop" ,(local-file
                                                                     "apps/vscode_cpp.desktop"))))
        (service home-xdg-configuration-files-service-type
                 `(("sway/config" ,(local-file "sway"))
                   ("waybar/config" ,(local-file "waybar"))
                   ("gtk-3.0/settings.ini" ,(local-file "gtk-3.0-settings.ini"))
                   ("kanshi/config" ,(local-file "kanshi"))
                   ("xfce4/xfconf/xfce-perchannel-xml/thunar.xml" ,(local-file "thunar.xml"))
                   ("nvim/init.lua" ,(local-file "nvim/init.lua"))
                   ("nvim/lua/plugins.lua" ,(local-file "nvim/lua/plugins.lua"))
                   ("xdg-desktop-portal/portals.conf" ,(local-file "portals.conf"))
                   ("dunst/dunstrc" ,(local-file "dunstrc"))
                   ("swaylock/config" ,(local-file "swaylock"))
                   ;; broot
                   ("broot/conf.hjson" ,(local-file "broot/conf.hjson"))
                   ("broot/verbs.hjson" ,(local-file "broot/verbs.hjson"))
                   ("broot/skins/catppuccin-macchiato.hjson" ,(local-file "broot/skins/catppuccin-macchiato.hjson"))
                   ("broot/skins/catppuccin-mocha.hjson" ,(local-file "broot/skins/catppuccin-mocha.hjson"))
                   ("broot/skins/dark-blue.hjson" ,(local-file "broot/skins/dark-blue.hjson"))
                   ("broot/skins/dark-gruvbox.hjson" ,(local-file "broot/skins/dark-gruvbox.hjson"))
                   ("broot/skins/dark-orange.hjson" ,(local-file "broot/skins/dark-orange.hjson"))
                   ("broot/skins/native-16.hjson" ,(local-file "broot/skins/native-16.hjson"))
                   ("broot/skins/solarized-dark.hjson" ,(local-file "broot/skins/solarized-dark.hjson"))
                   ("broot/skins/solarized-light.hjson" ,(local-file "broot/skins/solarized-light.hjson"))
                   ("broot/skins/white.hjson" ,(local-file "broot/skins/white.hjson"))))
        (simple-service 'env-vars home-environment-variables-service-type
                        `(("QT_QPA_PLATFORM" . "wayland;xcb")
                          ("GTK_THEME" . "Yaru-dark")
                          ("SDL_VIDEODRIVER" . "wayland")
                          ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")
                          ("XDG_CURRENT_DESKTOP" . "sway")
                          ("XDG_SESSION_DESKTOP" . "sway")
                          ("XDG_SESSION_TYPE" . "wayland")
                          ;; Performance environment variables for Wayland
                          ("ELECTRON_OZONE_PLATFORM_HINT" . "wayland")
                          ("MOZ_ENABLE_WAYLAND" . "1")
                          ("NIXOS_OZONE_WL" . "1")
                          ("GDK_BACKEND" . "wayland")
                          ("CLUTTER_BACKEND" . "wayland")
                          ;; Cursor theme
                          ("XCURSOR_THEME" . "Adwaita")
                          ("XCURSOR_SIZE" . "24")
                          ;; podman system service --time=0 unix:///run/user/$(id -u)/podman/podman.sock
                          ("DOCKER_HOST" . "unix:///run/user/$(id -u)/podman/podman.sock")
                          ;; Unknown terminal: foot
                          ("TERM" . "xterm")))
        (simple-service 'variant-packages-service
         home-channels-service-type
          (cons* 
           (channel
            (name 'pantherx)
            (url "https://channels.pantherx.org/git/panther.git")
            (branch "master")
            (introduction
             (make-channel-introduction
              "54b4056ac571611892c743b65f4c47dc298c49da"
              (openpgp-fingerprint
               "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
           (channel
            (name 'small-guix)
            (url "https://codeberg.org/fishinthecalculator/small-guix.git")
            (introduction
             (make-channel-introduction
              "f260da13666cd41ae3202270784e61e062a3999c"
              (openpgp-fingerprint
               "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2"))))
           %default-channels))
        (service home-msmtp-service-type
         (home-msmtp-configuration
          (accounts
           (list
            (msmtp-account
             (name "gofranz.com")
             (configuration
              (msmtp-configuration
               (auth? #t)
               (tls? #t)
               (tls-starttls? #f)
               (host "smtp.fastmail.com")
               (port 465)
               (user "mail@gofranz.com")
               (from "mail@gofranz.com")
               (password-eval "secret-tool lookup Title smtp.fastmail.com_gofranz.com"))))))))
        (service home-mcron-service-type
         (home-mcron-configuration
          (jobs (list
                 mcron-job-pimsync))))
        (service home-syncthing-service-type)
        (service home-dbus-service-type)
        (service home-pipewire-service-type)
        ;; I want to manage SSH keys manually for now
        ;; (service home-openssh-service-type)
        (service home-ssh-agent-service-type)
        (service home-gpg-agent-service-type
                 (home-gpg-agent-configuration
                  (pinentry-program
                    (file-append
                     pinentry "/bin/pinentry")))))
                    
        %base-home-services)))
