# ASUS/Google Nexus 7 (2012) Nerves system

Nerves system for the 2012 Nexus 7 (`grouper`, and the 3G `tilapia`):
NVIDIA Tegra 3 (T30L, 4x Cortex-A9), 1 GB RAM, 16/32 GB eMMC.

| Feature              | Description                                         |
| -------------------- | --------------------------------------------------- |
| CPU                  | Quad-core Cortex-A9 (Tegra 3)                        |
| Memory               | 1 GB DRAM                                           |
| Storage              | eMMC (`/dev/mmcblk0`)                                |
| Linux kernel         | 7.0.1, libre-tegra (grate) tree, as used by postmarketOS |
| IEx terminal         | Tablet screen (`tty1`)                              |
| Networking           | USB gadget Ethernet (`usb0`), Wi-Fi (BCM4330, untested) |
| Bootloader           | Mainline U-Boot (`grouper_defconfig`) in eMMC boot partitions |

## Prerequisites

This system does **not** install a bootloader. The tablet must already run
mainline U-Boot, flashed into the eMMC hardware boot partitions with
fusee-tools and re-crypt. See
<https://codeberg.org/libre-tegra/user-documentation/src/branch/master/asus-google-grouper-tilapia.md>
and U-Boot's `doc/board/asus/grouper.rst`.

## How booting works

* U-Boot's bootstd scans the bootable (first) MBR partition for
  `extlinux/extlinux.conf`.
* The FAT boot partition holds `a/zImage`, `b/zImage` and the device trees for
  each slot. U-Boot picks the device tree for the board revision via
  `$fdtfile` (`grouper-E1565`, `grouper-PM269` or `tilapia-E1565`).
* An upgrade writes the inactive slot, then rewrites `extlinux.conf` to point
  at it. That write is the commit.
* Nerves firmware metadata is stored in U-Boot environment format at 1 MiB
  into the eMMC user area (`/etc/fw_env.config`). U-Boot itself does not
  read it. U-Boot's own environment lives in `mmcblk0boot1` and is left alone.

Limitations:

* No automatic rollback. U-Boot doesn't track boot attempts in this setup,
  so firmware is marked valid as soon as it's written. Manual
  `Nerves.Runtime.revert/0` works.
* Do not add `menu title`, `prompt` or `timeout` to the extlinux files. They
  make U-Boot wait at `Enter choice:`, and the power button sends an empty
  Enter, so the tablet gets stuck.
* Power the tablet on by plugging in USB, or press Power briefly. Holding
  Power through U-Boot can send stray input.

## Installing the first time

Put U-Boot in mass storage mode: hold Volume Down while powering on, then
choose "mount internal storage". The eMMC appears as a USB disk on the host.

```sh
MIX_TARGET=nexus7 mix firmware
MIX_TARGET=nexus7 mix burn    # pick the "UMS disk 0" device
```

After that, `mix upload` over USB networking works as usual.

## Host-side notes

* `mix upload` and `scp`/`sftp` fail with "subsystem request failed" when the
  SSH client forwards locale variables (Ubuntu's `/etc/ssh/ssh_config` has
  `SendEnv LANG LC_* COLORTERM NO_COLOR`). Erlang/OTP 29's SSH server then
  rejects subsystem requests. Unset those variables for the upload, e.g. with
  `upload.sh` in the parent workspace.
* USB gadget Ethernet uses fixed MACs (`02:4e:37:00:00:02` on the tablet,
  `02:4e:37:00:00:01` on the host side), so a NetworkManager profile can be
  bound to `02:4e:37:00:00:01` with `ipv4.method auto`.
* The tablet's USB link uses a 172.31.x.x/30 subnet. Docker networks in
  172.31.0.0/16 shadow it.
