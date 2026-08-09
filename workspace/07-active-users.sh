#!/usr/bin/env bash

set -euo pipefail

csv_file=/lab/data/users.csv
role_filter="${1:-}"
count=0


if [[ ! -f "$csv_file" ]]; then
	printf 'The csv files could not be found: %s\n' "$csv_file"
	exit 1
fi

while IFS=, read -r id name role active; do
	if [[ "$id" == 'id' ]]; then
		continue
	fi

	if [[ "$active" != 'true' ]]; then
		continue
	fi

	if [[ -n "$role_filter" && "$role" != "$role_filter" ]]; then
		continue
	fi

	printf '%s - %s\n' "$name" "$role"
	((count += 1 ))
done < "$csv_file"


printf 'Total active users: %d\n' "$count"


