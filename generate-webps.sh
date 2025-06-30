#!/bin/bash

USAGE='generate-webps.sh [-d|--delete] FOLDER...

Webp image generator. It converts .png images into resized .webp images.

Options:
  -h / --help          show this message
  -d / --delete        delete .png files after generation
'

. ./sh-setup.sh

delete=

smallerSize () {
    webpinfo "$2" | awk -v div=$(( 2 ** "$1" )) '/Width/ { w = $2 / div } /Height/ { h =  $2 / div } END { print w, h }'
}

while test $# -ne 0
do
    case "$1" in
    -h|--help)
        usage 0
        ;;
    -d|--delete)
        delete="$1"
        ;;
    --)
        shift
        break
        ;;
    -*)
        usage
        ;;
    *)
        break
        ;;
    esac
    shift
done

if test $# -lt 1
then
    usage
fi

for d in "$@"
do
    if ! test -d "$d"
    then
        echo "$d is not a folder!" 1>&2
        continue
    fi

    mkdir -p "$d/high" "$d/normal"

    for f in "$d"/*.png
    do
        high="$d/high/$(basename "${f%.*}.webp")"
        normal="$d/normal/$(basename "${f%.*}.webp")"
        echo "Processing $f"
        cwebp -lossless "$f" -o "$high" -quiet &&
            cwebp -lossless "$high" -resize $(smallerSize 1 "$high") -o "$normal" -quiet &&
            test -n "$delete" && rm -f "$f"
    done
done
