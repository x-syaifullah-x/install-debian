#!/bin/sh

if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  case "$XDG_SESSION_TYPE" in
    wayland)
      PS1='${debian_chroot:+($debian_chroot)}\u ⇰ '
      ;;
    *)
      PS1='${debian_chroot:+($debian_chroot)}\u :: '
      ;;
    esac
fi

NEWLINE_BEFORE_PROMPT=yes
[ "$NEWLINE_BEFORE_PROMPT" = yes ] && PROMPT_COMMAND="PROMPT_COMMAND=echo"
unset NEWLINE_BEFORE_PROMPT

HISTCONTROL=ignoreboth
HISTFILE="/dev/null"
#HISTSIZE=1000
#HISTFILESIZE=2000
: '
ket :
%d = tanggal
%a = hari
%b = bulan
%Y = Tahun
%H = jam
%M = menit
%S = detik
'
HISTTIMEFORMAT="%a, %d %b %Y %H:%M:%S "

# enable color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias diff='diff --color=auto'
  alias dir='dir --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias grep='grep --color=auto'
  alias ip='ip --color=auto'
  alias ls='ls --color=auto'
  alias vdir='vdir --color=auto'
fi

# SETUP ALIAS
_BASH_ALIASES="${HOME}/.bash_aliases"
if [ -f "$_BASH_ALIASES" ]; then
    . "$_BASH_ALIASES"
fi
unset _BASH_ALIASES