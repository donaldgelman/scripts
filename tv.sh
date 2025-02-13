#!/bin/env bash

tv () {
	plist=$(find $@ -name *mp4 -o -name *mkv -o -name *avi | shuf)

	vid=$(echo "$plist" | head -1)
	length=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$vid" | awk 'BEGIN {FS="."}{print $1}')
	start=$(shuf -i 0-$length -n 1)

	echo "$plist" | tail -n +2 | mpv --input-ipc-server=/tmp/mpvsocket --mute=yes --start=$start "$vid" --{ --start=0 --playlist=- --}
}

tv $* &
