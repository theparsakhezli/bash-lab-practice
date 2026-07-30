#!/usr/bin/env bash

if (( $# != 1 )); then
	printf 'Usage %s PATH\n' "$0" >&2
	exit 2
fi

path=$1

if [ -L "$path" ];then
	printf 'Type: symbolic linl \n'
	printf 'Target: %s\n' "$(readlink "$path")"
elif [ -f  "$path" ]; then
	size=$(stat -c '%s' "$path")
	lines=$(wc -l "$path")
	permissions=$(ls -l "$path")

	printf 'Type: Regular file \n'
	printf 'Size: %s bytes\n' "$size" 
	printf 'Lines: %s lines\n' "$lines"
	printf 'Persmissions: %s\n' "$permissions"
elif [ -d "$path" ];then
    entry_count=$(find "$path" -mindepth 1 -maxdepth 1 | wc -l)

    printf 'Type: directory\n'
    printf 'Direct child entries: %s\n' "$entry_count"
else
    printf 'Error: path does not exist: %s\n' "$path" >&2
    exit 1
fi

