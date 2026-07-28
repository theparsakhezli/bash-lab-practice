# Bash Practice Lab: Answer Sheet

These are reference solutions for the 20 scenarios in `README.md`.

Try each exercise yourself before reading its answer. There are many valid Bash solutions; these examples prioritise readability, input validation, safe quoting, useful exit codes, and ShellCheck compatibility.

## How to use this answer sheet

Inside the lab container:

```bash
cd /lab/workspace
nano 01-system-info.sh
chmod +x 01-system-info.sh
./01-system-info.sh
shellcheck 01-system-info.sh
```

Copy only the code inside the relevant answer into the matching script file.

---

# Level 1: Bash Foundations

## Answer 1: System Information Report

Create `01-system-info.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

report_title="${1:-System Information}"
current_user="$(id -un)"
host_name="$(hostname)"
current_time="$(date '+%Y-%m-%d %H:%M:%S')"
kernel_version="$(uname -r)"
working_directory="$(pwd)"
disk_available="$(df -h / | awk 'NR == 2 {print $4}')"

printf '%s\n' '========================'
printf '%s\n' "$report_title"
printf 'User: %s\n' "$current_user"
printf 'Hostname: %s\n' "$host_name"
printf 'Date: %s\n' "$current_time"
printf 'Kernel: %s\n' "$kernel_version"
printf 'Working directory: %s\n' "$working_directory"
printf 'Available disk space on /: %s\n' "$disk_available"
printf '%s\n' '========================'
```

Test it:

```bash
./01-system-info.sh
./01-system-info.sh "My Docker Lab"
```

---

## Answer 2: Interactive User Greeter

Create `02-greeter.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

read -r -p "Enter your name: " name
read -r -p "Enter your role: " role

if [[ -z "$name" ]]; then
    printf 'Error: name cannot be empty.\n' >&2
    exit 1
fi

role="${role:-student}"

printf 'Hello, %s! You are practising Bash as a %s.\n' "$name" "$role"
```

This solution uses the bonus default role. To make the role mandatory instead, replace the default assignment with an empty-value check.

Test failure handling:

```bash
printf '\n\n' | ./02-greeter.sh
echo "$?"
```

---

## Answer 3: File or Directory Inspector

Create `03-inspect-path.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )); then
    printf 'Usage: %s PATH\n' "$0" >&2
    exit 2
fi

path=$1

if [[ -L "$path" ]]; then
    printf 'Type: symbolic link\n'
    printf 'Target: %s\n' "$(readlink "$path")"
elif [[ -f "$path" ]]; then
    size_bytes=$(stat -c '%s' "$path")
    line_count=$(wc -l < "$path")
    permissions=$(stat -c '%A' "$path")

    printf 'Type: regular file\n'
    printf 'Size: %s bytes\n' "$size_bytes"
    printf 'Lines: %s\n' "$line_count"
    printf 'Permissions: %s\n' "$permissions"
elif [[ -d "$path" ]]; then
    entry_count=$(find "$path" -mindepth 1 -maxdepth 1 | wc -l)

    printf 'Type: directory\n'
    printf 'Direct child entries: %s\n' "$entry_count"
else
    printf 'Error: path does not exist: %s\n' "$path" >&2
    exit 1
fi
```

Test it:

```bash
./03-inspect-path.sh /lab/data/users.csv
./03-inspect-path.sh /lab/data
./03-inspect-path.sh /missing
```

---

## Answer 4: Safe File Creator

Create `04-create-file.sh`:

```bash
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
```

Test it:

```bash
./04-create-file.sh notes.txt
./04-create-file.sh notes.txt
./04-create-file.sh /etc/test
./04-create-file.sh ../escape.txt
```

---

## Answer 5: Simple Calculator

