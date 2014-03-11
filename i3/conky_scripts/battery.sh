#!/bin/bash
ICONPATH="/home/fede/.i3/stlarch_icons"
COLOR_ICON="#5E6A6B"
BATT_PERC=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage: | grep -o '[0-9][0-9]*')
	BATT_CONN=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep state | grep -o 'discharging')
if [ -d '/sys/class/power_supply/BAT1' ] ; then
  if [ -z "$BATT_CONN" ] ; then
    echo -n "^fg($COLOR_ICON)^i($ICONPATH/ac5.xbm)^fg()`printf %3.0f $BATT_PERC`% |"
  else
    if [[ $BATT_PERC -lt 85 && $BATT_PERC -gt 35 ]] ; then
      echo -n "^fg($COLOR_ICON)^i($ICONPATH/batt5half)^fg()`printf %3.0f $BATT_PERC`% |"
    fi
    if [[ $BATT_PERC -lt 35 ]] ; then
      echo -n "^fg($COLOR_ICON)^i($ICONPATH/batt5empty)^fg()`printf %3.0f $BATT_PERC`% |"
    fi
    if [[ $BATT_PERC -gt 85 ]] ; then
      echo -n "^fg($COLOR_ICON)^i($ICONPATH/batt5full.xbm)^fg()`printf %3.0f $BATT_PERC`% |"
    fi
  fi
fi
