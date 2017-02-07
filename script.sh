#!/bin/bash
myurl=$(sed -n '1p' ~/.myurl.txt)
firefox $myurl &
disper -S &
xset s off &
sleep 15 && xdotool key F11 && xdotool mousemove 9999 9999

for (( ; ; ))
do
sleeptime=$(sed -n '2p' ~/.myurl.txt)
sleep $sleeptime
if pgrep -x update.sh > /dev/null; then
    sleep 2
  elif ping -q -c 1 -W 1 google.com > /dev/null; then 
    xdotool key F11
    xdotool sleep 1
    xdotool key CTRL+l
    myurl=$(sed -n '1p' ~/.myurl.txt) &&
    xdotool type $myurl
    xdotool sleep 1
    xdotool key KP_Enter
    xdotool sleep 1
    xdotool key F11
  else
    nmcli networking off && nmcli networking on
    sleep 5
  fi
    done