Create `05-calculator.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s INTEGER OPERATOR INTEGER\n' "$0"
    printf 'Operators: + - * / %%\n'
}

if [[ "${1:-}" == '--help' ]]; then
    usage
    exit 0
fi

if (( $# != 3 )); then
    usage >&2
    exit 2
fi

left=$1
operator=$2
right=$3

integer_pattern='^-?[0-9]+$'

if [[ ! "$left" =~ $integer_pattern || ! "$right" =~ $integer_pattern ]]; then
    printf 'Error: both operands must be integers.\n' >&2
    exit 2
fi

case "$operator" in
    +) result=$((left + right)) ;;
    -) result=$((left - right)) ;;
    '*') result=$((left * right)) ;;
    /)
        if (( right == 0 )); then
            printf 'Error: division by zero is not allowed.\n' >&2
            exit 1
        fi
        result=$((left / right))
        ;;
    %)
        if (( right == 0 )); then
            printf 'Error: modulo by zero is not allowed.\n' >&2
            exit 1
        fi
        result=$((left % right))
        ;;
    *)
        printf 'Error: unsupported operator: %s\n' "$operator" >&2
        usage >&2
        exit 2
        ;;
esac

printf '%s %s %s = %s\n' "$left" "$operator" "$right" "$result"
```

Quote `*` so your shell does not expand it as a filename pattern:

```bash
./05-calculator.sh 12 + 5
./05-calculator.sh 12 / 4
./05-calculator.sh 6 '*' 7
```

---

# Level 2: Files, Text, and Loops

## Answer 6: Batch File Renamer

Create `06-rename-files.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

prefix="${1:-backup-}"
renamed=0

shopt -s nullglob

for file in *.txt; do
    if [[ "$file" == "$prefix"* ]]; then
        printf 'Skipping already-prefixed file: %s\n' "$file"
        continue
    fi

    destination="${prefix}${file}"

    if [[ -e "$destination" ]]; then
        printf 'Skipping %s: destination already exists: %s\n' "$file" "$destination" >&2
        continue
    fi

    printf 'Renaming %s -> %s\n' "$file" "$destination"
    mv -- "$file" "$destination"
    ((renamed += 1))
done

printf 'Renamed files: %d\n' "$renamed"
```

Test it in a temporary directory:

```bash
mkdir -p rename-test
cd rename-test
touch report1.txt report2.txt report3.txt backup-old.txt
../06-rename-files.sh
```

`shopt -s nullglob` makes `*.txt` expand to nothing when no matching files exist.

---

## Answer 7: Active User Reporter

Create `07-active-users.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

csv_file=/lab/data/users.csv
role_filter="${1:-}"
count=0

if [[ ! -f "$csv_file" ]]; then
    printf 'Error: CSV file not found: %s\n' "$csv_file" >&2
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
    ((count += 1))
done < "$csv_file"

printf 'Total active users: %d\n' "$count"
```

Test it:

```bash
./07-active-users.sh
./07-active-users.sh developer
```

---

## Answer 8: Log Error Summary

Create `08-log-errors.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

log_file=/lab/data/app.log

if [[ ! -f "$log_file" ]]; then
    printf 'Error: log file not found: %s\n' "$log_file" >&2
    exit 1
fi

count_level() {
    local level=$1
    awk -v level="$level" '$2 == level {count++} END {print count + 0}' "$log_file"
}

printf 'INFO: %s\n' "$(count_level INFO)"
printf 'WARN: %s\n' "$(count_level WARN)"
printf 'ERROR: %s\n' "$(count_level ERROR)"
printf '\n'

awk '$2 == "ERROR" {print $3}' "$log_file" | sort | uniq -c | awk '{print $2 ": " $1}'
```

Expected result:

```text
INFO: 3
WARN: 2
ERROR: 3

database_connection_failed: 2
api_timeout: 1
```

The original scenario example says `INFO: 4`, but the supplied `app.log` currently contains three `INFO` lines.

---

## Answer 9: Old File Cleaner

