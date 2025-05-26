My .dotfiles; A work in progress.

## System Configuration

```bash
sudo su - root
export SYS_CONF=/home/franz/dotfiles/system && guix system -L $SYS_CONF reconfigure $SYS_CONF/thinkpad.scm
export SYS_CONF=/home/franz/dotfiles/system && guix system -L $SYS_CONF reconfigure $SYS_CONF/framework.scm
```

Debug

```bash
SYS_CONF=/home/franz/dotfiles/system guix repl -L $SYS_CONF $SYS_CONF/thinkpad.scm
```

## Home Configuration

```bash
cd /home/franz/dotfiles/home
guix home reconfigure home.scm
```

## Mail

```bash
echo "Subject: Hi" | msmtp -a f-a.nz m@f-a.nz -v
```