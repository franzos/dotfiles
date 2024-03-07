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
             (gnu home services)
	     (gnu home services ssh)
	     (gnu home services gnupg)
	     (gnu home services shells)
	     (gnu home services sound)
	     (gnu home services desktop)
	     (gnu home services syncthing))

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages (specifications->packages (list "alacritty"
                                           "qutebrowser"
                                           "neovim"
                                           "qalculate-gtk"
                                           "transmission"
                                           "vscode"
                                           "signal-desktop"
                                           "vscodium"
                                           "syncthing"
                                           "trash-cli"
                                           "gsettings-desktop-schemas"
					   "gnome-themes-extra"
					   "file"
                                           "firefox"
                                           "glib:bin"
                                           "evince"
                                           "telegram-desktop"
                                           "electrum-cc"
                                           "calibre"
                                           "ublock-origin-chromium"
                                           "keychain"
                                           "icedove-wayland"
					   "obs-pipewire-audio-capture"
					   ;; "xdg-desktop-portal"
					   "xdg-desktop-portal-wlr"
                                           "obs-wlrobs"
                                           "obs"
					   "wl-clipboard"
					   "clipman"
					   "grim"
					   "dmenu"
                                           "recoll"
                                           "bitcoin-core"
                                           "qemu"
                                           "wireshark"
                                           "kleopatra"
                                           "docker"
                                           "quassel"
                                           "linphone-desktop"
                                           "libreoffice"
                                           "flatpak"
                                           "nheko"
                                           "monero"
                                           "ungoogled-chromium"
                                           "tomb"
                                           "keepassxc"
                                           "vlc"
                                           "guvcview"
                                           "gimp"
                                           "mpv"
                                           "yt-dlp"
                                           "seahorse"
                                           "inkscape"
                                           "emacs"
                                           "docker-compose"
                                           "git"
                                           "tigervnc-client"
                                           "recutils"
                                           "curl"
                                           "adb"
                                           "wget"
                                           "bind:utils"
                                           "rsync"
                                           "graphicsmagick"
                                           "imagemagick"
                                           "glances"
                                           "python"
                                           "nmap"
                                           "steghide"
                                           "shellcheck"
                                           "emacs-geiser-guile"
                                           "docker-cli"
                                           "bmon"
                                           "htop"
                                           "unzip"
                                           "aspell"
                                           "wireguard-tools"
                                           "zip"
                                           "lsof"
                                           "pnpm"
                                           "font-linuxlibertine"
                                           "net-tools"
                                           "unrar"
                                           "libusb"
                                           "emacs-geiser"
                                           "font-openmoji"
                                           "restic"
                                           "font-ibm-plex"
                                           "hunspell-dict-en"
                                           "hunspell-dict-en-us"
                                           "aspell-dict-en"
                                           "unicode-emoji"
                                           "aspell-dict-uk"
					   "qpwgraph"
					   "sed"
					   "mit-scheme"
					   "qtwayland"
					   "swappy"
					   "wf-recorder"
					   "playerctl" 
					   "yaru-theme"
					   "keychain"
					   "dconf"
					   "evince"
					   "ffmpegthumbnailer"
					   "webp-pixbuf-loader"
					   "tumbler"
					   "libgsf"
					   "thunar-archive-plugin"
					   "font-google-material-design-icons"
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
		 `((".gtkrc-2.0", (local-file "gtkrc-2.0"))
		   (".local/share/applications/vscode.desktop", (local-file "apps/vscode.desktop"))
		   (".local/share/applications/vscode_go.desktop", (local-file "apps/vscode_go.desktop"))
		   (".local/share/applications/vscode_rust.desktop", (local-file "apps/vscode_rust.desktop"))))
	(service home-xdg-configuration-files-service-type
		 `(("sway/config" ,(local-file "sway"))
		   ("waybar/config", (local-file "waybar"))
		   ("gtk-3.0/settings.ini" ,(local-file "gtk-3.0-settings.ini"))
		   ("kanshi/config" ,(local-file "kanshi"))
		   ("xfce4/xfconf/xfce-perchannel-xml/thunar.xml" ,(local-file "thunar.xml"))
		   ("nvim/init.lua" ,(local-file "nvim/init.lua"))
		   ("nvim/lua/plugins.lua", (local-file "nvim/lua/plugins.lua"))))
	(simple-service
	 'env-vars home-environment-variables-service-type
	 `(("QT_QPA_PLATFORM" . "wayland;xcb")
           ("GTK_THEME" . "Yaru-dark")
           ("SDL_VIDEODRIVER" . "wayland")
	   ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")))
	(service home-syncthing-service-type)
	(service home-dbus-service-type)
	(service home-pipewire-service-type)
	(service home-openssh-service-type)
	(service home-gpg-agent-service-type
		 (home-gpg-agent-configuration
                  (pinentry-program
                   (file-append pinentry "/bin/pinentry")))))))