Create `09-clean-old-files.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s DIRECTORY DAYS [--dry-run]\n' "$0"
}

if (( $# < 2 || $# > 3 )); then
    usage >&2
    exit 2
fi

target_dir=$1
days=$2
mode="${3:-}"

case "$target_dir" in
    ''|/|/etc|/etc/*|/usr|/usr/*|/var|/var/*)
        printf 'Error: refusing unsafe target directory: %s\n' "$target_dir" >&2
        exit 1
        ;;
esac

if [[ ! -d "$target_dir" ]]; then
    printf 'Error: directory not found: %s\n' "$target_dir" >&2
    exit 1
fi

if [[ ! "$days" =~ ^[0-9]+$ ]]; then
    printf 'Error: days must be a non-negative integer.\n' >&2
    exit 2
fi

if [[ -n "$mode" && "$mode" != '--dry-run' ]]; then
    printf 'Error: unknown option: %s\n' "$mode" >&2
    usage >&2
    exit 2
fi

found=0

while IFS= read -r -d '' file; do
    ((found += 1))

    if [[ "$mode" == '--dry-run' ]]; then
        printf '[DRY RUN] Would delete: %s\n' "$file"
    else
        printf 'Deleting: %s\n' "$file"
        rm -- "$file"
    fi
done < <(find "$target_dir" -type f -mtime "+$days" -print0)

printf 'Matching files: %d\n' "$found"
```

Test it:

```bash
touch -d '10 days ago' /lab/logs/old.log
touch /lab/logs/new.log
./09-clean-old-files.sh /lab/logs 7 --dry-run
./09-clean-old-files.sh /lab/logs 7
```

Note: `find -mtime +7` means strictly more than seven complete 24-hour periods old.

---

## Answer 10: Directory Backup

Create `10-backup.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s SOURCE_DIRECTORY DESTINATION_DIRECTORY\n' "$0"
}

if (( $# != 2 )); then
    usage >&2
    exit 2
fi

source_dir=${1%/}
destination_dir=${2%/}

if [[ ! -d "$source_dir" ]]; then
    printf 'Error: source directory not found: %s\n' "$source_dir" >&2
    exit 1
fi

mkdir -p "$destination_dir"

timestamp=$(date '+%Y%m%d-%H%M%S')
source_name=$(basename "$source_dir")
source_parent=$(dirname "$source_dir")
archive="$destination_dir/${source_name}-${timestamp}.tar.gz"

tar -czf "$archive" -C "$source_parent" "$source_name"

if [[ ! -s "$archive" ]]; then
    printf 'Error: backup archive is missing or empty: %s\n' "$archive" >&2
    exit 1
fi

archive_size=$(du -h "$archive" | awk '{print $1}')
printf 'Backup created: %s\n' "$archive"
printf 'Archive size: %s\n' "$archive_size"

mapfile -t old_backups < <(
    find "$destination_dir" -maxdepth 1 -type f -name "${source_name}-*.tar.gz" \
        -printf '%T@ %p\n' | sort -nr | awk 'NR > 5 {$1=""; sub(/^ /, ""); print}'
)

for old_backup in "${old_backups[@]}"; do
    printf 'Removing old backup: %s\n' "$old_backup"
    rm -- "$old_backup"
done
```

Test it:

```bash
./10-backup.sh /lab/data /lab/workspace/backups
ls -lh /lab/workspace/backups
```

---

# Level 3: Functions, Validation, and Automation

## Answer 11: Environment File Loader

