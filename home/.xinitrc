exec i3

if [ -s ~/.xmodmap ]; then
    xmodmap ~/.xmodmap
fi

xrdb ~/.Xresources
