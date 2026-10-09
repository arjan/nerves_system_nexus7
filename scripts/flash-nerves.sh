#!/usr/bin/env bash
#
# First-time install of Nerves firmware on the Nexus 7 (2012).
#
# 1. Tablet off. Hold Volume Down and plug in USB (or press Power briefly).
# 2. In the U-Boot menu choose "mount internal storage".
# 3. Run: scripts/flash-nerves.sh path/to/firmware.fw
#
# The script only writes to a disk that looks exactly like U-Boot's mass
# storage export of the tablet's eMMC, and asks before writing.

set -euo pipefail

FW=${1:?usage: $0 firmware.fw}
[ -f "$FW" ] || { echo "Firmware not found: $FW" >&2; exit 1; }

echo "Waiting for the tablet's eMMC (U-Boot \"UMS disk 0\")..."
DEV=""
for _ in $(seq 300); do
    for d in $(lsblk -dnpo NAME,TRAN | awk '$2=="usb"{print $1}'); do
        model=$(lsblk -dno MODEL "$d" | xargs)
        vendor=$(lsblk -dno VENDOR "$d" | xargs)
        size=$(lsblk -dbno SIZE "$d")
        if [ "$model" = "UMS disk 0" ] && [ "$vendor" = "Linux" ] && [ "$size" -lt 70000000000 ]; then
            DEV=$d
        fi
    done
    [ -n "$DEV" ] && break
    sleep 1
done
[ -n "$DEV" ] || { echo "No tablet eMMC found. Is U-Boot in \"mount internal storage\"?" >&2; exit 1; }

if lsblk -nro MOUNTPOINTS "$DEV" | grep -q .; then
    echo "$DEV has mounted partitions. Unmount them first:" >&2
    lsblk -o NAME,MOUNTPOINTS "$DEV" >&2
    exit 1
fi

echo
lsblk -o NAME,SIZE,TRAN,VENDOR,MODEL "$DEV"
echo
echo "Firmware: $FW"
fwup -m -i "$FW" | grep -E 'meta-(product|version|platform|uuid)'
echo
read -r -p "Erase $DEV and install this firmware? Type 'yes': " answer
[ "$answer" = "yes" ] || { echo "Aborted."; exit 1; }

sudo fwup -a -i "$FW" -t complete -d "$DEV" -U
sync
echo
echo "Done. Unplug USB, then plug it in again to boot (don't hold Power)."
