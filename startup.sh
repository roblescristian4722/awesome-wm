#!/bin/bash
setxkbmap -layout latam
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Natural Scrolling Enabled" 1
picom -b
