#!/bin/bash
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

[[ -f ~/.Xresources ]] && xrdb -I$HOME ~/.Xresources

xautolock -locker '/usr/bin/lock.sh' -time 10&
xss-lock -- "/usr/bin/lock.sh"&

exec i3
