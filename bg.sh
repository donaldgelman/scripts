#!/bin/bash

current=$HOME/bin/bg/bgtmp.txt
myphotos=$HOME/bin/bg/my_photos.txt

randpic=$(shuf -n 1 $myphotos)
echo "$randpic" > $current

bg() {
	feh --bg-max $randpic
}

bg_remove() {
	grep -vFf "$current" $myphotos > temp.txt && mv temp.txt $myphotos
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
