My .dotfiles; A work in progress.

## System Configuration

```bash
sudo su - root
SYS_CONF=/home/franz/src/config/system guix system -L $SYS_CONF reconfigure $SYS_CONF/thinkpad.scm
```

Debug

```bash
SYS_CONF=/home/franz/src/config/system guix repl -L $SYS_CONF $SYS_CONF/thinkpad.scm
```

## Home Configuration

```bash
cd /home/franz/src/config/home
guix home reconfigure home.scm
```