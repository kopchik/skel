# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#PROGRAMS TUNNING
export PATH=~/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-7-openjdk/jre}
export HISTTIMEFORMAT='%h %d %H:%M:%S'
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;33'
export EDITOR=vim
export PAGER=`which less`
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#PROMPT
#export PS1="\e[0;34m\h@\W\$\e[m "
#export PS1="\h@\W\$ "
#export PS1="┌─[\t]─[\u@\h]\n└──> \w \$ >> "
export PS1="[\u@\h] \w\$ "

#set * to match all files
shopt -s dotglob

#HISTORY
HISTSIZE=10000
HISTCONTROL=ignoredups:ignorespace
HISTIGNORE='rm *'
shopt -s histappend


#SSH AGENT
export SSH_AUTH_SOCK=~/.ssh/ssh-agent
ssh-add -l 2>&1 >/dev/null #return status 2 is if ssh-add is unable to contact the authentication agent
if [ $? == 2 ]; then
    pkill -TERM -u $(whoami) -x ssh-agent
    echo "starting ssh-agent"; rm -f $SSH_AUTH_SOCK; eval `/usr/bin/ssh-agent -a $SSH_AUTH_SOCK`;
fi


#CHANGE CWD TO HOMEDIR. Workarround for ubuntu bug with working dir in
#x-session
if [ "`pwd`" == "/" ]; then
    cd
fi

#FIX XKB LAYOUT SWITCHING
if [ -n "${XDG_SESSION_PATH}" ]; then
    setxkbmap -option "grp:shift_caps_switch,caps:ctrl_modifier"
fi


#ALIASES
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias mystrace='strace -s 256 -f -o /tmp/mystrace'

alias psl='ps auxww --sort=lstart | sort -r -k3,4 | head -20'

alias mes="ssh exe@messir.net -p26000"
alias mymail="xhost +local:mymail; sudo -H -u mymail ecryptfs-mount-private; sudo -H -u mymail claws-mail"

#alias skype="xhost +local:skype; sudo -H -u skype skype"
#alias skype="xhost +local:skype; sudo -H -u skype ecryptfs-mount-private; sudo -H -u skype skype"
#alias skype="xhost +local:skype; sudo -H -u skype LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so skype"
#alias skype="xhost +local:skype; sudo -H -u skype ecryptfs-mount-private; sudo -H -u skype LD_PRELOAD=/usr/local/lib/v4l1compat.so skype"

alias udperr='watch --differences=cumulative "netstat -s -u | grep \"receive errors\""'
alias flvideo='find /proc/`pgrep -f libflashplayer`/fd/ -lname "/tmp/Fla*"'
alias projector_on='xrandr --output LVDS1 --mode 1024x768 --output VGA1 --auto --same-as LVDS1'
alias projector_off='xrandr --output LVDS1 --auto --output VGA1 --off'

alias sched_1ms="sudo sysctl kernel.sched_min_granularity_ns=100000"
alias sched_10ms="sudo sysctl kernel.sched_min_granularity_ns=1000000"
alias sched_100ms="sudo sysctl kernel.sched_min_granularity_ns=10000000"
alias sched_1000ms="sudo sysctl kernel.sched_min_granularity_ns=100000000"

alias qua="cd /home/exe/repos/phd/drafts/crm_params"
alias benches="cd /home/FILEZ/000_BACK/FILEZ/benches/test_SDAG"
alias site="cd ~exe/repos/utilz/sites/messir.net"
alias crm="cd ~exe/repos/crm/crm3/"
alias hpc="cd ~exe/repos/crm/utilz/hpc_bencher/"
alias p="sudo ping -n -s 100 -i0.1"
alias abslinux="cd /home/sources/abs/testing/linux/src/"
alias iwscan="sudo iwlist scan | less"
b() { echo $1 | sudo tee /sys/class/backlight/acpi_video0/brightness; }



#MISC
# .Xresources handled automatically
#xrdb -merge ~/.Xdefaults


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
for x in `seq $t -1 0`; do echo -n "$x "; sleep 1; done && mplayer -af volume=-10 ~/Downloads/beep-8.mp3
}


#LOCAL TUNING
if [ "`hostname`" == "dhcp089" ]; then
    PROXY="http://proxy.science.unitn.it:3128/"
    export http_proxy=$PROXY
    export ftp_proxy=$PROXY
    export https_proxy=$PROXY
fi
