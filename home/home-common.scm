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
             (px home services unattended-upgrade)
             (px services containers)
             (px packages audio)
             (px packages wm)
             (px packages desktop-tools))

;; Theme configuration
;; available: ibm-5151, macos-classic, fleet
(define current-theme "fleet")
(define current-theme-dir
  (string-append (dirname (current-filename)) "/themes/" current-theme))

;; Darkman theme switching scripts - installed to profile/share/ for darkman 2.3+
(define darkman-scripts
  (package
    (name "darkman-scripts")
    (version "1.0")
    (source (local-file current-theme-dir #:recursive? #t))
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

;; Packages shared by all hosts.
(define common-packages
  (cons* niri-shm                    ;; Patched niri with SHM screencast support (PR #1791)
         darkman-scripts             ;; Theme switching scripts for darkman
  (specifications->packages
   (list
         ;; GUI Apps
         "gimp"
         "keepassxc"                 ;; password manager
         "vlc"
         "inkscape"
         ; "wireshark"
         ; "recoll"
         ; "calibre"                  ;; E-Books
         "qalculate-gtk"            ;; calculator
         "mousepad"                 ;; text editor
         ;; "logseq"
         "google-chrome-stable"
         "librewolf"
         "libreoffice"
         "papers"                    ;; PDF Reader
         "xournalpp"
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
         ; "deepfilternet-ladspa"

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
         "networkmanager-dmenu"      ;; wifi/vpn picker (waybar network on-click)
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
         ; "wtype"                     ;; typing backend for voxtype
         ; "voxtype-vulkan"            ;; push-to-talk voice-to-text
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
         ; "emacs"
         ; "emacs-geiser"
         ; "emacs-geiser-guile"
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
         "git:credential-libsecret"
         "git:send-email"
         "rsync"
         ; "ripgrep"                   ;; better grep
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
         "tku"                       ;; Token Usage
         "envstash"                  ;; .env version management
         "tomb"                      ;; secrets manager
         "syncthing"
         "trash-cli"
         ; "qpwgraph"
         ; "sed"
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

;; Security monitoring packages — only used by framework (scheduled via mcron).
(define security-packages
  (specifications->packages
   (list
         "aide"                      ;; file integrity baseline
         "yara"                      ;; pattern matching on recent files
         "lynis"                     ;; weekly user-context audit
   )))

;; Files placed under $HOME, shared by all hosts.
(define home-files-common
  `((".gitconfig" ,(local-file "gitconfig"))
    (".gtkrc-2.0" ,(local-file "gtkrc-2.0"))
    ;; Claude container: manifest with SSL search paths, gitconfig
    (".config/claude-container/manifest.scm"
     ,(local-file "claude-container-manifest.scm"))
    (".config/claude-container/gitconfig"
     ,(plain-file "claude-container-gitconfig"
        "[include]\n\tpath = ~/.gitconfig\n[credential]\n\thelper =\n\thelper = !gh auth git-credential\n[url \"https://github.com/\"]\n\tinsteadOf = git@github.com:\n"))
    (".local/bin/docker" ,(local-file "docker" #:recursive? #t))
    (".local/bin/bt-toggle-profile" ,(local-file "bt-toggle-profile" #:recursive? #t))
    (".local/bin/bt-profile-status" ,(local-file "bt-profile-status" #:recursive? #t))
    (".local/bin/power-profile-status" ,(local-file "power-profile-status" #:recursive? #t))
    (".local/bin/power-profile-toggle" ,(local-file "power-profile-toggle" #:recursive? #t))
    (".local/share/applications/lock.desktop" ,(local-file
                                                 "apps/lock.desktop"))
    (".local/share/applications/hibernate.desktop" ,(local-file
                                                      "apps/hibernate.desktop"))
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
    (".local/share/gtk-themes/settings-dark.ini" ,(local-file (string-append current-theme-dir "/gtk-settings-dark.ini")))
    (".local/share/gtk-themes/settings-light.ini" ,(local-file (string-append current-theme-dir "/gtk-settings-light.ini")))
    ;; Waybar theme files for darkman switching (used by scripts)
    (".local/share/waybar-themes/style-light.css" ,(local-file (string-append current-theme-dir "/waybar-light.css")))
    (".local/share/waybar-themes/style-dark.css" ,(local-file (string-append current-theme-dir "/waybar-dark.css")))))

;; Security monitoring scripts (scheduled via mcron on framework).
(define home-files-security
  `((".local/bin/security-aide-home" ,(local-file "security-aide-home" #:recursive? #t))
    (".local/bin/security-aide-accept" ,(local-file "security-aide-accept" #:recursive? #t))
    (".local/bin/security-yara-recent" ,(local-file "security-yara-recent" #:recursive? #t))
    (".local/bin/security-lynis-weekly" ,(local-file "security-lynis-weekly" #:recursive? #t))))

;; XDG config files shared by all hosts.
(define xdg-config-files-common
  `(("niri/config.kdl" ,(local-file "niri.kdl"))
    ("niri/colors.kdl" ,(local-file (string-append current-theme-dir "/niri-colors.kdl")))
    ("waybar/config" ,(local-file "waybar"))
    ("waybar/config-niri" ,(local-file "waybar-niri"))
    ("networkmanager-dmenu/config.ini" ,(local-file "networkmanager-dmenu/config.ini"))
    ;; waybar/style.css managed by darkman scripts, not guix home
    ("kanshi/config" ,(local-file "kanshi"))
    ("xfce4/xfconf/xfce-perchannel-xml/thunar.xml" ,(local-file "thunar.xml"))
    ("nvim/init.lua" ,(local-file "nvim/init.lua"))
    ("nvim/lua/plugins.lua" ,(local-file "nvim/lua/plugins.lua"))
    ("nvim/lua/core/options.lua" ,(local-file "nvim/lua/core/options.lua"))
    ("nvim/lua/core/keymaps.lua" ,(local-file "nvim/lua/core/keymaps.lua"))
    ("xdg-desktop-portal/portals.conf" ,(local-file "portals.conf"))

    ("dunst/dunstrc" ,(local-file "dunstrc"))
    ("foot/foot.ini" ,(local-file (string-append current-theme-dir "/foot.ini")))
    ("swaylock/config" ,(local-file "swaylock"))
    ;; EasyEffects autoload: apply fw13 preset on Framework speakers
    ("easyeffects/autoload/output/fw13-easy-effects.json" ,(local-file "easyeffects-autoload-output.json"))
    ;; WirePlumber Bluetooth configuration for A2DP preference (WirePlumber 0.5+)
    ("wireplumber/wireplumber.conf.d/51-bluetooth.conf" ,(local-file "wireplumber-bluetooth.conf"))
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
    ("broot/skins/white.hjson" ,(local-file "broot/skins/white.hjson"))
    ;; ClamAV freshclam config (DB stored in ~/.local/share/clamav)
    ("clamav/freshclam.conf" ,(local-file "freshclam.conf"))))

;; XDG config files for AIDE (used by security-aide-home).
(define xdg-config-files-aide
  `(("aide/aide.conf" ,(local-file "aide.conf"))))

;; Bash configuration shared by all hosts.
(define bash-service
  (service home-bash-service-type
           (home-bash-configuration
            (aliases '(("grep" . "grep --color=auto")
                       ("ll" . "ls -l")
                       ("ls" . "ls -p --color=auto")
                       ("ccs" . "guix shell -m $HOME/.config/claude-container/manifest.scm -- claude")
                       ("ccss" . "guix shell -m $HOME/.config/claude-container/manifest.scm -- claude --dangerously-skip-permissions")
                       ("pms" . "podman system service --time=0 unix:///run/user/$(id -u)/podman/podman.sock")
                       ("freshclam" . "mkdir -p $HOME/.local/share/clamav && guix shell clamav -- freshclam --datadir=$HOME/.local/share/clamav --config-file=$XDG_CONFIG_HOME/clamav/freshclam.conf")
                       ("clamscan" . "guix shell clamav -- clamscan --database=$HOME/.local/share/clamav")))
            (bashrc (list (local-file
                           ".bashrc"
                           "bashrc")))
            (bash-profile (list (local-file
                                 ".bash_profile"
                                 "bash_profile"))))))

;; Environment variables shared by all hosts.
(define env-vars-service
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
                    ;; Hardware acceleration (auto-detect via Mesa)
                    ("ANGLE_DEFAULT_PLATFORM" . "vulkan")
                    ;; Cursor theme
                    ("XCURSOR_THEME" . "Adwaita")
                    ("XCURSOR_SIZE" . "24")
                    ;; podman system service --time=0 unix:///run/user/$(id -u)/podman/podman.sock
                    ("DOCKER_HOST" . "unix:///run/user/$(id -u)/podman/podman.sock")
                    ;; Unknown terminal: foot
                    ("TERM" . "xterm-256color")
                    ;; Disable version enforcement
                    ("COREPACK_ENABLE_STRICT" . "0")
                    ("COREPACK_ENABLE_PROJECT_SPEC" . "0")
                    ;; Do Not Track: ex. Turborepo
                    ("DO_NOT_TRACK" . "1")
                    ("NEXT_TELEMETRY_DISABLED" . "1")
                    ;; GPG TTY for pinentry
                    ("GPG_TTY" . "$(tty)")
                    ;; Claude Code thinking budget
                    ("MAX_THINKING_TOKENS" . "63999")
                    ;; Suppress history files for tools that honor these
                    ("LESSHISTFILE" . "/dev/null")
                    ("NODE_REPL_HISTORY" . "")
                    ("SQLITE_HISTORY" . "/dev/null")
                    ("PSQL_HISTORY" . "/dev/null")
                    ("MYSQL_HISTFILE" . "/dev/null"))))

;; Extra Guix channels (pantherx) available via `guix home ... reconfigure`.
(define channels-service
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
                   %default-channels)))

(define syncthing-service
  (service home-syncthing-service-type))

(define dbus-service
  (service home-dbus-service-type))

(define pipewire-service
  (service home-pipewire-service-type
           (home-pipewire-configuration
            (pipewire pipewire)
            (wireplumber wireplumber))))

;; I want to manage SSH keys manually for now
;; (service home-openssh-service-type)
;; SSH agent managed by keychain in .bashrc
;; (service home-ssh-agent-service-type)
(define gpg-agent-service
  (service home-gpg-agent-service-type
           (home-gpg-agent-configuration
            (pinentry-program
             (file-append
              pinentry-qt "/bin/pinentry-qt")))))

(define darkman-service
  (service home-darkman-service-type
           (home-darkman-configuration
            (darkman darkman)
            (latitude 38.7)
            (longitude -9.14)
            (use-geoclue #f))))

(define podman-healthcheckd-service
  (service home-podman-healthcheckd-service-type))

;; Extra profile for Zed's node — kept out of the main home profile
;; (per preference) but refreshed on every `guix home reconfigure`.
(define zed-node-profile-service
  (simple-service 'zed-node-profile
                  home-activation-service-type
                  #~(let* ((home (getenv "HOME"))
                           (profile-dir (string-append home "/.guix-extra-profiles/zed-node"))
                           (profile (string-append profile-dir "/zed-node"))
                           (manifest #$(plain-file "zed-node-manifest.scm"
                                                   "(specifications->manifest '(\"node\"))")))
                      (system* "mkdir" "-p" profile-dir)
                      (format #t "Updating zed-node profile…~%")
                      (system* "/run/current-system/profile/bin/guix"
                               "package" "-p" profile "-m" manifest))))

;; Unattended home upgrade (Saturday 21:00, after system upgrade at 17:00).
;; Host variants call this with their own path so reconfigure picks the
;; right file.
(define (unattended-upgrade-for config-file)
  (service home-unattended-upgrade-service-type
           (home-unattended-upgrade-configuration
            (config-file config-file)
            (schedule "0 21 * * 6")
            (skip-on-battery? #t)
            (warm-packages '("node" "pnpm" "gh" "sed" "ripgrep"
                             "claude-code" "rust" "gcc-toolchain"
                             "openssl"))
            (channels #~
                      (cons*
                       (channel
                        (name 'pantherx)
                        (branch "master")
                        (url "https://codeberg.org/gofranz/panther.git")
                        (introduction
                         (make-channel-introduction
                          "54b4056ac571611892c743b65f4c47dc298c49da"
                          (openpgp-fingerprint
                           "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
                       %default-channels)))))

;; Builds the full service list for a host.
;;   home-files        — list of (path local-file) entries for $HOME
;;   xdg-config-files  — list of (path local-file) entries under ~/.config
;;   unattended-upgrade-config-file — absolute path to the host's .scm file
;;   extra-services    — additional services to layer on (msmtp, mcron, …)
(define* (common-services #:key
                          home-files
                          xdg-config-files
                          unattended-upgrade-config-file
                          (extra-services '()))
  (append
   (list bash-service
         (service home-files-service-type home-files)
         (service home-xdg-configuration-files-service-type xdg-config-files)
         env-vars-service
         channels-service
         syncthing-service
         dbus-service
         pipewire-service
         gpg-agent-service
         darkman-service
         podman-healthcheckd-service
         zed-node-profile-service
         (unattended-upgrade-for unattended-upgrade-config-file))
   extra-services
   %base-home-services))
