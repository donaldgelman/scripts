#!/bin/bash
ffmpeg -loop 1 -i "$1" -i "$2.mp3" -c:v libx264 -tune stillimage -c:a aac -b:a 320k -pix_fmt yuv420p -shortest -vf 'scale=360:360:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1' "$2_yt.mp4"
