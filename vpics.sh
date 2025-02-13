#!/bin/bash

#create a given number ($2) of jpg images of a given video file ($1).

vid=$1

pics=$2

vlength=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$vid" | awk 'BEGIN {FS="."}{print $1}')

i=1; while [ $i -le $pics ]
do 
    rand=$(shuf -i 0-$vlength -n 1)
    ffmpeg -y -ss $rand -i "$vid" -vframes 1 -q:v 1 $rand.jpg
    i=$(($i + 1))
done

