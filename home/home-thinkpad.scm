;; Thinkpad

(load (string-append (dirname (current-filename)) "/home-common.scm"))

(home-environment
 (packages common-packages)
 (services
  (common-services
   #:home-files home-files-common
   #:xdg-config-files xdg-config-files-common
   #:unattended-upgrade-config-file "/home/franz/dotfiles/home/home-thinkpad.scm")))
