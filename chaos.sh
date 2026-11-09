#!/usr/bin/env bash
# Break things on purpose.
#   sudo ./chaos.sh reboot   simulate a reboot: every process that systemd does not manage dies
#   sudo ./chaos.sh kill     kill -9 the Clippy process, whoever started it
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo" >&2; exit 1; }
case "${1:-}" in
  reboot)
    echo "Simulating a reboot at $(date +%T) ..."
    if systemctl is-active --quiet clippy 2>/dev/null; then
      echo "(clippy.service is managed by systemd, so a real reboot would start it again at boot)"
      systemctl restart clippy; echo "service restarted as a reboot would"
    else
      pkill -9 -f 'uvicorn api.main:app' && echo "Clippy process killed. Nothing will bring it back."
    fi ;;
  kill)
    pkill -9 -f 'uvicorn api.main:app' && echo "kill -9 sent at $(date +%T)" || echo "no Clippy process found" ;;
  *) echo "usage: sudo ./chaos.sh reboot|kill"; exit 1 ;;
esac
