(cons* (channel
        (name 'pantherx)
        (branch "master")
        (url "https://channels.pantherx.org/git/panther.git")
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
        (name 'rustup)
        (url "https://github.com/declantsien/guix-rustup")
         (introduction
          (make-channel-introduction
           "325d3e2859d482c16da21eb07f2c6ff9c6c72a80"
           (openpgp-fingerprint
            "F695 F39E C625 E081 33B5  759F 0FC6 8703 75EF E2F5"))))
       %default-channels)

