(use-modules (gnu home)
             (gnu packages)
             (gnu packages bash)
             (gnu packages gnome)
             (gnu packages gnupg)
             (gnu packages linux)
             (gnu services)
             (gnu services shepherd)
             (guix gexp)
             (guix profiles)
             (guix channels)
             (guix packages)
             (guix build-system copy)
             ((guix licenses) #:prefix license:)
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
             (gnu home services shepherd)
             (px home services foot)
             (px packages audio)
             (px packages wm)
             (px packages desktop-tools))

;; Theme configuration
;; available: ibm-5151, macos-classic, fleet
(define current-theme "macos-classic")

(define mcron-job-pimsync
  #~(job '(next-hour '(0 3 6 9 12 15 18 21))
         "pimsync sync"
         #:user "franz"))

;; Darkman theme switching scripts - installed to profile/share/ for darkman 2.3+
(define darkman-scripts
  (package
    (name "darkman-scripts")
    (version "1.0")
    (source (local-file (string-append "themes/" current-theme) #:recursive? #t))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("foot-dark" "share/dark-mode.d/foot")
         ("foot-light" "share/light-mode.d/foot")
         ("gtk-dark" "share/dark-mode.d/gtk")
         ("gtk-light" "share/light-mode.d/gtk")
         ("dunst-dark" "share/dark-mode.d/dunst")
         ("dunst-light" "share/light-mode.d/dunst")
         ("vscode-dark" "share/dark-mode.d/vscode")
         ("vscode-light" "share/light-mode.d/vscode")
         ("waybar-dark" "share/dark-mode.d/waybar")
         ("waybar-light" "share/light-mode.d/waybar")
         ("niri-dark" "share/dark-mode.d/niri")
         ("niri-light" "share/light-mode.d/niri"))))
    (home-page "")
    (synopsis "Darkman theme switching scripts")
    (description "Scripts for automatic dark/light theme switching with darkman.")
    (license license:gpl3+)))

(home-environment
 (packages
  (cons* niri-shm                    ;; Patched niri with SHM screencast support (PR #1791)
         darkman-scripts             ;; Theme switching scripts for darkman
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
         "papers"                    ;; PDF Reader
         "kleopatra"                 ;; pgp
         "mpv"
         "tidal-hifi"
         "mullvad-vpn-desktop"
         "slack-desktop"
         ;; "qimgv"                  ;; image viewer
         "oculante"                  ;; image viewer
         "dbeaver"

         ;; Sound
         "pipewire"
         "wireplumber"
         ;; Framework: https://github.com/FrameworkComputer/linux-docs/blob/main/easy-effects/fw13-easy-effects.json OR https://github.com/cab404/framework-dsp
         ;; Thinkpad: https://github.com/JackHack96/EasyEffects-Presets "Laptop"
         "easyeffects"
         "easyeffects-presets-framework"
         "deepfilternet-ladspa"

         ;; Fonts
         "font-openmoji"
         "font-google-noto"
         "font-google-noto-emoji"
         "unicode-emoji"
         "font-ibm-plex"
         "font-awesome"
         "font-linuxlibertine"

         ;; Desktop
         "xwayland-satellite"        ;; X11 support for niri
         "xdg-desktop-portal-gnome"
         "xdg-desktop-portal-gtk"
         "wayland-protocols"         ;; screen sharing (Google Meet)
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
         ;; rquickshare

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
         "gnupg"
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
         "git:send-email"
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
         ;; "flatpak"
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
         "keifu"
         "inotify-tools"             ;; file access monitoring

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
         "claude-code"
   ))))

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (append (list (service home-bash-service-type
                 (home-bash-configuration
                  (aliases '(("grep" . "grep --color=auto")
                             ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")
                             ("ccs" . "guix shell node pnpm gh claude-code -- claude")
                             ("ccss" . "guix shell node pnpm claude-code -- claude --dangerously-skip-permissions")
                             ("ccssj" . "guix shell --container --expose=$HOME/.gitconfig=$HOME/.gitconfig --expose=$HOME/.config/gh=$HOME/.config/gh --share=$HOME/.claude=$HOME/.claude --share=$HOME/.claude.json=$HOME/.claude.json --share=$HOME/.config/claude=$HOME/.config/claude --share=$HOME/.cache/pnpm=$HOME/.cache/pnpm --share=$HOME/.local/share/pnpm=$HOME/.local/share/pnpm --expose=$XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR --preserve='^DBUS_SESSION_BUS_ADDRESS$' --preserve='^COLORTERM$' --share=$PWD=$PWD --network coreutils bash grep sed gawk git node pnpm gh dunst claude-code nss-certs -- claude --dangerously-skip-permissions")
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
                   (".local/share/applications/oculante.desktop" ,(local-file
                                                                   "apps/oculante.desktop"))
                   ;; GTK-3 theme templates for darkman
                   (".local/share/gtk-themes/settings-dark.ini" ,(local-file (string-append "themes/" current-theme "/gtk-settings-dark.ini")))
                   (".local/share/gtk-themes/settings-light.ini" ,(local-file (string-append "themes/" current-theme "/gtk-settings-light.ini")))
                   ;; Waybar theme files for darkman switching (used by scripts)
                   (".local/share/waybar-themes/style-light.css" ,(local-file (string-append "themes/" current-theme "/waybar-light.css")))
                   (".local/share/waybar-themes/style-dark.css" ,(local-file (string-append "themes/" current-theme "/waybar-dark.css")))))
        (service home-xdg-configuration-files-service-type
                 `(("niri/config.kdl" ,(local-file "niri.kdl"))
                   ("niri/colors.kdl" ,(local-file (string-append "themes/" current-theme "/niri-colors.kdl")))
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
                          ;; ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")
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
                          ("GPG_TTY" . "$(tty)")
                          ;; Claude Code thinking budget
                          ("MAX_THINKING_TOKENS" . "63999")))
        (simple-service 'variant-packages-service
         home-channels-service-type
          (cons*
           (channel
            (name 'pantherx)
            (url "https://codeberg.org/gofranz/panther.git")
            (branch "master")
            (introduction
             (make-channel-introduction
              "54b4056ac571611892c743b65f4c47dc298c49da"
              (openpgp-fingerprint
               "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
           (channel
            (name 'small-guix)
            (url "https://codeberg.org/fishinthecalculator/small-guix.git")
            (branch "main")
            (introduction
             (make-channel-introduction
              "f260da13666cd41ae3202270784e61e062a3999c"
              (openpgp-fingerprint
               "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2"))))
           (channel
            (name 'guix-android)
            (url "https://framagit.org/tyreunom/guix-android.git")
            (introduction
             (make-channel-introduction
              "d031d039b1e5473b030fa0f272f693b469d0ac0e"
              (openpgp-fingerprint
               "1EFB 0909 1F17 D28C CBF9  B13A 53D4 57B2 D636 EE82"))))
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
                  (darkman darkman)
                  (latitude 38.7)
                  (longitude -9.14)
                  (use-geoclue #f)))
        ;; Monitor access to sensitive directories (SSH, AWS, GPG keys)
        (simple-service 'sensitive-file-watch
                        home-shepherd-service-type
                        (list (shepherd-service
                               (provision '(sensitive-file-watch))
                               (documentation "Alert on access to sensitive credential directories")
                               (start #~(make-forkexec-constructor
                                         (list #$(file-append bash "/bin/bash")
                                               #$(local-file "sensitive-file-watch.sh"))
                                         #:environment-variables
                                         (list (string-append "HOME=" (getenv "HOME"))
                                               (string-append "PATH=" (getenv "PATH"))
                                               (string-append "DBUS_SESSION_BUS_ADDRESS="
                                                              (or (getenv "DBUS_SESSION_BUS_ADDRESS") ""))
                                               (string-append "NOTIFY_SEND_PATH="
                                                              #$(file-append libnotify "/bin/notify-send")))))
                               (stop #~(make-kill-destructor))))))
        %base-home-services)))
