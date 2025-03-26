#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


# enable bash completion in interactive shells
# for OS-X, use brew version
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

#export	EDITOR='vim'
export	EDITOR='nvim'

# for xterm titles
export	PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME}: ${PWD/$HOME/~}\007"'

export	LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

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
    path="${path/#\/home1\/irteam\/naver\/work\/jihoonc/~}"

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



export	LC_ALL=en_US.UTF-8
export	LANG=en_US.UTF-8

export	LESSCHARSET='utf-8'

bind -m vi-insert "\C-l":clear-screen
bind -m vi-insert "\C-p":previous-history
bind -m vi-insert "\C-n":next-history
set -o vi

alias	tmux='tmux -2'
alias	urlencode="perl -MCGI::Util=escape -e'while(<>){chop;print escape(\$_).\"\\n\";}'"
alias	urldecode="perl -MCGI::Util=unescape -e'while(<>){chop;print unescape(\$_).\"\\n\";}'"
alias	base64encode="perl -mMIME::Base64 -e 'while(<>){print MIME::Base64::encode_base64(\$_)}'"
alias	base64decode="perl -mMIME::Base64 -e 'while(<>){print MIME::Base64::decode_base64(\$_)}'"
alias	ls='ls --color=auto --show-control-chars'
alias	grep="grep --exclude-dir vendor --color=yes"
alias	p='perl'
alias	less='less -r'
#alias	vi='vim'
alias	vi='nvim'
alias 	v='vi $(find . -path "./.git*" -prune -o -print | peco)'
alias	vi_nofmt='vim --cmd "let g:go_fmt_autosave = 0"'
alias	curlheader='curl -s -D - -o /dev/null'
alias	pythonserver='/usr/bin/python -m SimpleHTTPServer'
alias	xml_pp='xmllint --format -'

if echo "$MACHTYPE" | grep -qi "apple" ; then
	alias	ls='/bin/ls -G'
fi

export	GOPATH=$HOME/go

export	FTP_PASSIVE=1

# Preserve bash history in multiple terminal windows
# from http://unix.stackexchange.com/a/48113

export HISTCONTROL=ignoredups:erasedups	# no duplicate entries
export HISTSIZE=100000			# big big history
export HISTFILESIZE=100000		# big big history
shopt -s histappend			# append to history, don't overwrite it
export SHELL_SESSION_HISTORY=0

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

export CDPATH=.:~:~/src

if [[ "$OSTYPE" =~ ^darwin ]]; then
	export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
	export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
	eval $($BREWPATH shellenv)
fi

[ -f ~/.fzf/shell/key-bindings.bash ] && source ~/.fzf/shell/key-bindings.bash
[ -f ~/.fzf/shell/completion.bash ] && source ~/.fzf/shell/completion.bash


export BASH_SILENCE_DEPRECATION_WARNING=1
if [[ -f "$HOME/.cargo/env" ]]; then
	. "$HOME/.cargo/env"
fi

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#export	PATH=$HOME/.local/bin:$HOME/bin:$HOME/.fzf/bin:$GOPATH/bin:$PATH:/usr/local/go/bin
export	PATH=$HOME/.local/bin:$HOME/bin:$GOPATH/bin:$PATH:/usr/local/go/bin

if [ -f "$HOME/.bashrc.$(hostname -s)" ]; then
	# shellcheck source=/dev/null
	source "$HOME/.bashrc.$(hostname -s)"
fi

alias llama3="ollama run llama3:instruct"
alias llama3_8b="ollama run llama3:8b-instruct-q8_0"

PATH="/Users/jihoonc/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/jihoonc/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/jihoonc/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/jihoonc/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/jihoonc/perl5"; export PERL_MM_OPT;
