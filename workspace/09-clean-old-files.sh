#!/usr/bin/env bash

set -euo pipefail

path="${1:-}"
time="${2:-}"
mode="${3:-}"

# Validate arguments
if [[ -z "$path" ]]; then
    printf 'Error: path is required\n' >&2
    exit 1
fi

if [[ -z "$time" ]]; then
    printf 'Error: time is required\n' >&2
    exit 1
fi

# Validate directory
if [[ ! -d "$path" ]]; then
    printf 'Error: path does not exist or is not a directory: %s\n' "$path" >&2
    exit 1
fi

# Validate time
if ! [[ "$time" =~ ^[0-9]+$ ]] || [[ "$time" -le 0 ]]; then
    printf 'Error: time must be a positive integer: %s\n' "$time" >&2
    exit 1
fi

# Protect important directories
case "$path" in
    ''|/|/etc|/etc/*|/usr|/usr/*|/var|/var/*)
        printf 'Error: refusing unsafe target directory: %s\n' "$path" >&2
        exit 1
        ;;
esac

# Validate mode
if [[ -n "$mode" && "$mode" != "--dry-run" ]]; then
    printf 'Error: invalid mode: %s\n' "$mode" >&2
    exit 1
fi

count=0

while IFS= read -r -d '' file; do
    if [[ "$mode" == "--dry-run" ]]; then
        printf 'Would delete: %s\n' "$file"
    else
        rm -f -- "$file"
        printf 'Deleted: %s\n' "$file"
    fi

    ((count++))
done < <(find "$path" -type f -mtime +"$time" -print0)

printf 'Done. %d files found and processed.\n' "$count"