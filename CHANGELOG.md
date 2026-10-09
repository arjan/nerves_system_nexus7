# Changelog

## v0.1.0

Initial release.

* Buildroot 2026.05.2 via `nerves_system_br` 1.34.4, Erlang/OTP 29
* Linux 7.0.1 from the libre-tegra (grate) tree, as packaged by postmarketOS
* A/B firmware updates by rewriting `extlinux/extlinux.conf` on the FAT boot
  partition, which mainline U-Boot's bootstd reads
* USB gadget Ethernet (CDC-ECM/RNDIS) with fixed MAC addresses
* F2FS application partition, formatted without discard on first boot
* BCM4330 Wi-Fi/Bluetooth firmware included (Wi-Fi untested)
