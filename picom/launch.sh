#!/bin/sh
if pgrep -x "picom" >/dev/null; then
	killall picom
fi
picom --config ~/.config/picom/picom.conf &
