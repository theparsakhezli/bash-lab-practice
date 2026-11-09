#!/usr/bin/env bash
set -euo pipefail

workspace=/lab/workspace

if (( $# != 1 )); then
    printf 'Usage: %s RELATIVE_FILE_PATH\n' "$0" >&2
    exit 2
fi

requested_path=$1

if [[ -z "$requested_path" ]]; then
    printf 'Error: the file path cannot be empty.\n' >&2
    exit 2
fi

if [[ "$requested_path" == /* ]]; then
    printf 'Error: absolute paths are not allowed.\n' >&2
    exit 1
fi

if [[ "$requested_path" == '..' || "$requested_path" == ../* || "$requested_path" == */../* || "$requested_path" == */.. ]]; then
    printf 'Error: parent-directory traversal is not allowed.\n' >&2
    exit 1
fi

target="$workspace/$requested_path"

if [[ -e "$target" ]]; then
    printf 'Error: file already exists: %s\n' "$target" >&2
    exit 1
fi

mkdir -p "$(dirname "$target")"
printf 'Created on %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" > "$target"
printf 'Created: %s\n' "$target"