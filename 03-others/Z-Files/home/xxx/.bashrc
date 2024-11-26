#! ~/.bashrc

command_not_found_handle() { return 127; }

sudo() { su -p -c "PATH=$PATH:/sbin $*"; }

FIRST_RUN=1

if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  case "$XDG_SESSION_TYPE" in
    wayland)
			trap '
		  	if [[ -n "$BASH_COMMAND" && $FIRST_RUN -eq 0 ]]; then
		    	echo -ne "\e]0;$BASH_COMMAND\a"
		  	fi
			' DEBUG
      PS1="\$([ \$? == 0 ] || echo -e '\e[31m✘\e[0m ')${debian_chroot:+($debian_chroot)}\[\e]0;Terminal\a\]\$([ $(id -u) -eq 0 ] && echo '# ' || echo '⇰ ')"
      ;;
    *)
      PS1='${debian_chroot:+($debian_chroot)}\$ '
      ;;
    esac
fi

PROMPT_COMMAND='
[ $FIRST_RUN -eq 0 ] && echo; #NEW_LINE
FIRST_RUN=0
'

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

[ -f ~/.bash_aliases ] && . ~/.bash_aliases