Create `11-load-config.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

config_file=/lab/data/config.env
required_keys=(APP_NAME APP_PORT APP_ENV DB_HOST DB_PORT FEATURE_AI)

declare -A config=()

trim() {
    local value=$1
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

load_config() {
    local line key value

    while IFS= read -r line || [[ -n "$line" ]]; do
        line=$(trim "$line")

        [[ -z "$line" || "$line" == \#* ]] && continue

        if [[ "$line" != *=* ]]; then
            printf 'Error: invalid config line: %s\n' "$line" >&2
            exit 1
        fi

        key=$(trim "${line%%=*}")
        value=$(trim "${line#*=}")

        if [[ ! "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
            printf 'Error: invalid config key: %s\n' "$key" >&2
            exit 1
        fi

        config["$key"]=$value
    done < "$config_file"
}

get_config_value() {
    local key=$1

    if [[ ! -v "config[$key]" ]]; then
        printf 'Error: missing required key: %s\n' "$key" >&2
        exit 1
    fi

    printf '%s' "${config[$key]}"
}

validate_port() {
    local name=$1
    local value=$2

    if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 1 || value > 65535 )); then
        printf 'Error: %s must be between 1 and 65535.\n' "$name" >&2
        exit 1
    fi
}

if [[ ! -f "$config_file" ]]; then
    printf 'Error: config file not found: %s\n' "$config_file" >&2
    exit 1
fi

load_config

for key in "${required_keys[@]}"; do
    get_config_value "$key" > /dev/null
done

app_name=$(get_config_value APP_NAME)
app_port=$(get_config_value APP_PORT)
app_env=$(get_config_value APP_ENV)
db_host=$(get_config_value DB_HOST)
db_port=$(get_config_value DB_PORT)
feature_ai=$(get_config_value FEATURE_AI)

validate_port APP_PORT "$app_port"
validate_port DB_PORT "$db_port"

case "$app_env" in
    development|staging|production) ;;
    *)
        printf 'Error: invalid APP_ENV: %s\n' "$app_env" >&2
        exit 1
        ;;
esac

printf 'Application: %s\n' "$app_name"
printf 'Application address: 0.0.0.0:%s\n' "$app_port"
printf 'Environment: %s\n' "$app_env"
printf 'Database: %s:%s\n' "$db_host" "$db_port"
printf 'AI feature enabled: %s\n' "$feature_ai"
```

This parser treats values as plain data rather than executable shell code.

---

## Answer 12: Service Status Dashboard

Create `12-service-status.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

services_file=/lab/data/services.txt
running=0
stopped=0
failed=0
unknown=0

if [[ ! -f "$services_file" ]]; then
    printf 'Error: services file not found: %s\n' "$services_file" >&2
    exit 1
fi

printf '%-14s %s\n' 'SERVICE' 'STATUS'
printf '%-14s %s\n' '-------' '------'

while IFS=: read -r service status; do
    [[ -z "$service" ]] && continue

    printf '%-14s %s\n' "$service" "$status"

    case "$status" in
        running) ((running += 1)) ;;
        stopped) ((stopped += 1)) ;;
        failed)  ((failed += 1)) ;;
        *)       ((unknown += 1)) ;;
    esac
done < "$services_file"

printf '\nRunning: %d\n' "$running"
printf 'Stopped: %d\n' "$stopped"
printf 'Failed: %d\n' "$failed"
printf 'Unknown: %d\n' "$unknown"

if (( failed > 0 || unknown > 0 )); then
    exit 2
elif (( stopped > 0 )); then
    exit 1
else
    exit 0
fi
```

Check the status code:

```bash
./12-service-status.sh
echo "$?"
```

With the supplied data, it exits with status `2` because `scheduler` is failed.

---

## Answer 13: Retry a Command

Create `13-retry.sh`:

```bash
#!/usr/bin/env bash
set -u
set -o pipefail

usage() {
    printf 'Usage: %s MAX_ATTEMPTS COMMAND [ARGUMENTS...]\n' "$0"
}

if (( $# < 2 )); then
    usage >&2
    exit 2
fi

max_attempts=$1
shift

if [[ ! "$max_attempts" =~ ^[1-9][0-9]*$ ]]; then
    printf 'Error: MAX_ATTEMPTS must be a positive integer.\n' >&2
    exit 2
fi

attempt=1
last_status=0

while (( attempt <= max_attempts )); do
    printf 'Attempt %d/%d: ' "$attempt" "$max_attempts"
    printf '%q ' "$@"
    printf '\n'

    if "$@"; then
        printf 'Command succeeded on attempt %d.\n' "$attempt"
        exit 0
    else
        last_status=$?
        printf 'Command failed with status %d.\n' "$last_status" >&2
    fi

    if (( attempt < max_attempts )); then
        sleep 2
    fi

    ((attempt += 1))
done

printf 'All %d attempts failed.\n' "$max_attempts" >&2
exit "$last_status"
```

