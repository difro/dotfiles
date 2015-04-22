#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

export	HISTSIZE=1000
export	HISTFILESIZE=1000

export	EDITOR='vim'

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
export	PS1="$GRAY($YELLOW\u$GRAY@$CYAN\h$GRAY)--($LIGHT_CYAN\w$GRAY)--(\A)\n$WHITE\$$NO_COLOR "

export	LC_ALL=ko_KR.UTF-8
export	LANG=ko_KR.UTF-8

export	LESSCHARSET='utf-8'

bind -m vi-insert "\C-l":clear-screen
bind -m vi-insert "\C-p":previous-history
bind -m vi-insert "\C-n":next-history
set -o vi

# load host-specific configuration.
if [ -f ~/.bashrc.`hostname` ]; then
	. ~/.bashrc.`hostname`
fi

alias	tmux='tmux -2'
alias	urlencode="perl -MCGI::Util=escape -e'while(<>){chop;print escape(\$_).\"\\n\";}'"
alias	urldecode="perl -MCGI::Util=unescape -e'while(<>){chop;print unescape(\$_).\"\\n\";}'"
alias	base64encode="perl -mMIME::Base64 -e 'while(<>){print MIME::Base64::encode_base64(\$_)}'"
alias	base64decode="perl -mMIME::Base64 -e 'while(<>){print MIME::Base64::decode_base64(\$_)}'"
alias	ls='ls --color=auto --show-control-chars'
alias	grep='grep --color=auto'
alias	p='perl'
alias	less='less -r'
alias	vi='vim'
alias 	v='vi $(find . -path "./.git*" -prune -o -print | peco)'
alias	curlheader='curl -s -D - -o /dev/null'
alias	pythonserver='/usr/bin/python -m SimpleHTTPServer'

if echo "$MACHTYPE" | grep -qi "apple" ; then
	alias	ls='ls -G'
fi

export	PATH=$HOME/bin:$PATH

export	GOPATH=$HOME/work/go
export	FTP_PASSIVE=1
