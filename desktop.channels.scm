(cons* (channel
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
       (channel
        (name 'divya-lambda)
        (url "https://codeberg.org/divyaranjan/divya-lambda.git")
        (branch "master")
        (introduction
         (make-channel-introduction
          "fe2010125fcbe003de42436b1a73ab53cc5e8288"
          (openpgp-fingerprint
           "F0B3 1A69 8006 8FB8 096A  2F12 B245 10C6 108C 8D4A"))))
       %default-channels)

