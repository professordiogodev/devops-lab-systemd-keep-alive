#!/usr/bin/env bash
# Break things on purpose.
#   sudo ./chaos.sh reboot   simulate a reboot: every process that systemd does not manage dies
#   sudo ./chaos.sh kill     kill -9 the Clipstr process, whoever started it
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo" >&2; exit 1; }
case "${1:-}" in
  reboot)
    echo "Simulating a reboot at $(date +%T) ..."
    if systemctl is-active --quiet clipstr 2>/dev/null; then
      echo "(clipstr.service is managed by systemd, so a real reboot would start it again at boot)"
      systemctl restart clipstr; echo "service restarted as a reboot would"
    else
      pkill -9 -f 'uvicorn api.main:app' && echo "Clipstr process killed. Nothing will bring it back."
    fi ;;
  kill)
    pkill -9 -f 'uvicorn api.main:app' && echo "kill -9 sent at $(date +%T)" || echo "no Clipstr process found" ;;
  *) echo "usage: sudo ./chaos.sh reboot|kill"; exit 1 ;;
esac
