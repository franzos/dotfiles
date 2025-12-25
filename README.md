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

## Themes

Available: `ibm-5151`, `macos-classic`

Change theme in `home/home.scm`:
```scheme
(define current-theme "ibm-5151")
```

To add a new theme, create `home/themes/<name>/` with:
- `foot.ini`, `sway-colors`, `waybar-light.css`, `waybar-dark.css`
- `gtk-settings-light.ini`, `gtk-settings-dark.ini`
- Darkman scripts: `foot-dark`, `foot-light`, `sway-dark`, `sway-light`, `waybar-dark`, `waybar-light`, `dunst-dark`, `dunst-light`, `vscode-dark`, `vscode-light`, `gtk-dark`, `gtk-light`

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
- **Chrome** with Hardware Acceleration
- **Hibernation** Hibernate to disk after 60m standby

### Security
- Smart card support (pcscd)
- lxqt-policykit agent
- block-facebook-hosts
- Yubikey challenge-response for sudo

#### Yubikey Setup (Challenge-Response for sudo)

Enable slot 2:

```bash
guix shell python-yubikey-manager -- ykman config usb --enable OTP
```

Program slot 2:

```bash
# openssl rand -hex 20
guix shell python-yubikey-manager -- ykman otp chalresp --touch 2 <your-secret-hex>
```

Generate challenge file (once, with any key):

```bash
guix shell yubico-pam -- ykpamcfg -2 -v
```

### Hardware-specific
- **Framework**: AMD GPU, fw-fanctrl
- **Thinkpad**: Intel i915, SSH server, backlight udev rules