`set -e` is intentionally not enabled here because command failures are the behaviour this script needs to capture and retry.

Test it:

```bash
./13-retry.sh 3 bash -c 'exit 1'
./13-retry.sh 3 bash -c 'echo success'
```

---

## Answer 14: Parallel Job Runner

Create `14-parallel-jobs.sh`:

```bash
#!/usr/bin/env bash
set -u
set -o pipefail

log_dir=/lab/logs/parallel-jobs
mkdir -p "$log_dir"

run_job() {
    local name=$1
    local duration=$2
    local should_fail=$3
    local log_file="$log_dir/${name}.log"

    printf '%s started at %s\n' "$name" "$(date '+%H:%M:%S')" > "$log_file"
    sleep "$duration"

    if [[ "$should_fail" == 'true' ]]; then
        printf '%s failed intentionally at %s\n' "$name" "$(date '+%H:%M:%S')" >> "$log_file"
        return 1
    fi

    printf '%s completed at %s\n' "$name" "$(date '+%H:%M:%S')" >> "$log_file"
}

start_time=$SECONDS
pids=()
names=()

jobs=(
    'job-1:2:false'
    'job-2:4:false'
    'job-3:1:true'
)

for definition in "${jobs[@]}"; do
    IFS=: read -r name duration should_fail <<< "$definition"
    printf 'Starting %s in the background.\n' "$name"
    run_job "$name" "$duration" "$should_fail" &
    pids+=("$!")
    names+=("$name")
done

failures=0

for index in "${!pids[@]}"; do
    pid=${pids[$index]}
    name=${names[$index]}

    if wait "$pid"; then
        printf '%s succeeded. Log: %s/%s.log\n' "$name" "$log_dir" "$name"
    else
        status=$?
        printf '%s failed with status %d. Log: %s/%s.log\n' \
            "$name" "$status" "$log_dir" "$name" >&2
        ((failures += 1))
    fi
done

runtime=$((SECONDS - start_time))
printf 'Total runtime: %d seconds\n' "$runtime"
printf 'Failed jobs: %d\n' "$failures"

if (( failures > 0 )); then
    exit 1
fi
```

The total runtime should be roughly four seconds, not seven, because the jobs run concurrently.

---

## Answer 15: Lock File Protection

Create `15-single-instance.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

lock_file=/tmp/bash-practice-deploy.lock

exec 9>"$lock_file"

if ! flock -n 9; then
    printf 'Another deployment is already running.\n' >&2
    exit 1
fi

cleanup() {
    flock -u 9 || true
}

trap cleanup EXIT INT TERM

printf 'Deployment started by PID %d.\n' "$$"
sleep 5
printf 'Deployment completed.\n'
```

For a correct lock test, use one persistent container:

```bash
docker compose up -d
docker compose exec bash-lab bash
```

Open a second host terminal and enter the same container:

```bash
docker compose exec bash-lab bash
```

Run `./15-single-instance.sh` in both shells. Two separate `docker compose run --rm` containers do not share `/tmp`, so they would not share this lock file.

---

# Level 4: DevOps-Style Bash Scenarios

## Answer 16: HTTP Health Checker

Create `16-health-check.sh`:

