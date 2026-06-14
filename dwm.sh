#!/bin/sh

mkdir -p ~/.logs

exec > ~/.logs/xsession 2>&1

numlockx on

xset -dpms
xset s off
xset b off

xrdb ~/.Xresources

xrandr --output HDMI-1 --right-of eDP-1

[ -e /tmp/dwm.fifo ] && rm /tmp/dwm.fifo
mkfifo /tmp/dwm.fifo

playerctld daemon

XDG_MENU_PREFIX=arch- kbuildsycoca6

picom &
pid_picom=$!

dunst &
pid_dunst=$!

feh --no-fehbg --bg-scale ~/Pictures/wallpaper/3d-tech.jpg

while true; do
	dates=$(date '+%a %d %b %H:%M:%S')
	volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '
	{
		v=int($2*100)
		if ($3=="[MUTED]") printf "MUTED"
		else printf "%d%%", v
	}')
	battery=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "AC")
	xsetroot -name ":$dates :$volume :$battery"
	sleep 1
done &
pid_xsetroot=$!

cleanup() {
	kill "$pid_picom" "$pid_dunst" "$pid_xsetroot" 2>/dev/null
}

trap cleanup EXIT

dwm 2> ~/.logs/dwm
