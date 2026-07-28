# Bash Practice Lab: 20 Docker-Based Scenarios

This lab gives you 20 practical Bash exercises inside an isolated Ubuntu Docker container. The exercises begin with basic scripting and gradually move toward automation, logging, validation, process handling, networking, and safer scripts.

## 1. Requirements

Install Docker and Docker Compose on your Ubuntu laptop.

Check them:

```bash
docker --version
docker compose version
```

## 2. Start the isolated lab

Open a terminal in this folder and run:

```bash
docker compose build
docker compose run --rm bash-lab
```

You are now inside the container:

```text
root@container:/lab/workspace#
```

Your scripts should normally be created inside:

```text
/lab/workspace
```

The practice data is available in:

```text
/lab/data
```

Logs can be written to:

```text
/lab/logs
```

Exit the container with:

```bash
exit
```

Your `workspace`, `data`, and `logs` directories remain on your laptop, but all commands run inside the container.

## 3. Reset the lab

From inside the container:

```bash
/lab/bin/reset-lab.sh
```

From your laptop:

```bash
docker compose run --rm bash-lab /lab/bin/reset-lab.sh
```

Resetting deletes everything inside `workspace` and `logs`, then recreates the original practice data.

## 4. Recommended script template

Use this template for most exercises:

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
    echo "Start"
}

main "$@"
```

Make scripts executable:

```bash
chmod +x script-name.sh
./script-name.sh
```

Check scripts with ShellCheck:

```bash
shellcheck script-name.sh
```

---

# Level 1: Bash Foundations

## Scenario 1: System Information Report

Create `01-system-info.sh`.

The script must print:

- Current user
- Hostname
- Current date and time
- Linux kernel version
- Current working directory
- Available disk space for `/`

Requirements:

- Use variables for at least three values.
- Add clear labels to the output.
- Print a separator line before and after the report.

Example:

```text
========================
System Information
User: root
Hostname: abc123
...
========================
```

Bonus: accept an optional report title as `$1`.

---

## Scenario 2: Interactive User Greeter

Create `02-greeter.sh`.

The script should:

1. Ask the user for their name.
2. Ask for their role.
3. Print a personalised message.
4. If either answer is empty, print an error and exit with status `1`.

Concepts:

- `read`
- Variables
- `if`
- Exit codes

Bonus: use `${variable:-default}` to provide a default role.

---

## Scenario 3: File or Directory Inspector

Create `03-inspect-path.sh`.

Usage:

```bash
./03-inspect-path.sh /lab/data/users.csv
```

The script must identify whether the supplied path is:

- A regular file
- A directory
- A symbolic link
- Missing

For a file, also print:

- Size in bytes
- Number of lines
- Permissions

For a directory, print the number of direct child entries.

Requirements:

- Validate that exactly one argument was provided.
- Return a non-zero exit code when the path does not exist.

---

## Scenario 4: Safe File Creator

Create `04-create-file.sh`.

Usage:

```bash
./04-create-file.sh notes.txt
```

Behaviour:

- Create the requested file inside `/lab/workspace`.
- Refuse absolute paths such as `/etc/test`.
- Refuse paths containing `..`.
- Do not overwrite an existing file.
- Add a first line containing the creation date.

Concepts:

- Argument validation
- Pattern matching
- Safe paths
- Redirection

---

## Scenario 5: Simple Calculator

Create `05-calculator.sh`.

Usage:

```bash
./05-calculator.sh 12 + 5
./05-calculator.sh 12 / 4
```

Support:

- Addition
- Subtraction
- Multiplication
- Integer division
- Modulo

Requirements:

- Validate that both operands are integers.
- Reject division by zero.
- Use a `case` statement for the operator.

Bonus: add a `--help` option.

---

# Level 2: Files, Text, and Loops

## Scenario 6: Batch File Renamer

Create `06-rename-files.sh`.

First create test files:

```bash
touch report1.txt report2.txt report3.txt
```

The script should rename every `.txt` file in the current directory to:

```text
backup-report1.txt
backup-report2.txt
backup-report3.txt
```

Requirements:

- Use a loop.
- Skip files that already begin with `backup-`.
- Print every rename operation.
- Do not fail when no `.txt` files exist.

Bonus: accept the prefix as an optional argument.

---

## Scenario 7: Active User Reporter

Create `07-active-users.sh` using `/lab/data/users.csv`.

The script must print only active users in this format:

```text
Alice - admin
Bob - developer
Diana - designer
```

Then print:

```text
Total active users: 3
```

Requirements:

- Skip the CSV header.
- Use `while IFS=, read ...` or `awk`.
- Store the count in a variable.

Bonus: allow filtering by role:

```bash
./07-active-users.sh developer
```

---

## Scenario 8: Log Error Summary

Create `08-log-errors.sh` using `/lab/data/app.log`.

The output must include:

- Total `INFO` lines
- Total `WARN` lines
- Total `ERROR` lines
- Each unique error message and its count

Example:

```text
INFO: 4
WARN: 2
ERROR: 3

