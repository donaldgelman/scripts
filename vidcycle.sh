#!/bin/bash

#cycles $3 times through randomly selected clips of given duration ($2) of all videos in a given folder ($1)

folder=$1
vidcycle=$HOME/bin/tmp/vidcycle.txt
find $folder -type f \( -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.avi" \) | shuf > $vidcycle

duration=$2

repetitions=$3

echo "# mpv EDL v0" > $HOME/bin/tmp/vidcycle.mpv.edl

start_vidcycle () {

while read line ; do
	length=$(ffprobe -v fatal -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$line" | awk 'BEGIN {FS="."}{print $1}')
	start=$(shuf -i 0-$length -n 1)
	byte_length=$(echo -n "$line" | wc -c)
	escaped_line=$(echo "$line" | sed 's/\\/\\\\/g')
	echo "%$byte_length%$escaped_line,start=$start,length=$duration" >> "$HOME/bin/tmp/vidcycle.mpv.edl"
done < "$vidcycle"
}

for i in $(seq $repetitions); do start_vidcycle; done

mpv --no-audio --loop=yes --really-quiet $HOME/bin/tmp/vidcycle.mpv.edl 
