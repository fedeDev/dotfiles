#!/bin/bash
ICONPATH="/home/fede/.i3/stlarch_icons"
COLOR_ICON="#5E6A6B"
VOL=$(amixer get -D pulse Master | egrep -o "[0-9]+%" | head -n1 | tr -d '%')
MUTE=$(amixer get -D pulse Master | egrep -o "\[on\]" | head -n1)
if [ -n "$MUTE" ] ; then
  echo -n "^fg($COLOR_ICON)^i($ICONPATH/vol1.xbm)^fg()`printf %3.0f $VOL`"
else
  echo -n "^fg($COLOR_ICON)^i($ICONPATH/vol3.xbm)^fg()`printf %3.0f $VOL`"
fi
