#!/usr/bin/env bash
# Removes everything the lab created. Run with: sudo ./teardown.sh
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo" >&2; exit 1; }
systemctl disable --now clippy 2>/dev/null
rm -f /etc/systemd/system/clippy.service
rm -rf /etc/systemd/system/clippy.service.d /etc/clippy
systemctl daemon-reload
pkill -KILL -f 'uvicorn api.main:app' 2>/dev/null; sleep 1
rm -rf /opt/clippy /tmp/clippy-manual.log
userdel -f clippy 2>/dev/null
echo "Lab environment removed."
