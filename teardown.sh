#!/usr/bin/env bash
# Removes everything the lab created. Run with: sudo ./teardown.sh
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo" >&2; exit 1; }
systemctl disable --now clipstr 2>/dev/null
rm -f /etc/systemd/system/clipstr.service
rm -rf /etc/systemd/system/clipstr.service.d /etc/clipstr
systemctl daemon-reload
pkill -f 'uvicorn api.main:app' 2>/dev/null
rm -rf /opt/clipstr /tmp/clipstr-manual.log
userdel clipstr 2>/dev/null
echo "Lab environment removed."
