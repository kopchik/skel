~/.xcommon

xhost +local:root
xhost +local:skype

#synclient PalmDetect=1
synclient HorizTwoFingerScroll=1
#synclient AreaBottomEdge=2000 AreaRightEdge=3100
#synclient MaxTapMove=500 MaxTapTime=300 SingleTapTimeout=300
#synclient FastTaps=1

syndaemon -kd -i0.7 -R

i3status | dzen2 -ta l -y -1 -expand l &
#stalonetray &

/usr/bin/fluxbox
