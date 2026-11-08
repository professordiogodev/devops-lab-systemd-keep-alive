#!/usr/bin/env bash
# Checks your service. Run with: sudo ./verify.sh | tee evidence/verify.txt
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo:  sudo ./verify.sh" >&2; exit 1; }
pass=0; failn=0
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
prop() { systemctl show clipstr -p "$1" --value; }
healthy() { curl -fs --max-time 2 localhost:8000/healthz; }

echo "== The unit =="
check "clipstr.service exists as a unit file"        test -f /etc/systemd/system/clipstr.service
check "service is active (running)"                  systemctl is-active --quiet clipstr
check "service is enabled (starts at boot)"          systemctl is-enabled --quiet clipstr
check "runs as user clipstr, not root"               test "$(ps -o user= -p "$(prop MainPID)" 2>/dev/null | tr -d ' ')" = clipstr
check "restart policy is on-failure or always"       bash -c "[[ \"\$(systemctl show clipstr -p Restart --value)\" =~ ^(on-failure|always)$ ]]"
check "WorkingDirectory is /opt/clipstr"             test "$(prop WorkingDirectory)" = /opt/clipstr

echo "== The app =="
check "/healthz answers on port 8000"                healthy
check "the app reports a version that is not 'manual-start'" bash -c "healthy() { curl -fs --max-time 2 localhost:8000/healthz; }; v=\$(healthy); [[ \"\$v\" == *version* && \"\$v\" != *manual-start* ]]"
check "the app is a child of systemd, not a loose process" bash -c "systemctl show clipstr -p ControlGroup --value | grep -q 'clipstr.service'"

echo "== Survival =="
if systemctl is-active --quiet clipstr; then
  old=$(prop MainPID); kill -9 "$old" 2>/dev/null; ok=no
  for i in $(seq 1 20); do sleep 0.5; n=$(prop MainPID); [ "$n" != "$old" ] && [ "$n" != 0 ] && healthy >/dev/null && { ok=yes; break; }; done
  check "after kill -9 the service is back and healthy within 10s" test "$ok" = yes
  check "systemd counted the restart (NRestarts >= 1)"  test "$(prop NRestarts)" -ge 1
else
  echo "FAIL  after kill -9 the service is back (service is not running)"; failn=$((failn+1))
fi

echo "== Hardening =="
score=$(systemd-analyze security clipstr --no-pager 2>/dev/null | tail -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
unit_has() { systemctl cat clipstr 2>/dev/null | grep -qE "^$1=(yes|true)"; }
check "NoNewPrivileges=yes is in your unit"          unit_has NoNewPrivileges
check "PrivateTmp=yes is in your unit"               unit_has PrivateTmp
check "exposure score below 6.0 (you got: ${score:-n/a})"  bash -c "awk -v s='${score:-10}' 'BEGIN{exit !(s<6.0)}'"

echo
if [ "$failn" -eq 0 ]; then echo "ALL CHECKS PASSED ($pass/$pass)"; else echo "$failn check(s) failed, $pass passed"; fi
exit "$failn"
