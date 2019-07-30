#!/bin/bash

. tools.sh

detect_media

find_teslacam_dirs() {
	OIFS="$IFS"
	IFS=$'\n'
	for d in /mnt /media; do
		find "$d" -maxdepth 6 -name TeslaCam 2> /dev/null
	done
	IFS="$OIFS"
}

list_saved_clips() {
	OIFS="$IFS"
	IFS=$'\n'
	for d in $(find_teslacam_dirs); do
		find "$d/SavedClips" -maxdepth 1 -type d -name '20*'
	done
	IFS="$OIFS"
}

fix_spaces() {
    cat - | tr ' ' '?'
}

list_saved_clips | fix_spaces