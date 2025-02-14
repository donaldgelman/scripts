#!/bin/bash

bg_url=$HOME/bin/bg/bgtmp.txt
myphotos=$HOME/bin/bg/my_photos.txt


bg() {
	randpic=$(shuf -n 1 "$myphotos")
	echo "$randpic" > "$bg_url"
	feh --bg-max "$randpic"
}

bg_remove() {
	if [ -s "$bg_url" ]; then
		grep -vFf "$bg_url" "$myphotos" > temp.txt && mv temp.txt "$myphotos"
		echo "removed $bg_url"
	else
		echo "$bg_url is empty"
		exit 1
	fi
}

if [[ $# -eq 0 ]]; then
    bg
else
    if [[ "$1" == "remove" ]]; then
        bg_remove
    else
        echo "Invalid command. Use 'bg' or 'bg remove'."
        exit 1
    fi
fi
