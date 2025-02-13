#!/bin/bash

#create a given number ($3) of audio clips from a given audio or video file ($1) of a given length ($4). Place the clips in $2.

vid=$1

dir=$2

clips=$3

length=$4

vlength=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$vid" | awk 'BEGIN {FS="."}{print $1}')

mkdir $dir

i=1; while [ $i -le $clips ]
do rand=$(shuf -i 0-$vlength -n 1)
   rand2=$(($rand + $length))
   ffmpeg -i "$vid" -ac 2 -ss $rand -to $rand2 $rand.wav
   mv $rand.wav $dir/
   i=$(($i + 1))
done


