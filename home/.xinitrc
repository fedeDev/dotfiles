#!/bin/sh
#
# ~/.xinitrc
#

if [ -s ~/.xmodmap ]; then
    xmodmap ~/.xmodmap
fi

xrdb ~/.Xresources
exec i3
