# Bash initialization for interactive non-login shells and
# for remote shells (info "(bash) Bash Startup Files").

# Export 'SHELL' to child processes.  Programs such as 'screen'
# honor it and otherwise use /bin/sh.
export SHELL

if [[ $- != *i* ]]
then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile

    # Don't do anything else.
    return
fi

# Source the system-wide file.
source /etc/bashrc

# Adjust the prompt depending on whether we're in 'guix environment'.
if [ -n "$GUIX_ENVIRONMENT" ]
then
    PS1='\u@\h \w [env]\$ '
else
    PS1='\u@\h \w\$ '
fi

# History: in-memory only, never written to disk
HISTFILE=/dev/null
HISTSIZE=10000
HISTFILESIZE=0
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE=' *:ls:ll:cd:exit:clear'

alias ls='ls -p --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'

# SSH key
# eval `keychain --eval ssh franz yk1 yk1.no-pin yk2 yk2.no-pin`
eval `keychain --eval franz`

# Apps
export EDITOR=nvim
export QT_QPA_PLATFORM="wayland;xcb"
export PATH=$PATH:~/.cargo/bin/

# broot shell function
# This function starts broot and executes the command
# it produces, if any.
# It's needed because some shell commands, like `cd`,
# have no useful effect if executed in a subshell.
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

# Claude Code in a guix container
ccssj() {
    local manifests=("-m" "$HOME/.config/claude-container/manifest.scm")
    if [ -f "$PWD/manifest.scm" ]; then
        manifests+=("-m" "$PWD/manifest.scm")
        echo "ccssj: including $PWD/manifest.scm"
    fi
    guix shell "${manifests[@]}" --container \
        --expose="$HOME/.gitconfig=$HOME/.gitconfig" \
        --expose="$HOME/.config/gh=$HOME/.config/gh" \
        --expose="$HOME/.config/claude-container/gitconfig=$HOME/.config/claude-container/gitconfig" \
        --share="$HOME/.claude=$HOME/.claude" \
        --share="$HOME/.claude.json=$HOME/.claude.json" \
        --share="$HOME/.config/claude=$HOME/.config/claude" \
        --share="$HOME/.cache/pnpm=$HOME/.cache/pnpm" \
        --share="$HOME/.local/share/pnpm=$HOME/.local/share/pnpm" \
        --preserve='^COLORTERM$' \
        --share="$PWD=$PWD" \
        --network \
        -- env GUIX_CONTAINER=1 \
        GIT_CONFIG_GLOBAL="$HOME/.config/claude-container/gitconfig" \
        claude --dangerously-skip-permissions --settings '{"disableAllHooks":true}' "$@"
}

# envstash tab completion
source <(COMPLETE=bash envstash)

# direnv (.envrc)
eval "$(direnv hook bash)"
