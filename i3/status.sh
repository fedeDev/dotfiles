#!/bin/bash
# ------------------------------------------------------
# Dzen settings & Variables
# -------------------------
SLEEP=1
ICONPATH="/home/fede/.i3/stlarch_icons"
BINPATH="/home/fede/.i3"
COLOR_ICON="#285577"
CRIT_COLOR="#ff2c4a"
DZEN_FG="#A0A0A0"
DZEN_BG="#1f1f1f"
HEIGHT=12
WIDTH=1300
X=450
Y=3
BAR_FG="#285577"
BAR_MUTE="#505050"
BAR_BG="#808080"
BAR_H=7
BAR_W=40
FONT="-*-terminus-medium-r-*-*-12-*-*-*-*-*-iso10646-*"
VUP="amixer -c0 -q set Master 2dB+"
VDOWN="amixer -c0 -q set Master 2dB-"
EVENTS="sigusr1=togglehide"
DZEN_GDBAR="gdbar"
DZEN="dzen2 -e $EVENTS -x $X -y $Y -w $WIDTH -h $HEIGHT -fn $FONT -ta right -bg $DZEN_BG -fg $DZEN_FG"

# -------------
# Infinite loop
# -------------
while :; do
sleep ${SLEEP}

# ---------
# Functions
# ---------
Vol ()
{
	VOL=$(amixer get Master | egrep -o "[0-9]+%" | tr -d '%')
	MUTE=$(amixer get Master | egrep -o '\[on\]')
	if [ -n "$MUTE" ] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/vol1.xbm)^fg()" $(expr $VOL - 3 | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -nonl)
	else
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/vol3.xbm)^fg()" $(expr $VOL - 3 | $DZEN_GDBAR -fg $BAR_MUTE -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -nonl)
	fi
	return
}

Mem ()
{
	MEM=$(free -h | grep '-' | awk '{print $4}' | sed s/,/./ | sed s/G//)
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/mem1.xbm)^fg() ${MEM} GB"
	return
}

Temp ()
{
	TEMP=$(acpi -t | awk '{print $4}' | cut -d '.' -f 1 )
		if [[ ${TEMP} -gt 76 ]] ; then
			echo -n "^fg($CRIT_COLOR)^i($ICONPATH/temp1.xbm)^fg($CRIT_COLOR) ${TEMP}°C"
		else
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/temp1.xbm)^fg() ${TEMP}°C"
		fi
	return
}

Disk ()
{
	SDA2=$(df -h / | awk '/\/$/ {print $5}' | tr -d '%')
	#SDB1=$(df -h /home | awk '/home/ {print $5}' | tr -d '%')
	if [[ ${SDA2} -gt 80 ]] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/file1.xbm)^fg() $(echo $SDA2 | $DZEN_GDBAR -fg $CRIT_COLOR -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	else
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/file1.xbm)^fg() $(echo $SDA2 | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	fi
	#if [[ ${SDB1} -gt 80 ]] ; then
		#echo -n " ^fg($COLOR_ICON)^i($ICONPATH/home.xbm)^fg() $(echo $SDB1 | $DZEN_GDBAR -fg $CRIT_COLOR -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	#else
		#echo -n " ^fg($COLOR_ICON)^i($ICONPATH/home.xbm)^fg() $(echo $SDB1 | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	#fi
	return
}

MPD ()
{
	MPDPLAYING=$(mpc | grep -c "playing")
	MPDPAUSED=$(mpc | grep -c "paused")
	MPDINFO=$(mpc | grep -v 'volume:' | head -n1)
	MPDTIME=$(mpc | awk '/\%/ {print $4}' | tr -d "()%")
	if [ $MPDPLAYING -eq 1 ] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/play4.xbm)^fg() ${MPDINFO:0:55} $(echo $MPDTIME | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
	else
		if [ $MPDPAUSED -eq 1 ] ; then
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/pause4.xbm)^fg() ${MPDINFO:0:55}  $(echo $MPDTIME | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
		else
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/stop4.xbm)^fg()"
		fi
	fi
	return
}

Kernel ()
{
	KERNEL=$(uname -a | awk '{print $3}')
	echo -n "Kernel: $KERNEL"
	return
}

Uptime ()
{
	UPTIME=$($BINPATH/uptimepy)
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/upleft7.xbm)^fg(#a0a0a0) ${UPTIME}"
	return
}

Date ()
{
	TIME=$(date +'%b %d %l:%M%P')
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/clock8.xbm)^fg(#a0a0a0) ${TIME} "
	return
}

Between ()
{
    # echo -n " ^fg(#A0A0A0)^r(2x2)^fg() "
    echo -n "  "
	return
}

OSLogo ()
{
	echo -n " ^fg($COLOR_ICON)^i($ICONPATH/arch1.xbm)^fg() "
	return
}

Battery ()
{
	BATT_PERC=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage: | grep -o '[0-9][0-9]*')
	BATT_CONN=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep state | grep -o 'discharging')

	if [ -z "$BATT_CONN" ] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/ac5.xbm)^fg() $BATT_PERC%" # $(echo $BATT_PERC | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
	else
		if [[ $BATT_PERC -lt 85 && $BATT_PERC -gt 35 ]] ; then
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/batt5half.xbm)^fg() $BATT_PERC%" #$(echo $BATT_PERC | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
		fi
		if [[ $BATT_PERC -lt 35 ]] ; then
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/batt5empty.xbm)^fg() $BATT_PERC%" #$(echo $BATT_PERC | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
		fi
		if [[ $BATT_PERC -gt 85 ]] ; then
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/batt5full.xbm)^fg() $BATT_PERC%" #$(echo $BATT_PERC | $DZEN_GDBAR -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
		fi

	fi
}

# -----
# Print
# -----
Print () {
    #OSLogo
    #Kernel
	#Between
    Uptime
	Between
    MPD
	Between
    Temp
	Between
    Mem
  Between
    Disk
  Between
    Vol
  Between
    Battery
  Between
    Date
  echo
  return
}

echo "$(Print)"
done | $DZEN &

