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
             (gnu home services syncthing)
             (px home services darkman)
             (px home services foot)
             (px packages audio))

;; Theme configuration
;; available: ibm-5151, macos-classic
(define current-theme "ibm-5151")

(define mcron-job-pimsync
  #~(job '(next-hour '(0 3 6 9 12 15 18 21))
         "pimsync sync"
         #:user "franz"))

(home-environment
 (packages
  (specifications->packages
   (list
         ;; GUI Apps
         "gimp"
         "keepassxc"                 ;; password manager
         "vlc"
         "inkscape"
         "wireshark"
         "recoll"
         "calibre"                  ;; E-Books
         "qalculate-gtk"            ;; calculator
         "mousepad"                 ;; text editor
         "logseq"
         "google-chrome-stable"
         "librewolf"
         "libreoffice"
         "evince"                    ;; PDF Reader
         "kleopatra"                 ;; pgp
         "mpv"
         "tidal-hifi"
         "mullvad-vpn-desktop"
         "slack-desktop"
         "qimgv"                     ;; image viewer

         ;; Sound
         "pipewire"
         "wireplumber"
         "noise-suppression-for-voice"

         ;; Fonts
         "font-openmoji"
         "font-google-noto"
         "font-google-noto-emoji"
         "unicode-emoji"
         "font-ibm-plex"
         "font-awesome"
         "font-linuxlibertine"

         ;; Desktop
         "niri"
         "xwayland-satellite"          ;; X11 support for niri
         "xdg-desktop-portal-gnome"
         "xdg-desktop-portal-gtk"
         "swayidle"
         "swaylock"
         "swaybg"
         "keychain"
         "wlsunset"                  ;; Night light
         "bemenu"
         "slurp"                     ;; screen area selection
         "blueman"
         "waybar"                    ;; status bar
         "dunst"                     ;; notifications
         "pinentry-qt"               ;; prompt for pgp, ssh, ...
         "pavucontrol"               ;; audio control
         "pamixer"                   ;; keyboard audio volumne
         "brightnessctl"             ;; keyboard display brightness
         "lxqt-policykit"
         "wl-clipboard"
         "clipman"
         "grim"                      ;; screenshot editing
	     "dmenu"
	     "j4-dmenu-desktop"          ;; flatpak integration
		 "swappy"                    ;; Screenshot editing
         "playerctl"                 ;; media control
         "kanshi" 			         ;; auto display handling
         "xdg-utils"                 ;; xdg-open

         ;; Themes
         "yaru-theme"
         "hicolor-icon-theme"
         "papirus-icon-theme"
         "adwaita-icon-theme"
         "gnome-themes-extra"

         ;; Dictionary
         "aspell"
         "hunspell-dict-en"
         "hunspell-dict-en-us"
         "aspell-dict-en"
         "aspell-dict-de"
         "aspell-dict-uk"
         "shellcheck"

         ;; Supporting
         "libusb"
         "emacs"
         "emacs-geiser"
         "emacs-geiser-guile"
         "bind:utils"
         "python"
         "glib:bin"
         "gpgme"
         "gsettings-desktop-schemas"
         "qtwayland"
         "dconf"
         "libgsf"

		 ;; CLI
         "curlie"                    ;; like curl
         "tealdeer"                  ;; tdlr
         "jq"                        ;; json processor (darkman vscode)
         "bmon"
         "htop"
         "unzip"
         "git"
         "jj-vcs"
         "rsync"
         "ripgrep"                   ;; better grep
         "broot"                     ;; file explorer
         "glances"                   ;; system monitor
         "restic"                    ;; backup
         "nmap"
         "yt-dlp"
         "wireguard-tools"
         "zip"
         "lsof"
         "net-tools"
         "unrar"
         "recutils"
         "curl"
         "wget"
         "qemu"
         "flatpak"
         "tomb"                      ;; secrets manager
         "syncthing"
         "trash-cli"
         "qpwgraph"
         "sed"
         "openssh-sans-x"
         "newsboat"                  ;; RSS reader
         "file"	                    ;; file type guesser
         "neovim"                   ;; editor
         "transmission"
         "sniffnet"
         "witr"

         ;; Thunar
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

         ;; Email and Calendar
         "aerc"
         "w3m"
         "isync"
         "msmtp"
         "libsecret"
         "pimsync"
         "khal"
         ;; "himalaya"               ;; Email

         ;; Fan Control
         ;; "fw-fanctrl"             ;; Framework fan control

         "darkman"
         "bluetuith"                 ;; Bluetooth TUI
         "direnv"

         ;;Zed
         "zed"
         "wakatime-cli"
         "wakatime-ls"
         "package-version-server"
   )))

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (append (list (service home-bash-service-type
                 (home-bash-configuration
                  (aliases '(("grep" . "grep --color=auto")
                             ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")
                             ("ccs" . "guix shell node pnpm gh -- pnpm dlx @anthropic-ai/claude-code")
                             ("ccss" . "guix shell node pnpm gh -- pnpm dlx @anthropic-ai/claude-code --dangerously-skip-permissions")
                             ("pms" . "podman system service --time=0 unix:///tmp/podman.sock")))
                  (bashrc (list (local-file
                                 ".bashrc"
                                 "bashrc")))
                  (bash-profile (list (local-file
                                       ".bash_profile"
                                       "bash_profile")))))
        (service home-files-service-type
                 `((".gitconfig" ,(local-file "gitconfig"))
                   (".gtkrc-2.0" ,(local-file "gtkrc-2.0"))
                   ;; Bluetooth profile management scripts
                   (".local/bin/bt-toggle-profile" ,(local-file "bt-toggle-profile" #:recursive? #t))
                   (".local/bin/bt-profile-status" ,(local-file "bt-profile-status" #:recursive? #t))
                   (".local/share/applications/lock.desktop" ,(local-file
                                                               "apps/lock.desktop"))
                   (".local/share/applications/vscode.desktop" ,(local-file
                                                                 "apps/vscode.desktop"))
                   (".local/share/applications/vscode_go.desktop" ,(local-file
                                                                    "apps/vscode_go.desktop"))
                   (".local/share/applications/vscode_rust.desktop" ,(local-file
                                                                      "apps/vscode_rust.desktop"))
                   (".local/share/applications/vscode_cpp.desktop" ,(local-file
                                                                     "apps/vscode_cpp.desktop"))
                   (".local/share/applications/google-chrome-hw.desktop" ,(local-file
                                                                           "apps/google-chrome-hw.desktop"))
                   (".local/share/applications/mullvad-vpn.desktop" ,(local-file
                                                                      "apps/mullvad-vpn.desktop"))
                   (".local/share/applications/zed.desktop" ,(local-file
                                                                  "apps/zed.desktop"))
                   ;; GTK-3 theme templates for darkman
                   (".local/share/gtk-themes/settings-dark.ini" ,(local-file (string-append "themes/" current-theme "/gtk-settings-dark.ini")))
                   (".local/share/gtk-themes/settings-light.ini" ,(local-file (string-append "themes/" current-theme "/gtk-settings-light.ini")))
                   ;; Darkman theme switching scripts
                   (".local/share/dark-mode.d/gtk" ,(local-file (string-append "themes/" current-theme "/gtk-dark") #:recursive? #t))
                   (".local/share/dark-mode.d/foot" ,(local-file (string-append "themes/" current-theme "/foot-dark") #:recursive? #t))
                   (".local/share/dark-mode.d/dunst" ,(local-file (string-append "themes/" current-theme "/dunst-dark") #:recursive? #t))
                   (".local/share/dark-mode.d/vscode" ,(local-file (string-append "themes/" current-theme "/vscode-dark") #:recursive? #t))
                   (".local/share/dark-mode.d/waybar" ,(local-file (string-append "themes/" current-theme "/waybar-dark") #:recursive? #t))
                   (".local/share/dark-mode.d/niri" ,(local-file (string-append "themes/" current-theme "/niri-dark") #:recursive? #t))
                   (".local/share/light-mode.d/gtk" ,(local-file (string-append "themes/" current-theme "/gtk-light") #:recursive? #t))
                   (".local/share/light-mode.d/foot" ,(local-file (string-append "themes/" current-theme "/foot-light") #:recursive? #t))
                   (".local/share/light-mode.d/dunst" ,(local-file (string-append "themes/" current-theme "/dunst-light") #:recursive? #t))
                   (".local/share/light-mode.d/vscode" ,(local-file (string-append "themes/" current-theme "/vscode-light") #:recursive? #t))
                   (".local/share/light-mode.d/waybar" ,(local-file (string-append "themes/" current-theme "/waybar-light") #:recursive? #t))
                   (".local/share/light-mode.d/niri" ,(local-file (string-append "themes/" current-theme "/niri-light") #:recursive? #t))
                   ;; Waybar theme files for darkman switching
                   (".local/share/waybar-themes/style-light.css" ,(local-file (string-append "themes/" current-theme "/waybar-light.css")))
                   (".local/share/waybar-themes/style-dark.css" ,(local-file (string-append "themes/" current-theme "/waybar-dark.css")))))
        (service home-xdg-configuration-files-service-type
                 `(("niri/config.kdl" ,(local-file "niri.kdl"))
                   ("waybar/config" ,(local-file "waybar"))
                   ("waybar/config-niri" ,(local-file "waybar-niri"))
                   ;; waybar/style.css managed by darkman scripts, not guix home
                   ("kanshi/config" ,(local-file "kanshi"))
                   ("xfce4/xfconf/xfce-perchannel-xml/thunar.xml" ,(local-file "thunar.xml"))
                   ("nvim/init.lua" ,(local-file "nvim/init.lua"))
                   ("nvim/lua/plugins.lua" ,(local-file "nvim/lua/plugins.lua"))
                   ("nvim/lua/core/options.lua" ,(local-file "nvim/lua/core/options.lua"))
                   ("nvim/lua/core/keymaps.lua" ,(local-file "nvim/lua/core/keymaps.lua"))
                   ("xdg-desktop-portal/portals.conf" ,(local-file "portals.conf"))
                   ("dunst/dunstrc" ,(local-file "dunstrc"))
                   ("foot/foot.ini" ,(local-file (string-append "themes/" current-theme "/foot.ini")))
                   ("swaylock/config" ,(local-file "swaylock"))
                   ;; WirePlumber Bluetooth configuration for A2DP preference (WirePlumber 0.5+)
                   ("wireplumber/bluetooth.lua.d/51-bluez-config.lua" ,(local-file "wireplumber-bluetooth.lua"))
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
                          ("SDL_VIDEODRIVER" . "wayland")
                          ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")
                          ("XDG_CURRENT_DESKTOP" . "niri")
                          ("XDG_SESSION_DESKTOP" . "niri")
                          ("XDG_SESSION_TYPE" . "wayland")
                          ;; Performance environment variables for Wayland
                          ("ELECTRON_OZONE_PLATFORM_HINT" . "wayland")
                          ("MOZ_ENABLE_WAYLAND" . "1")
                          ("NIXOS_OZONE_WL" . "1")
                          ("GDK_BACKEND" . "wayland")
                          ("CLUTTER_BACKEND" . "wayland")
                          ;; Qt theme integration (reads color-scheme from gsettings)
                          ("QT_QPA_PLATFORMTHEME" . "gtk3")
                          ;; Hardware acceleration
                          ("LIBVA_DRIVER_NAME" . "radeonsi")
                          ("ANGLE_DEFAULT_PLATFORM" . "vulkan")
                          ;; Cursor theme
                          ("XCURSOR_THEME" . "Adwaita")
                          ("XCURSOR_SIZE" . "24")
                          ;; podman system service --time=0 unix:///run/user/$(id -u)/podman/podman.sock
                          ("DOCKER_HOST" . "unix:///run/user/$(id -u)/podman/podman.sock")
                          ;; Unknown terminal: foot
                          ("TERM" . "xterm")
                          ;; Disable version enforcement
                          ("COREPACK_ENABLE_STRICT" . "0")
                          ("COREPACK_ENABLE_PROJECT_SPEC" . "0")
                          ;; Do Not Track: ex. Turborepo
                          ("DO_NOT_TRACK" . "1")
                          ("NEXT_TELEMETRY_DISABLED" . "1")
                          ;; GPG TTY for pinentry
                          ("GPG_TTY" . "$(tty)")))
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
        (service home-pipewire-service-type
                 (home-pipewire-configuration
                  (pipewire pipewire)
                  (wireplumber wireplumber)))
        ;; I want to manage SSH keys manually for now
        ;; (service home-openssh-service-type)
        (service home-ssh-agent-service-type)
        (service home-gpg-agent-service-type
                 (home-gpg-agent-configuration
                  (pinentry-program
                    (file-append
                     pinentry-qt "/bin/pinentry-qt"))))
        (service home-darkman-service-type
                 (home-darkman-configuration
                  (latitude 38.7)       ;; Lisbon coordinates from wlsunset
                  (longitude -9.2)
                  (use-geoclue? #f))))  ;; Manual coords for privacy

        %base-home-services)))
