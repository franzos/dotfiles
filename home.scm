;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

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
             (gnu home services gnupg)
             (gnu home services shells)
             (gnu home services sound)
             (gnu home services desktop)
             (gnu home services syncthing))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 (packages
  (specifications->packages
   (list "alacritty"                ;; terminal
         "neovim"                   ;; editor
         "qalculate-gtk"            ;; calculator
         "mousepad"                 ;; text editor
         "logseq"
         "transmission"
         "vscode"
         ;; "signal-desktop"
         ;; "vscodium"
         "syncthing"
         ;; failing build
         ;; "trash-cli"
         "gsettings-desktop-schemas"
         "gnome-themes-extra"
         "file"	                    ;; file type guesser
         "librewolf"
         "glib:bin"
         "evince"
         "calibre"
         "gpgme"
         "keychain"
         "icedove-wayland"
         "obs-pipewire-audio-capture"
         ;; "xdg-desktop-portal"
         "xdg-desktop-portal-wlr"
         ;; without this, the file dialog is properly styled
         ;; "xdg-desktop-portal-gtk"
         "obs-wlrobs"
         "obs"
         "wl-clipboard"
         "clipman"
         "grim"                      ;; screenshot editing
         ;; should be replaced by rofi
	       "dmenu"
	       "j4-dmenu-desktop"          ;; flatpak integration
         ;; dmenu replacement
         "rofi-wayland"
         "pinentry-rofi"
	       "recoll"
         "qemu"
         "wireshark"
         "kleopatra"                 ;; pgp
         "docker"
         "quassel"                   ;; irc
         "linphone-desktop"          ;; voip
         "libreoffice"
         "flatpak"
         "nheko"
         "monero"
         "tomb"                      ;; secrets manager
         "steghide"
         "keepassxc"                 ;; password manager
         "vlc"
         "guvcview"
         "gimp"
         "mpv"
         "yt-dlp"
         "seahorse"
         "inkscape"
         "emacs"
         "docker-cli"
         "docker-compose@2"
         "git"
         "tigervnc-client"
         "recutils"
         "curl"
         "wget"
         "bind:utils"
         "rsync"
         "glances"
         "python"
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
         "mit-scheme"
         "qtwayland"
         "swappy"
         "wf-recorder"
         "playerctl"
         "keychain"
         "dconf"
         "evince"
         "libgsf"
         "font-google-material-design-icons"
         "libreoffice"
         "openssh-sans-x"
         "swayidle"
         "swaylock"
         "swaybg"
         "wlsunset"                  ;; Night light
         "bemenu"
         "blueman"
         ;; "j4-dmenu-desktop"          ;; flatpak in bemenu
         "waybar"                    ;; status bar
         "dunst"                     ;; notifications
         "pinentry"                  ;; prompt for php, ssh, ...
         "pavucontrol"               ;; audio control
         "pamixer"                   ;; keyboard audio volumne
         "brightnessctl"             ;; keyboard display brightness
         "yaru-theme"
         "hicolor-icon-theme"
         "papirus-icon-theme"
         "gnome-themes-extra"
         "adwaita-icon-theme"
         "font-awesome"
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
         "mpv" 				               ;; video player
         "kanshi" 			             ;; auto display handling
         "throttled"
         "xdg-utils"
   )))
 
 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (list (service home-bash-service-type
                 (home-bash-configuration
                  (aliases '(("grep" . "grep --color=auto") ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")))
                  (bashrc (list (local-file
                                 "/home/franz/src/guix-config/.bashrc"
                                 "bashrc")))
                  (bash-profile (list (local-file
                                       "/home/franz/src/guix-config/.bash_profile"
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
                   ("gtk-3.0/settings.ini" ,(local-file
                                             "gtk-3.0-settings.ini"))
                   ("kanshi/config" ,(local-file "kanshi"))
                   ("xfce4/xfconf/xfce-perchannel-xml/thunar.xml" ,(local-file
                                                                    "thunar.xml"))
                   ("nvim/init.lua" ,(local-file "nvim/init.lua"))
                   ("nvim/lua/plugins.lua" ,(local-file
                                             "nvim/lua/plugins.lua"))))
        (simple-service 'env-vars home-environment-variables-service-type
                        `(("QT_QPA_PLATFORM" . "wayland;xcb")
                          ("GTK_THEME" . "Yaru-dark")
                          ("SDL_VIDEODRIVER" . "wayland")
                          ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")
                          ("XDG_CURRENT_DESKTOP" . "sway")
                          ("XDG_SESSION_DESKTOP" . "sway")
                          ("XDG_SESSION_TYPE" . "wayland")))
        (simple-service 'variant-packages-service
         home-channels-service-type
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
         %default-channels))
        (service home-syncthing-service-type)
        (service home-dbus-service-type)
        (service home-pipewire-service-type)
        (service home-openssh-service-type)
        (service home-ssh-agent-service-type)
        (service home-gpg-agent-service-type
                 (home-gpg-agent-configuration
                  (pinentry-program
                    (file-append
                     pinentry "/bin/pinentry")))))))
                    
        ; %base-home-services)))
