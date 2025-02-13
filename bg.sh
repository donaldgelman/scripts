#!/bin/bash

randpic=$(shuf -n 1 ~/bin/bg/my_photos.txt)
echo "${randpic%.*}" | grep -Eo "\b[^/]*$" > ~/bin/bg/bgtmp.txt
feh --bg-max $randpic