```bash
#!/usr/bin/env bash
set -u
set -o pipefail

usage() {
    printf 'Usage: %s URL\n' "$0"
}

if (( $# != 1 )); then
    usage >&2
    exit 2
fi

url=$1
max_attempts=3

for ((attempt = 1; attempt <= max_attempts; attempt++)); do
    printf 'Attempt %d/%d: %s\n' "$attempt" "$max_attempts" "$url"

    result=$(curl \
        --silent \
        --show-error \
        --output /dev/null \
        --connect-timeout 3 \
        --max-time 10 \
        --write-out '%{http_code} %{time_total}' \
        "$url" 2>&1)
    curl_status=$?

    if (( curl_status == 0 )); then
        read -r http_status response_time <<< "$result"
        printf 'HTTP status: %s\n' "$http_status"
        printf 'Response time: %ss\n' "$response_time"

        if [[ "$http_status" =~ ^[0-9]{3}$ ]] && (( 10#$http_status >= 200 && 10#$http_status <= 399 )); then
            printf 'Health check passed.\n'
            exit 0
        fi

        printf 'Health check failed because of HTTP status %s.\n' "$http_status" >&2
    else
        printf 'curl failed: %s\n' "$result" >&2
    fi

    if (( attempt < max_attempts )); then
        sleep 2
    fi
done

exit 1
```

Test it:

```bash
./16-health-check.sh https://example.com
./16-health-check.sh http://127.0.0.1:9999
```

---

## Answer 17: Port Availability Checker

Create `17-check-port.sh`:

```bash
#!/usr/bin/env bash
set -u
set -o pipefail

usage() {
    printf 'Usage: %s HOSTNAME PORT\n' "$0"
}

if (( $# != 2 )); then
    usage >&2
    exit 2
fi

host=$1
port=$2

if [[ -z "$host" || "$host" =~ [[:space:]] ]]; then
    printf 'Error: invalid hostname.\n' >&2
    exit 2
fi

if [[ ! "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
    printf 'Error: port must be between 1 and 65535.\n' >&2
    exit 2
fi

if nc -z -w 3 "$host" "$port" 2>/dev/null; then
    printf '%s:%s OPEN\n' "$host" "$port"
    exit 0
else
    printf '%s:%s CLOSED\n' "$host" "$port"
    exit 1
fi
```

A simple same-container test:

```bash
nc -l 8080 >/tmp/nc-test.log 2>&1 &
./17-check-port.sh 127.0.0.1 8080
./17-check-port.sh 127.0.0.1 8081
```

---

## Answer 18: Process Monitor

Create `18-process-monitor.sh`:

```bash
#!/usr/bin/env bash
set -u
set -o pipefail

usage() {
    printf 'Usage: %s PROCESS_NAME [--watch]\n' "$0"
}

if (( $# < 1 || $# > 2 )); then
    usage >&2
    exit 2
fi

process_name=$1
mode="${2:-}"

if [[ -z "$process_name" ]]; then
    printf 'Error: process name cannot be empty.\n' >&2
    exit 2
fi

if [[ -n "$mode" && "$mode" != '--watch' ]]; then
    printf 'Error: unknown option: %s\n' "$mode" >&2
    usage >&2
    exit 2
fi

check_process() {
    local matches

    matches=$(ps -eo pid=,etime=,args= | awk -v name="$process_name" \
        'index($0, name) && $0 !~ /18-process-monitor\.sh/ {print}')

    if [[ -z "$matches" ]]; then
        printf 'Process not found: %s\n' "$process_name"
        return 1
    fi

    printf '%-8s %-12s %s\n' 'PID' 'RUNTIME' 'COMMAND'
    printf '%s\n' "$matches"
    return 0
}

if [[ "$mode" == '--watch' ]]; then
    trap 'printf "\nWatch stopped.\n"; exit 0' INT TERM

    while true; do
        printf '\033[2J\033[H'
        printf 'Process watch: %s | %s\n\n' "$process_name" "$(date '+%H:%M:%S')"
        check_process || true
        sleep 5
    done
else
    check_process
fi
```

Test it:

```bash
sleep 300 &
./18-process-monitor.sh sleep
./18-process-monitor.sh sleep --watch
```

For exact process-name matching in production scripts, investigate `pgrep -x` and `/proc` rather than relying only on textual command matching.

---

## Answer 19: Mini Deployment Script

