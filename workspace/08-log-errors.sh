#!/usr/bin/env bash

set -euo pipefail


logfile=/lab/data/app.log


if [[ ! -f "$logfile" ]]; then
	printf 'Error: log file not found: %S\n'  "$logfile" >&2
	exit 1
fi

count_level() {
	local level=$1
	awk -v level="$level" '$2 == level {count++} END {print count + 0}' "$logfile"
}
printf 'INFO: %s\n' "$(count_level INFO)"
printf 'WARN: %s\n' "$(count_level WARN)"
printf 'ERROR: %s\n' "$(count_level ERROR)"
printf '\n'

awk '$2 == "ERROR" {print $3}' "$logfile" | sort | uniq -c | awk '{print $2 ": " $1}'
