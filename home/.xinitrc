#!/bin/sh
#
# ~/.xinitrc
#
xrdb ~/.Xresources
xinput --set-prop 'Razer  Razer Abyssus' 'Device Accel Constant Deceleration' 2 &
exec i3
