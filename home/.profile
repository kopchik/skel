# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source ~/.profile_local


#################
# SHELL TUNNING #
#################

#set * to match all files
shopt -s dotglob
# HISTORY
HISTSIZE=10000
HISTCONTROL=ignoredups:ignorespace
HISTIGNORE='rm *: sudo rm *:cp *'
shopt -s histappend
# ENV TUNNING
export HOME
export PATH=~/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
#export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-7-openjdk/jre}
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-7-openjdk}
export HISTTIMEFORMAT='%h %d %H:%M:%S '
#export GREP_OPTIONS='--color=auto'
export EDITOR=vim
export PAGER="`which less` -R"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8


##########################
# HOST-SPECIFIC SETTINGS #
##########################

if [ "$HOSTNAME" == "dhcp089" ]; then
  PROXY="http://proxy.science.unitn.it:3128/"
  export http_proxy=$PROXY
  export ftp_proxy=$PROXY
  export https_proxy=$PROXY
fi

if [ "$HOSTNAME" == "ux32vd" ]  || [ "$HOSTNAME" == "p1" ]; then
    export PATH=~/github/stlink_new/:$PATH
    #SSH AGENT
    export SSH_AUTH_SOCK=~/.ssh/ssh-agent
    ssh-add -l 2>&1 >/dev/null #return status 2 is if ssh-add is unable to contact the authentication agent
    if [ $? == 2 ]; then
        pkill -TERM -u $(whoami) -x ssh-agent
        echo "starting ssh-agent"; rm -f $SSH_AUTH_SOCK; eval `/usr/bin/ssh-agent -a $SSH_AUTH_SOCK`;
    fi
    SCREENDEV="eDP1"


    alias dg="python3 -m dg"
fi

#CHANGE CWD TO HOMEDIR. Workarround for ubuntu bug with working dir in
#x-session
if [ "`pwd`" == "/" ]; then
    cd
fi



#ALIASES
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

function svndiff () { svn diff $@ | colordiff | less -R; }
function svndwdiff () { svn diff $@ | dwdiff --diff-input -c | less -R; }

alias mystrace='strace -s 256 -f -o /tmp/mystrace'
alias psl='ps auxww --sort=lstart | sort -r -k3,4 | head -20'

#alias skype="xhost +local:skype; sudo -H -u skype skype"
#alias skype="xhost +local:skype; sudo -H -u skype ecryptfs-mount-private; sudo -H -u skype skype"
#alias skype="xhost +local:skype; sudo -H -u skype LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so skype"
#alias skype="xhost +local:skype; sudo -H -u skype ecryptfs-mount-private; sudo -H -u skype LD_PRELOAD=/usr/local/lib/v4l1compat.so skype"

alias udperr='watch --differences=cumulative "netstat -s -u | grep \"receive errors\""'
alias flvideo='find /proc/`pgrep -f libflashplayer`/fd/ -lname "/tmp/Fla*"'
alias projector_on='xrandr --output eDP1 --mode 1024x768 --output VGA1 --mode 1024x768 --same-as eDP1'
alias projector_off='xrandr --output eDP1 --auto --output VGA1 --off'


alias sched_1ms="sudo sysctl kernel.sched_min_granularity_ns=100000"
alias sched_10ms="sudo sysctl kernel.sched_min_granularity_ns=1000000"
alias sched_100ms="sudo sysctl kernel.sched_min_granularity_ns=10000000"
alias sched_1000ms="sudo sysctl kernel.sched_min_granularity_ns=100000000"

alias romashka="mplayer http://81.187.163.34:8282/cam1.asf -cache 32"

alias iwscan="sudo iwlist scan | less"
p() { addr=$1
      if [ -z "$addr" ]; then addr="8.8.8.8"; fi
      sudo ping -n -s 100 -i0.1 $addr
}

remove_ssh() {
  sed -i ${1}d ~/.ssh/known_hosts
}

# X STUFF
export EXT_SCREEN=${EXT_SCREEN:-HDMI-1}
export INT_SCREEN=${INT_SCREEN:-eDP-1}

alias hdmi_on="xrandr --output $EXT_SCREEN --auto"
alias hdmi_off="xrandr --output $EXT_SCREEN --off; xrandr --output $INT_SCREEN --auto"
alias hdmi_mirror="xrandr --output $EXT_SCREEN --auto --same-as eDP-1"
alias hdmi_left="xrandr --output $EXT_SCREEN --auto --left-of eDP-1"

alias vga_on="xrandr --output VGA-1 --auto"
alias vga_off="xrandr --output VGA-1 --off; xrandr --output $INT_SCREEN --auto"

