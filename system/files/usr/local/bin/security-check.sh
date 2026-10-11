#!/usr/bin/env bash
# Daily security check — added by Claude Code system-hardening
# Run manually:  sudo /usr/local/bin/security-check.sh
# Strong tamper signal = a package's own binaries/libraries (under /usr,/bin,/boot,...)
# changed checksum or went missing. /etc config files are expected to differ and are
# watched separately by auditd; known auto-regenerated caches are ignored too.
LOG=/var/log/security-check.log
ts() { date '+%Y-%m-%d %H:%M:%S'; }
# Known-benign / expected-to-differ paths (regex):
BENIGN='backup file:|/etc/|__pycache__|\.pyc |/usr/lib/vlc/plugins/plugins\.dat|/usr/bin/sonic |ld\.so\.cache'
{
  echo "==================== $(ts) ===================="
  echo "[*] Verifying package files against the database (pacman -Qkk)..."
  raw=$(LC_ALL=C pacman -Qkk 2>&1)
  strong=$(printf '%s\n' "$raw" \
            | grep -iE "SHA256 checksum mismatch|No such file or directory|Size mismatch" \
            | grep -vE "$BENIGN" || true)
  if [ -n "$strong" ]; then
    echo "[!!] POSSIBLE TAMPERING — package binaries/libraries differ from what was installed:"
    printf '%s\n' "$strong"
  else
    echo "[ok] No tampering: all package binaries & libraries match the database."
  fi
  ncfg=$(printf '%s\n' "$raw" | grep -c 'backup file:')
  echo "[i] ${ncfg} edited config-file differences ignored (expected for /etc files you changed)."
  echo
  echo "[*] Checking for known-vulnerable installed packages (arch-audit)..."
  vulns=$(arch-audit -u 2>/dev/null || true)
  if [ -n "$vulns" ]; then
    echo "[!] Update these packages (known security issues):"; printf '%s\n' "$vulns"
  else
    echo "[ok] No installed packages have known unpatched vulnerabilities."
  fi
  echo "==================== end $(ts) ===================="; echo
} >> "$LOG" 2>&1
tail -n 40 "$LOG" | systemd-cat -t check-sec
