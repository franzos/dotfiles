(use-modules (guix packages)
             (guix search-paths)
             (gnu packages)
             (gnu packages tls)
             (gnu packages nss))

(define nss-certs-with-ssl-env
  (package
    (inherit nss-certs)
    (native-search-paths
     (list (search-path-specification
            (variable "SSL_CERT_FILE")
            (files '("etc/ssl/certs/ca-certificates.crt"))
            (file-type 'regular)
            (separator #f))
           (search-path-specification
            (variable "GIT_SSL_CAINFO")
            (files '("etc/ssl/certs/ca-certificates.crt"))
            (file-type 'regular)
            (separator #f))
           (search-path-specification
            (variable "CURL_CA_BUNDLE")
            (files '("etc/ssl/certs/ca-certificates.crt"))
            (file-type 'regular)
            (separator #f))))))

(packages->manifest
 (append
  (list nss-certs-with-ssl-env)
  (map specification->package
   '("coreutils" "bash" "grep" "sed" "gawk" "git"
     "node" "pnpm" "gh" "dunst" "ripgrep" "claude-code" "which"))))
