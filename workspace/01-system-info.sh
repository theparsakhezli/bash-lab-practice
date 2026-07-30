#!/usr/bin/env bash
set -euo pipefail

title="${1:-System Information}"
CurrentUser=$(whoami)
Hostname=$(hostname)
Today=$(date)
LinuxData=$(uname -a)
CWD=$(pwd)
Space=$(df -h /)
echo "=========================="
echo "$title"
echo "User: $CurrentUser"
echo "Hostname: $Hostname"
echo "Today: $Today"
echo "Linux data: $LinuxData"
echo "Current working directory: $CWD"
echo "Available space: $Space"
echo "========================="



