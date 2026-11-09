#!/usr/bin/env bash
set -euo pipefail

LAB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

rm -rf "$LAB_ROOT/workspace"/* "$LAB_ROOT/logs"/*
mkdir -p "$LAB_ROOT/workspace" "$LAB_ROOT/logs" "$LAB_ROOT/data"

cat > "$LAB_ROOT/data/users.csv" <<'DATA'
id,name,role,active
1,Alice,admin,true
2,Bob,developer,true
3,Charlie,developer,false
4,Diana,designer,true
5,Eve,qa,false
DATA

cat > "$LAB_ROOT/data/app.log" <<'DATA'
2026-07-28T08:00:01 INFO service_started
2026-07-28T08:01:14 INFO user_login user=alice
2026-07-28T08:02:45 WARN disk_usage percent=82
2026-07-28T08:03:12 ERROR database_connection_failed retry=1
2026-07-28T08:03:20 ERROR database_connection_failed retry=2
2026-07-28T08:03:33 INFO database_connection_restored
2026-07-28T08:05:00 WARN memory_usage percent=76
2026-07-28T08:06:18 ERROR api_timeout endpoint=/reports
DATA

cat > "$LAB_ROOT/data/config.env" <<'DATA'
APP_NAME=market-navigator
APP_PORT=3000
APP_ENV=development
DB_HOST=postgres
DB_PORT=5432
FEATURE_AI=true
DATA

cat > "$LAB_ROOT/data/services.txt" <<'DATA'
nginx:running
postgres:running
redis:stopped
worker:running
scheduler:failed
DATA

cat > "$LAB_ROOT/data/backup-source.txt" <<'DATA'
This file represents important application data.
Practice creating backups without touching your real machine.
DATA

printf 'Lab reset completed.\n'
