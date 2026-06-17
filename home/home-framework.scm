;; Framework 13

;; These modules supply the `job` macro, msmtp record constructors, and
;; gexp reader syntax used below. They're needed in this file's compile
;; scope because `(load ...)` only imports them at runtime, too late for
;; the `#~(job ...)` forms in the mcron job definitions.
(use-modules (guix gexp)
             (gnu services mcron)
             (gnu home services)
             (gnu home services mcron)
             (gnu home services mail))

(load (string-append (dirname (current-filename)) "/home-common.scm"))

(define mcron-job-pimsync
  #~(job '(next-hour '(0 3 6 9 12 15 18 21))
         "pimsync sync"
         #:user "franz"))

(define msmtp-service
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
                 (password-eval "secret-tool lookup Title smtp.fastmail.com_gofranz.com")))))))))

(define mcron-service
  (service home-mcron-service-type
           (home-mcron-configuration
            (jobs (list
                   mcron-job-pimsync)))))

(home-environment
 (packages common-packages)
 (services
  (common-services
   #:home-files home-files-common
   #:xdg-config-files xdg-config-files-common
   #:unattended-upgrade-config-file "/home/franz/dotfiles/home/home-framework.scm"
   #:extra-services (list msmtp-service mcron-service))))