# .Xresources handled automatically
#xrdb -merge ~/.Xdefaults
# fix xkb layout switching
if [ -n "${XDG_SESSION_PATH}" ]; then
    setxkbmap -option "grp:shift_caps_switch,caps:ctrl_modifier"
fi


mkimg() {
    n=0
    q=70
    s=1600
    OPTIND=1
    while getopts "hn:q:s:" opt; do
        case $opt in
            n)
                n=$OPTARG
                ;;
            q)
                q=$OPTARG
                ;;
            s)
                s=$OPTARG
                ;;
            h)
                echo "mkimg -n <start number> -q <jpeg quality> -s <size>  <files>"
                return
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                ;;
        esac
    done
    shift $((OPTIND-1))
echo "start number $n, quality $q, size $s"
echo "files: $*"
echo "press Ctrl+C to abort, Enter to continue"
read


    for img in $*; do
        if [ ! -f "$img" ]; then
            echo "$img doesn't exists"
            continue
        fi

        echo "rotating image $img (if needed)"
        jhead -autorot "$img"

        echo "resizing it"
        gm convert -quality "$q" -resize $s $img $n.jpeg

        let n=$n+1
    done
}


########
# MISC #
########

#from http://stackoverflow.com/questions/282802/how-can-i-view-all-historical-changes-to-a-file-in-svn
svn_file_hist() {
    url=$1 # current url of file
    svn log -q $url | grep -E -e "^r[[:digit:]]+" -o | cut -c2- | sort -n | {

#       first revision as full text
        echo
        read r
        svn log -r$r $url@HEAD
        svn cat -r$r $url@HEAD
        echo

#       remaining revisions as differences to previous revision
        while read r
        do
            echo
            svn log -r$r $url@HEAD
            svn diff -c$r $url@HEAD
            echo
        done
    }
}


get_mac() {
MACADDR="52:54:00:$(dd if=/dev/urandom bs=512 count=1 2>/dev/null \
    | md5sum \
    | sed 's/^\(..\)\(..\)\(..\).*$/\1:\2:\3/')"
echo $MACADDR
}


countdown() {
  t=$1
  for x in `seq $t -1 1`; do echo -n "$x "; sleep 1; done && mplayer -af volume=-10 ~/Downloads/beep-07.mp3
}

pynew() {
  name=$1
  if [ -z "$name" ]; then
    echo "please provide a name for file"
    return 1
  fi
  if [ -f "$name" ]; then
    echo "file already exists"
  else
    echo -e "#!/usr/bin/env python3\n\n\nif __name__ == '__main__':\n  \n  " >> $name
    chmod 755 $name
  fi
  vim $name
}

myfind() {
  find -name ${1}*;
}


orphans() {
  if [[ ! -n $(pacman -Qdt) ]]; then
    echo "No orphans to remove."
  else
    sudo pacman -Rns $(pacman -Qdtq)
  fi
}



##########
# COLORS #
##########

# colors from https://wiki.archlinux.org/index.php/Color_Bash_Prompt
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
bakgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset


##########
# PROMPT #
##########

#useful variables for PS1
#from https://gist.github.com/wyattanderson/1264760
if [[ $TERM =~ "256color" ]]; then
    host_color="38;5;$((16 + $(echo $HOSTNAME | cksum | cut -c8-10) % 256))";
else
    host_color="1;$((31 + $(echo $HOSTNAME | cksum | cut -c8-10) % 6))";
fi

if [ $UID == 0 ]; then
    ptr="\[${txtred}\]#\[${txtrst}\] ";
else
    ptr="> ";
fi

reset="\[$txtrst\]"  # reset colors
host="\[\033[${host_color}m\]\h${reset}"

status() {
  if [ $? == 0 ]; then
    #echo -e "${txtgrn}[$?]${txtrst}"
    echo
  else
    echo -e "${txtred}[$?]${txtrst}"
  fi
}

#export PS1="\e[0;34m\h@\W\$\e[m "
#export PS1="\h@\W\$ "
#export PS1="┌─[\t]─[\u@\h]\n└──> \w \$ >> "
#export PS1="[\u@\h] \w\$ "
#if [[ $LANG =~ UTF-8 ]]; then
#    PS1="$reset┌─\$(status)─[\t]─[\u@$host]─[\w]\n└──$ptr"
#else
    PS1="$reset[\t][\u@\h]-[\w]\n--$ptr"
#fi



############################
# START TMUX AUTOMATICALLY #
############################

test -z ${TMUX} && tmux