database_connection_failed: 2
api_timeout: 1
```

Requirements:

- Use `grep`, `awk`, `sort`, and/or `uniq`.
- Handle a missing log file cleanly.

---

## Scenario 9: Old File Cleaner

Create `09-clean-old-files.sh`.

The script should delete regular files older than a specified number of days from a target directory.

Usage:

```bash
./09-clean-old-files.sh /lab/logs 7
```

Safety requirements:

- Refuse `/`, `/etc`, `/usr`, `/var`, and empty paths.
- Require the number of days to be a non-negative integer.
- First support a dry-run mode:

```bash
./09-clean-old-files.sh /lab/logs 7 --dry-run
```

- Print each file before deleting it.

Test file ages with:

```bash
touch -d '10 days ago' /lab/logs/old.log
touch /lab/logs/new.log
```

---

## Scenario 10: Directory Backup

Create `10-backup.sh`.

Usage:

```bash
./10-backup.sh /lab/data /lab/workspace/backups
```

The script must:

- Validate the source directory.
- Create the destination if needed.
- Produce a compressed archive named with a timestamp.
- Print the archive path and size.
- Exit with an error if the archive is empty or missing.

Expected name format:

```text
data-20260728-153000.tar.gz
```

Bonus: keep only the five newest backups.

---

# Level 3: Functions, Validation, and Automation

## Scenario 11: Environment File Loader

Create `11-load-config.sh` using `/lab/data/config.env`.

The script must safely read these values:

- `APP_NAME`
- `APP_PORT`
- `APP_ENV`
- `DB_HOST`
- `DB_PORT`
- `FEATURE_AI`

Then print a configuration summary.

Requirements:

- Verify all required keys exist.
- Validate that ports are numeric and between `1` and `65535`.
- Reject unknown environment values. Allow only:
  - `development`
  - `staging`
  - `production`

Important: do not blindly execute arbitrary file contents with `source` unless you understand the security risk.

Bonus: implement a function named `get_config_value`.

---

## Scenario 12: Service Status Dashboard

Create `12-service-status.sh` using `/lab/data/services.txt`.

Print a table:

```text
SERVICE      STATUS
nginx        running
postgres     running
redis        stopped
worker       running
scheduler    failed
```

Then print totals for:

- Running
- Stopped
- Failed

Exit codes:

- `0` when all services are running
- `1` when one or more services are stopped
- `2` when one or more services have failed

Failed must take priority over stopped.

---

## Scenario 13: Retry a Command

Create `13-retry.sh`.

Usage:

```bash
./13-retry.sh 3 curl -fsS https://example.com
```

The first argument is the maximum number of attempts. Everything after it is the command to execute.

Requirements:

- Validate the attempt count.
- Print the attempt number.
- Stop immediately when the command succeeds.
- Wait two seconds between failures.
- Return the final command's exit code after all attempts fail.

Concepts:

- `shift`
- `"$@"`
- Loops
- Exit status using `$?`

---

## Scenario 14: Parallel Job Runner

Create `14-parallel-jobs.sh`.

The script should start three simulated jobs in parallel:

```bash
sleep 2
sleep 4
sleep 1
```

Each job must:

- Print when it starts.
- Write completion output to a separate log file.
- Run in the background.

The parent script must:

- Store all process IDs.
- Wait for every job.
- Report which jobs succeeded or failed.
- Print the total runtime.

Bonus: make one job fail intentionally and handle it without losing the other results.

---

## Scenario 15: Lock File Protection

Create `15-single-instance.sh`.

The script should simulate a five-second deployment. It must prevent two copies from running simultaneously.

Requirements:

- Use `flock` if available, or safely implement a lock directory.
- Print a clear message when another instance is already running.
- Always release the lock when the script exits.
- Use `trap` for cleanup when appropriate.

Test it by opening two container terminals and running the script in both.

Second terminal:

```bash
docker compose run --rm bash-lab
```

---

# Level 4: DevOps-Style Bash Scenarios

## Scenario 16: HTTP Health Checker

Create `16-health-check.sh`.

Usage:

```bash
./16-health-check.sh https://example.com
```

The script must:

- Accept a URL.
- Use `curl` with a connection timeout.
- Print the HTTP status code.
- Print the response time.
- Return success only for HTTP status codes from `200` to `399`.
- Retry failed requests up to three times.

Bonus: accept multiple URLs from a text file.

---

## Scenario 17: Port Availability Checker

Create `17-check-port.sh`.

Usage:

```bash
./17-check-port.sh example.com 443
```

The script must:

- Validate the hostname and port arguments.
- Use `nc` to test connectivity.
- Timeout after three seconds.
- Print either `OPEN` or `CLOSED`.
- Return `0` for open and `1` for closed.

Local test:

In one container terminal:

```bash
nc -l 8080
```

In another:

```bash
./17-check-port.sh bash-practice-lab 8080
```

Note: separate `docker compose run` containers may not share the same predictable name. You can instead start the service with:

```bash
docker compose up -d
```

Then enter it:

```bash
docker compose exec bash-lab bash
```

---

## Scenario 18: Process Monitor

Create `18-process-monitor.sh`.

Usage:

```bash
./18-process-monitor.sh sleep
```

The script must:

- Check whether a process name is running.
- Print matching PIDs.
- Print process runtime and command.
- Return `0` if found and `1` if not found.

Testing:

```bash
sleep 300 &
./18-process-monitor.sh sleep
```

Bonus: add a `--watch` mode that checks every five seconds until interrupted.

---

## Scenario 19: Mini Deployment Script

Create `19-deploy.sh` to simulate an application deployment.

Required steps:

1. Validate that `/lab/data/config.env` exists.
2. Create a timestamped release directory under `/lab/workspace/releases`.
3. Copy configuration and application data into the release.
4. Write deployment steps to `/lab/logs/deploy.log`.
5. Update a symbolic link named `current` to point to the new release.
6. Keep only the three newest releases.
7. Roll back the incomplete release if any step fails.

Requirements:

- Use functions.
- Use `set -euo pipefail`.
- Use `trap` for failure handling.
- Print a deployment summary.

Bonus: implement:

```bash
./19-deploy.sh --rollback
```

which changes `current` to the previous release.

---

## Scenario 20: Server Audit Report

Create `20-server-audit.sh`.

This is your final project. Generate a text report at:

```text
/lab/logs/server-audit-TIMESTAMP.txt
```

The report must include:

- Date and hostname
- Uptime
- Kernel version
- CPU count
- Memory usage
- Disk usage
- Top five processes by memory
- Listening TCP ports
- Number of files in `/lab/data`
- Number of errors in `/lab/data/app.log`
- Status summary from `/lab/data/services.txt`

Requirements:

- Divide the script into functions.
- Use clear report sections.
- Redirect both normal output and errors appropriately.
- Continue when an optional command is unavailable, but record that fact.
- Print the final report path.
- Run ShellCheck and fix meaningful warnings.

Bonus features:

- Add `--json` output using `jq`.
- Add warning thresholds for disk and memory usage.
- Exit non-zero when a critical threshold is exceeded.

---

# Practice Method

For each scenario:

1. Read the requirements without searching for a complete solution.
2. Write a first version.
3. Test the successful path.
4. Test at least two failure cases.
5. Run ShellCheck.
6. Refactor repeated code into functions.
7. Add `set -euo pipefail` after understanding where it affects the script.

Use this checklist:

```text
[ ] Correct result
[ ] Input validation
[ ] Useful error messages
[ ] Correct exit codes
[ ] Quoted variables
[ ] Handles missing files
[ ] Handles empty input
[ ] ShellCheck reviewed
[ ] Safe to run twice
```

# Useful Docker Commands

Build the image:

```bash
docker compose build
```

Start a temporary isolated container:

```bash
docker compose run --rm bash-lab
```

Start a persistent lab container:

```bash
docker compose up -d
```

Open a shell inside it:

```bash
docker compose exec bash-lab bash
```

Stop and remove the persistent container:

```bash
docker compose down
```

Delete and rebuild everything:

```bash
docker compose down --volumes --remove-orphans
docker compose build --no-cache
```

Because the lab mounts only its own folders, scripts cannot normally modify unrelated files on your laptop. Still avoid mounting sensitive host paths or the Docker socket into the container.
