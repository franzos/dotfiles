My .dotfiles; A work in progress.

## System Configuration

```bash
su - root
cd /home/franz/dotfiles && guix system -L system reconfigure system/thinkpad.scm
cd /home/franz/dotfiles && guix system -L system reconfigure system/framework.scm
```

Debug

```bash
cd /home/franz/dotfiles && guix repl -L system system/thinkpad.scm
```

## Home Configuration

```bash
cd /home/franz/dotfiles/home
guix home reconfigure home.scm
```

## Mail

```bash
echo "Subject: Hi" | msmtp -a gofranz.com mail@gofranz.com -v
```

## Features

- **Darkman** - Automatic dark/light theme switching at sunrise/sunset (toggle: `darkman toggle` or Mod+T)
- **Sway** (Wayland) with greetd/wlgreet, waybar, swaylock
- **Mail stack** - aerc + isync + msmtp + dovecot (local IMAP)
- **Calendar/Contacts** - khal + pimsync (auto-sync every 10min)
- **Rootless Podman** - Container runtime
- **Mullvad VPN** - VPN service
- **broot** - File navigator with multi-scheme theming
- **Unattended upgrades** - Daily at 12:00 (pantherx + small-guix channels)
- **LUKS encryption** - Full disk encryption
- **TLP** - Power management with custom AC/battery profiles
- **ZRAM** - Compressed swap (8G thinkpad, 24G framework)

### Security
- Smart card support (pcscd)
- lxqt-policykit agent
- block-facebook-hosts

### Hardware-specific
- **Framework**: AMD GPU, fw-fanctrl
- **Thinkpad**: Intel i915, SSH server, backlight udev rules