#!/bin/bash

merge() {
	ffmpeg \
		-i "$1" \
		-i "$2" \
		-i "$3" \
		-filter_complex "[1:v][0:v]scale2ref=oh*mdar:ih[1v][0v];[2:v][0v]scale2ref=oh*mdar:ih[2v][0v];[0v][1v][2v]hstack=3,scale='2*trunc(iw/2)':'2*trunc(ih/2)'" \
		"$4"
}

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
		find "$d/SavedClips" -maxdepth 1 -type d -name 20*
	done
	IFS="$OIFS"
}

list_n_saved_clips() {
	local select=$1

	OIFS="$IFS"
	IFS=$'\n'
	N=0
	for clip in $(list_saved_clips); do
		if [ x$select == x ] || [ x$select == x$N ]; then
			if [ x$select == x ]; then
				echo -n "$N "
			fi
			echo "$clip"
		fi
		N=$(( $N + 1 ))
	done
	IFS="$OIFS"
}

process_clips() {
	local path="$1"
	local name="$2"
	local output="$3"

	ffmpeg -y -f concat -safe 0 \
		-i <(find "$path" -name "$name" -size +10M -printf "file '%p'\n") \
		-c copy "$output"
}

helpmsg() {
	echo "Usage: tesscam [saved|recent]"
}

if [[ -z $1 ]]; then
	echo "Scanning /mnt and /media for TeslaCam directories"
	helpmsg
elif [ x$1 == xsaved ]; then
	if [[ -z $2 ]]; then
		echo "Select a clip to process like \"tesscam saved 1\""
		list_n_saved_clips
	else
		CLIP="$(list_n_saved_clips $2)"
		process_clips "$CLIP" '*front*' /tmp/front.mp4
		process_clips "$CLIP" '*left_repeater*' /tmp/left_repeater.mp4
		process_clips "$CLIP" '*right_repeater*' /tmp/right_repeater.mp4
		merge /tmp/left_repeater.mp4 /tmp/front.mp4 /tmp/right_repeater.mp4 "$CLIP/tesscam.mp4"
	fi
elif [ x$1 == xrecent ]; then
	echo "Not implemented!"
else
	helpmsg
fi
