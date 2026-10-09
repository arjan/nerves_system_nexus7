#!/usr/bin/env bash
#
# Upload Nerves firmware to a Nexus 7 over USB networking.
#
# Same as `mix upload`, except that it strips the locale variables that many
# distributions' /etc/ssh/ssh_config forward (SendEnv LANG LC_* ...).
# Erlang/OTP 29's SSH server rejects subsystem requests (fwup, sftp) after
# receiving them.
#
# Usage: scripts/upload.sh firmware.fw [host]

set -euo pipefail

FW=${1:?usage: $0 firmware.fw [host]}
HOST=${2:-nerves.local}
[ -f "$FW" ] || { echo "Firmware not found: $FW" >&2; exit 1; }

unset_args=(-u LANG -u LANGUAGE -u COLORTERM -u NO_COLOR)
for v in $(env | grep -oE '^LC_[A-Z_]+'); do unset_args+=(-u "$v"); done

echo "Uploading $FW to $HOST..."
env "${unset_args[@]}" ssh -T -o ServerAliveInterval=5 -s "$HOST" fwup < "$FW"
