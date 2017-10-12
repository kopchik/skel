#!/bin/bash

export PATH=$PATH:~/bin
. ~/.profile
. ~/.xcommon

#xhost +local:root
#xhost +local:skype
xhost +local:eiq

#synclient PalmDetect=1
synclient HorizTwoFingerScroll=1
synclient TapButton1=1
#synclient AreaBottomEdge=2000 AreaRightEdge=3100
#synclient MaxTapMove=500 MaxTapTime=300 SingleTapTimeout=300
#synclient FastTaps=1

syndaemon -kd -i0.7 -R &

i3status | dzen2 -ta l -y -1 -expand l &
xautolock -time 5 -locker mylock &
#stalonetray &

autocutsel -selection PRIMARY -fork
autocutsel -fork

/usr/bin/fluxbox
