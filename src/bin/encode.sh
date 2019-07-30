#!/bin/bash

. tools.sh

detect_media

OUT_DIR="${SNAP_USER_COMMON:-$PWD}"

banner() {
    echo "##################################################"
    echo "$@"
    echo "##################################################"
}

merge() {
	ffmpeg -an \
		-i "$1" \
		-i "$2" \
		-i "$3" \
		-filter_complex "[1:v][0:v]scale2ref=oh*mdar:ih[1v][0v];[2:v][0v]scale2ref=oh*mdar:ih[2v][0v];[0v][1v][2v]hstack=3,scale='2*trunc(iw/2)':'2*trunc(ih/2)'" \
		"$4"
}

process_clips() {
	local path="$1"
	local name="$2"
	local output="$3"

	ffmpeg -y -f concat -safe 0 -an \
        -i <(find "$path" -name "$name" -size +10M -printf "file '%p'\n") \
        -c copy "$output"
}

for dir_to_encode in $(cat -); do
    timedate="${dir_to_encode##*/}"

    # I do not like teslas time format
    # YYYY-MM-DD_HH-MM-SS -> YYYY-MM-DD_HH:MM:SS
    hour="${timedate##*_}"
    timedate="${timedate%%_*}_${hour//-/:}"

    if [ ! -f "$OUT_DIR/$timedate.mp4" ]; then
        expanded_path="$(echo $dir_to_encode)"

        banner "Process clips for $timedate"
        process_clips "$expanded_path" '*front*' $OUT_DIR/front.tmp.mp4
        process_clips "$expanded_path" '*left_repeater*' $OUT_DIR/left_repeater.tmp.mp4
        process_clips "$expanded_path" '*right_repeater*' $OUT_DIR/right_repeater.tmp.mp4

        banner "Merge clips for $timedate"
        merge \
            $OUT_DIR/left_repeater.tmp.mp4 \
            $OUT_DIR/front.tmp.mp4 \
            $OUT_DIR/right_repeater.tmp.mp4 \
            "$OUT_DIR/$timedate.mp4"

        rm $OUT_DIR/*.tmp.mp4
    fi
done

