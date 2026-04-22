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

;; Security monitoring jobs — see ~/dotfiles/home/security-* scripts.
;; All three run under the user; msmtp uses secret-tool, so they only
;; deliver mail while the keyring is unlocked (i.e. when logged in).
;; Schedule for times when Franz is typically logged in, not 03:00.
(define mcron-job-security-aide
  ;; Daily at 09:00
  #~(job "0 9 * * *"
         "/home/franz/.local/bin/security-aide-home"
         #:user "franz"))

(define mcron-job-security-yara
  ;; Daily at 09:15
  #~(job "15 9 * * *"
         "/home/franz/.local/bin/security-yara-recent"
         #:user "franz"))

(define mcron-job-security-lynis
  ;; Mondays at 09:30
  #~(job "30 9 * * 1"
         "/home/franz/.local/bin/security-lynis-weekly"
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
                   mcron-job-pimsync
                   mcron-job-security-aide
                   mcron-job-security-yara
                   mcron-job-security-lynis)))))

(home-environment
 (packages (append common-packages security-packages))
 (services
  (common-services
   #:home-files (append home-files-common home-files-security)
   #:xdg-config-files (append xdg-config-files-common xdg-config-files-aide)
   #:unattended-upgrade-config-file "/home/franz/dotfiles/home/home-framework.scm"
   #:extra-services (list msmtp-service mcron-service))))
