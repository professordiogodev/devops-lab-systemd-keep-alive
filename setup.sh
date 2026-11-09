#!/usr/bin/env bash
# Builds the "before" world: Clippy running the fragile way (a background process, no systemd).
# Run with: sudo ./setup.sh   (safe to run again)
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo:  sudo ./setup.sh" >&2; exit 1; }

state="$(systemctl is-system-running 2>/dev/null || true)"
if [ -z "$state" ] || [ "$state" = "offline" ]; then
  echo "systemd is not running in this environment." >&2
  echo "WSL: add '[boot]' + 'systemd=true' to /etc/wsl.conf, then run 'wsl --shutdown' in PowerShell." >&2
  exit 1
fi

echo "==> Installing packages (python3-venv, git, curl)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq python3-venv python3-pip git curl >/dev/null

echo "==> Creating the clippy system user"
id clippy >/dev/null 2>&1 || useradd --system --home /opt/clippy --shell /usr/sbin/nologin clippy

echo "==> Fetching Clippy into /opt/clippy"
if [ ! -d /opt/clippy/.git ]; then
  rm -rf /opt/clippy
  git clone -q https://github.com/professordiogodev/clippy /opt/clippy
fi
if [ ! -x /opt/clippy/venv/bin/uvicorn ]; then
  python3 -m venv /opt/clippy/venv
  /opt/clippy/venv/bin/pip install -q -r /opt/clippy/requirements.txt
fi
chown -R root:root /opt/clippy
chmod -R a+rX /opt/clippy

echo "==> Starting Clippy the fragile way (the way 'it works on my machine' starts)"
pkill -f 'uvicorn api.main:app' 2>/dev/null || true
sleep 1
cd /opt/clippy
sudo -u clippy -H env APP_VERSION=manual-start setsid nohup /opt/clippy/venv/bin/uvicorn api.main:app --host 0.0.0.0 --port 8000 \
  >/tmp/clippy-manual.log 2>&1 &
for i in $(seq 1 20); do
  curl -fs localhost:8000/healthz >/dev/null 2>&1 && break
  sleep 0.5
done
curl -fs localhost:8000/healthz && echo
echo
echo "Clippy is up on port 8000. It is not managed by anything. Open LAB.md and start Part 1."
