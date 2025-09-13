#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export BASH_SILENCE_DEPRECATION_WARNING=1

#-------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
#-------------------------------------------------------------------------------
export EDITOR='nvim'
export GOPATH=$HOME/go
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LESSCHARSET='utf-8'
export FTP_PASSIVE=1
export CDPATH=.:~:~/src
export MANPAGER='nvim +Man!'

export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:$HOME/bin:$GOPATH/bin:$PATH:/usr/local/go/bin

# For xterm titles
export PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME}: ${PWD/$HOME/~}\007"'

# LS_COLORS
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

#-------------------------------------------------------------------------------
# BASH HISTORY
#-------------------------------------------------------------------------------
# Preserve bash history in multiple terminal windows
# from http://unix.stackexchange.com/a/48113
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=10000000                   # big big history
export HISTFILESIZE=10000000               # big big history
export SHELL_SESSION_HISTORY=0
shopt -s histappend                       # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#-------------------------------------------------------------------------------
# SHELL PROMPT
#-------------------------------------------------------------------------------
GRAY="\[\033[1;30m\]"
LIGHT_GRAY="\[\033[0;37m\]"
CYAN="\[\033[0;36m\]"
LIGHT_CYAN="\[\033[1;36m\]"
NO_COLOR="\[\033[0m\]"
YELLOW="\[\033[1;33m\]"
WHITE="\[\033[1;37m\]"
RED="\[\033[1;31m\]"

shorten_path() {
    # Replace the home directory with ~
    local path="${PWD/#$HOME/~}"
    path="${path/#$(readlink -f $HOME)/~}"

    local IFS="/"
    local parts=($path)
    local new_path=""
    local len=${#parts[@]}

    for (( i=0; i<$len; i++ )); do
        if [[ $i == $((len-1)) ]]; then
            # If it's the last element, add the full name
            new_path+="${parts[$i]}"
        else
            # Else, add the first character followed by a /
            new_path+="${parts[$i]:0:1}/"
        fi
    done
    echo -n "$new_path"
}

get_git_branch() {
    # Check if the current directory is in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Echo the branch name
        echo -n "[$(git branch --show-current)]"
    fi
}

export PS1="$GRAY($YELLOW\u$GRAY@$CYAN\h$GRAY)--($LIGHT_CYAN\$(shorten_path)$GRAY)--(\A)$(  echo -n " $GRAY\$(get_git_branch)$GRAY")\n$WHITE\$$NO_COLOR "

#-------------------------------------------------------------------------------
# ALIASES
#-------------------------------------------------------------------------------
alias ls='ls --color=auto --show-control-chars'
alias grep="grep --exclude-dir vendor --color=auto"
alias p='perl'
alias less='less -r'
alias vi='nvim'
alias v='vi $(find . -path "./.git*" -prune -o -print | peco)'
alias vi_nofmt='vim --cmd "let g:go_fmt_autosave = 0"'
alias tmux='tmux -2'
alias urlencode="perl -MCGI::Util=escape -e'while(<>){chop;print escape(\$_).\"\\n\";}'"
alias urldecode="perl -MCGI::Util=unescape -e'while(<>){chop;print unescape(\$_).\"\\n\";}'"
alias base64encode="perl -mMIME::Base64 -e 'while(<>){print MIME::Base64::encode_base64(\$_)}'"
alias base64decode="perl -mMIME::Base64 -e 'while(<>){print MIME::Base64::decode_base64(\$_)}'"
alias curlheader='curl -s -D - -o /dev/null'
alias pythonserver='/usr/bin/python -m SimpleHTTPServer'
alias xml_pp='xmllint --format -'

#-------------------------------------------------------------------------------
# KEYBINDINGS
#-------------------------------------------------------------------------------
set -o vi
bind -m vi-insert "\C-l":clear-screen
bind -m vi-insert "\C-p":previous-history
bind -m vi-insert "\C-n":next-history

#-------------------------------------------------------------------------------
# SHELL EXTENSIONS (Completion, FZF, etc.)
#-------------------------------------------------------------------------------
# Bash Completion
if [[ "$OSTYPE" =~ ^darwin ]]; then
    BREWPATH=/opt/homebrew/bin/brew
    if [[ "$(arch)" == "i386" ]]; then
        BREWPATH=/usr/local/bin/brew
    fi
    if [ -f $($BREWPATH --prefix)/etc/bash_completion ]; then
        . $($BREWPATH --prefix)/etc/bash_completion
    fi
else
    if [ -f $HOME/.bash-completion/bash_completion ]; then
        . $HOME/.bash-completion/bash_completion
    fi
fi

# FZF
[ -f ~/.fzf/shell/key-bindings.bash ] && source ~/.fzf/shell/key-bindings.bash
[ -f ~/.fzf/shell/completion.bash ] && source ~/.fzf/shell/completion.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.nix-profile/share/fzf/key-bindings.bash ] && source ~/.nix-profile/share/fzf/key-bindings.bash

# Cargo
if [[ -f "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    alias cd=z
fi

# eza
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto --git --time-style relative'
fi

#-------------------------------------------------------------------------------
# OS-SPECIFIC CONFIGURATION
#-------------------------------------------------------------------------------
if [[ "$OSTYPE" =~ ^darwin ]]; then
    # GNU Coreutils
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

    # Homebrew
    eval $($BREWPATH shellenv)

    # ls alias for macOS
    # alias ls='/bin/ls -G'
fi

#-------------------------------------------------------------------------------
# NIX & HOME-MANAGER
#-------------------------------------------------------------------------------
home-manager-update() {
    if [ -z "$1" ]; then
        echo "Usage: home-manager-update <macbook|office>"
        return 1
    fi
    cd ~/.config/home-manager && nix flake update && home-manager switch --flake ".#$1" && cd -
}
alias home-manager-diff="nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager"

nix-darwin-update() {
    cd ~/.config/nix-darwin && nix flake update && sudo nix run nix-darwin -- switch --flake .#mac || cd -
}

#-------------------------------------------------------------------------------
# LOCAL/HOSTNAME-SPECIFIC OVERRIDES
#-------------------------------------------------------------------------------
if [ -f "$HOME/.bashrc.$(hostname -s)" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.bashrc.$(hostname -s)"
fi

#-------------------------------------------------------------------------------
# When called by LLM
#-------------------------------------------------------------------------------
if [ -n "$CURSOR_AGENT" ]; then
    unset HISTFILE
    export PS1="$ "
    unalias ls
fi