Create `19-deploy.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

config_file=/lab/data/config.env
source_data=/lab/data
deploy_root=/lab/workspace/releases
current_link=/lab/workspace/current
log_file=/lab/logs/deploy.log
new_release=''
deployment_complete=false

log() {
    local message=$1
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$message" | tee -a "$log_file"
}

cleanup_failed_deployment() {
    local status=$?

    if [[ "$deployment_complete" != true && -n "$new_release" && -d "$new_release" ]]; then
        log "Deployment failed; removing incomplete release: $new_release"
        rm -rf -- "$new_release"
    fi

    exit "$status"
}

list_releases_newest_first() {
    find "$deploy_root" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' \
        | sort -nr \
        | cut -d' ' -f2-
}

prune_old_releases() {
    local release

    mapfile -t old_releases < <(list_releases_newest_first | tail -n +4)

    for release in "${old_releases[@]}"; do
        log "Removing old release: $release"
        rm -rf -- "$release"
    done
}

rollback() {
    local current_target

    mkdir -p "$deploy_root"
    mapfile -t releases < <(list_releases_newest_first)

    if (( ${#releases[@]} < 2 )); then
        printf 'Error: at least two releases are required for rollback.\n' >&2
        exit 1
    fi

    current_target=''
    if [[ -L "$current_link" ]]; then
        current_target=$(readlink -f "$current_link")
    fi

    for release in "${releases[@]}"; do
        if [[ "$release" != "$current_target" ]]; then
            ln -sfn "$release" "$current_link"
            log "Rolled back current link to: $release"
            printf 'Rollback complete: %s\n' "$release"
            return 0
        fi
    done

    printf 'Error: no previous release was found.\n' >&2
    exit 1
}

deploy() {
    if [[ ! -f "$config_file" ]]; then
        printf 'Error: missing config file: %s\n' "$config_file" >&2
        exit 1
    fi

    mkdir -p "$deploy_root" "$(dirname "$log_file")"

    timestamp=$(date '+%Y%m%d-%H%M%S')
    new_release="$deploy_root/release-$timestamp-$$"

    trap cleanup_failed_deployment ERR INT TERM

    log "Creating release directory: $new_release"
    mkdir -p "$new_release/config" "$new_release/data"

    log 'Copying configuration.'
    cp -- "$config_file" "$new_release/config/config.env"

    log 'Copying application data.'
    cp -a -- "$source_data/." "$new_release/data/"

    log 'Writing release metadata.'
    printf 'deployed_at=%s\n' "$(date --iso-8601=seconds)" > "$new_release/RELEASE"

    log 'Updating current symbolic link.'
    ln -sfn "$new_release" "$current_link"

    deployment_complete=true
    trap - ERR INT TERM

    prune_old_releases

    log "Deployment completed: $new_release"
    printf '\nDeployment summary\n'
    printf 'Release: %s\n' "$new_release"
    printf 'Current: %s\n' "$(readlink -f "$current_link")"
    printf 'Log: %s\n' "$log_file"
}

case "${1:-}" in
    '') deploy ;;
    --rollback) rollback ;;
    *)
        printf 'Usage: %s [--rollback]\n' "$0" >&2
        exit 2
        ;;
esac
```

Test several deployments:

```bash
./19-deploy.sh
sleep 1
./19-deploy.sh
sleep 1
./19-deploy.sh
ls -la /lab/workspace/current
find /lab/workspace/releases -maxdepth 1 -type d
./19-deploy.sh --rollback
```

The PID is included in the release name to avoid collisions when two deployments start during the same second.

---

## Answer 20: Server Audit Report

Create `20-server-audit.sh`:

