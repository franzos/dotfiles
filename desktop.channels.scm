(cons* (channel
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
       %default-channels)
