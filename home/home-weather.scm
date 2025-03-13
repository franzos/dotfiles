;; Read packages from home.scm and query substitutes availability
;; Run: guile home-weather.scm

(use-modules (ice-9 regex)
             (ice-9 textual-ports)
             (ice-9 popen))

(define (extract-packages file-path)
  (let ((file (open-input-file file-path)))
    (let loop ((packages '()) (line (get-line file)))
      (if (eof-object? line)
          (begin
            (close-port file)
            (reverse packages))
          (cond
           ((string-prefix? "         \"" line)
            (let ((match (string-match "\"([^\"]*)\"" line)))
              (if match
                  (loop (cons (match:substring match 1) packages)
                        (get-line file))
                  (loop packages (get-line file)))))
           (else
            (loop packages (get-line file))))))))

(define (filter-packages packages)
  (filter (lambda (package)
            (not (string-contains package ":")))
          packages))

(define packages (extract-packages "home.scm"))
(define filtered-packages (filter-packages packages))

(define guix-weather-command
  (string-append "guix weather "
                 (string-join filtered-packages " ")))

(let ((port (open-input-pipe guix-weather-command)))
  (let loop ((line (get-line port)))
    (if (eof-object? line)
        (close-pipe port)
        (begin
          (display line)
          (newline)
          (loop (get-line port))))))
