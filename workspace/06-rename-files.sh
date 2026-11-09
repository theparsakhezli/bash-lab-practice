#!/usr/bin/env bash

set -euo pipefail

path="${1:-}"
prefix="${2:-backup-}"
renamed=0

if [[ -z "$path" ]]; then
    printf 'Usage: %s DIRECTORY [PREFIX]\n' "$0" >&2
    exit 1
fi

if [[ ! -d "$path" ]]; then
    printf 'Error: directory does not exist: %s\n' "$path" >&2
    exit 1
fi

# Make an unmatched *.txt pattern expand to nothing.
shopt -s nullglob

files=("$path"/*.txt)

if (( ${#files[@]} == 0 )); then
    printf 'No .txt files found in: %s\n' "$path"
    exit 0
fi

for file in "${files[@]}"; do
    directory="${file%/*}"
    filename="${file##*/}"

    if [[ "$filename" == "$prefix"* ]]; then
        printf 'Skipping already prefixed file: %s\n' "$file"
        continue
    fi

    destination="${directory}/${prefix}${filename}"

    if [[ -e "$destination" ]]; then
        printf 'Skipping %s: destination already exists: %s\n' \
            "$file" "$destination" >&2
        continue
    fi

    printf 'Renaming: %s -> %s\n' "$file" "$destination"
    mv -- "$file" "$destination"

    ((renamed += 1))
done

printf 'Renamed files: %d\n' "$renamed"
