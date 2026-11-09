#!/usr/bin/env bash
# Proves the lab environment is gone. Run with: sudo ./verify-teardown.sh
set -uo pipefail
cd "$(dirname "$0")"
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo:  sudo ./verify-teardown.sh" >&2; exit 1; }
pass=0; failn=0
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
no_user() { ! id "$1" >/dev/null 2>&1; }
no_group() { ! getent group "$1" >/dev/null 2>&1; }
no_path() { [ ! -e "$1" ]; }
no_proc() { ! pgrep -f "$1" >/dev/null 2>&1; }
no_listener() { ! ss -ltn 2>/dev/null | grep -qE ":$1\\b"; }

check "clipstr.service is not installed" no_path /etc/systemd/system/clipstr.service
check "clipstr.service is not known to systemd" bash -c "! systemctl list-unit-files 2>/dev/null | grep -q '^clipstr.service'"
check "no uvicorn process is running" no_proc 'uvicorn api.main:app'
check "port 8000 is free" no_listener 8000
check "user clipstr is gone" no_user clipstr
check "/opt/clipstr is gone" no_path /opt/clipstr
check "/etc/clipstr is gone" no_path /etc/clipstr

echo
if [ "$failn" -eq 0 ]; then echo "TEARDOWN VERIFIED ($pass/$pass)"; else echo "NOT CLEAN: $failn leftover(s). Finish the tear down steps and run this again."; fi
exit "$failn"