```bash
#!/usr/bin/env bash
set -u
set -o pipefail

output_dir=/lab/logs
services_file=/lab/data/services.txt
app_log=/lab/data/app.log
data_dir=/lab/data
timestamp=$(date '+%Y%m%d-%H%M%S')
report_file="$output_dir/server-audit-$timestamp.txt"

section() {
    printf '\n===== %s =====\n' "$1"
}

run_optional() {
    local command_name=$1
    shift

    if command -v "$command_name" >/dev/null 2>&1; then
        "$@" 2>&1 || printf 'Command failed: %s\n' "$command_name"
    else
        printf 'Command unavailable: %s\n' "$command_name"
    fi
}

write_system_information() {
    section 'SYSTEM INFORMATION'
    printf 'Date: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf 'Hostname: %s\n' "$(hostname)"
    printf 'Kernel: %s\n' "$(uname -r)"
    printf 'CPU count: %s\n' "$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf 'unknown')"
}

write_uptime() {
    section 'UPTIME'
    run_optional uptime uptime
}

write_memory() {
    section 'MEMORY USAGE'
    run_optional free free -h
}

write_disk() {
    section 'DISK USAGE'
    df -h / 2>&1
}

write_top_processes() {
    section 'TOP FIVE PROCESSES BY MEMORY'
    ps -eo pid,user,%mem,%cpu,etime,args --sort=-%mem 2>&1 | head -n 6
}

write_listening_ports() {
    section 'LISTENING TCP PORTS'

    if command -v ss >/dev/null 2>&1; then
        ss -lnt 2>&1
    elif command -v netstat >/dev/null 2>&1; then
        netstat -lnt 2>&1
    else
        printf 'Neither ss nor netstat is available.\n'
    fi
}

write_data_summary() {
    section 'LAB DATA SUMMARY'

    if [[ -d "$data_dir" ]]; then
        printf 'Files in %s: %s\n' "$data_dir" \
            "$(find "$data_dir" -type f | wc -l)"
    else
        printf 'Data directory missing: %s\n' "$data_dir"
    fi

    if [[ -f "$app_log" ]]; then
        printf 'ERROR entries in app.log: %s\n' \
            "$(awk '$2 == "ERROR" {count++} END {print count + 0}' "$app_log")"
    else
        printf 'Application log missing: %s\n' "$app_log"
    fi
}

write_service_summary() {
    section 'SERVICE STATUS SUMMARY'

    if [[ ! -f "$services_file" ]]; then
        printf 'Services file missing: %s\n' "$services_file"
        return
    fi

    awk -F: '
        {count[$2]++}
        END {
            printf "Running: %d\n", count["running"] + 0
            printf "Stopped: %d\n", count["stopped"] + 0
            printf "Failed: %d\n", count["failed"] + 0
        }
    ' "$services_file"
}

main() {
    mkdir -p "$output_dir"

    {
        printf 'BASH PRACTICE LAB SERVER AUDIT\n'
        write_system_information
        write_uptime
        write_memory
        write_disk
        write_top_processes
        write_listening_ports
        write_data_summary
        write_service_summary
    } > "$report_file" 2>&1

    if [[ ! -s "$report_file" ]]; then
        printf 'Error: report was not created correctly.\n' >&2
        exit 1
    fi

    printf 'Audit report created: %s\n' "$report_file"
}

main "$@"
```

Run it:

```bash
./20-server-audit.sh
cat /lab/logs/server-audit-*.txt
shellcheck 20-server-audit.sh
```

Ubuntu's minimal image may not include `ss` or `netstat`. This answer records that limitation instead of crashing, as required by the scenario.

---

# Suggested testing routine

For every answer:

```bash
chmod +x SCRIPT_NAME.sh
shellcheck SCRIPT_NAME.sh
./SCRIPT_NAME.sh
echo "Exit status: $?"
```

Also test bad inputs. For example:

```bash
./05-calculator.sh abc + 2
./09-clean-old-files.sh / 7
./17-check-port.sh localhost 99999
```

## Do not memorise the scripts

Use the answer sheet to compare approaches:

1. Identify what your version already handled correctly.
2. Find one missing validation or failure case.
3. Rewrite that part yourself.
4. Run ShellCheck again.
5. Explain each line aloud before moving to the next exercise.

The goal is not to reproduce these exact scripts. The goal is to understand arguments, quoting, conditions, loops, functions, pipelines, exit statuses, traps, processes, and safe automation well enough to build your own version.
