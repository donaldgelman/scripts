#!/bin/env bash

default_dir="$HOME/Music/"

radio_on () {
        socket="/tmp/mpvrsocket_$(date +%s%N)"
	playlist=$(find "$@" -name '*mp3' -o -name '*flac' -o -name '*wav' | shuf)
	track_1=$(echo "$playlist" | head -1)
	length=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$track_1" | awk 'BEGIN {FS="."}{print $1}')
	start=$(shuf -i 0-$length -n 1)
	echo "$playlist" | tail -n +2 | mpv --no-video --no-terminal --input-ipc-server=$socket --start=$start "$track_1" --{ --start=0 --playlist=- --}
}

radio_off () {
	for socket in /tmp/mpvr*; do
		if socat -u OPEN:/dev/null UNIX-CONNECT:"$socket" 2>/dev/null; then
			echo 'quit' | socat - $socket
		fi
		rm $socket
	done
}

if [ $# -eq 0 ]; then
	radio_on "$default_dir"
elif [ "$1" = "radio_off" ]; then
	radio_off
else
	radio_on "$@"
fi
