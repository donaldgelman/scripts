#!/bin/env bash

socket=/tmp/mpvrsocket

radio_on () {
	plist=$(find $@ -name *mp3 -o -name *flac -o -name *wav | shuf)

	vid=$(echo "$plist" | head -1)
	length=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$vid" | awk 'BEGIN {FS="."}{print $1}')
	start=$(shuf -i 0-$length -n 1)

	echo "$plist" | tail -n +2 | mpv --no-video --no-terminal --input-ipc-server=$socket --start=$start "$vid" --{ --start=0 --playlist=- --}
}

radio_off () {
	echo 'quit' | socat - $socket
	rm $socket
}

if [ ! -e $socket ]; then
    radio_on "$*"
else
    radio_off
fi
