# Changelog

## v0.1.0

Initial release.

* Buildroot 2026.05.2 via `nerves_system_br` 1.34.4, Erlang/OTP 29
* Linux 7.0.1 from the libre-tegra (grate) tree, as packaged by postmarketOS
* A/B firmware updates by rewriting `extlinux/extlinux.conf` on the FAT boot
  partition, which mainline U-Boot's bootstd reads
* USB gadget Ethernet (CDC-ECM/RNDIS) with fixed MAC addresses
* F2FS application partition, formatted without discard on first boot
* Kernel modules stored uncompressed, so `modprobe` and module autoloading work
* Touch/buttons (evdev), the Wi-Fi power sequence (reset-gpio) and Tegra
  cpufreq built into the kernel
* BCM4330 Wi-Fi (tested: WPA2, DHCP, inbound and outbound) and Bluetooth
  firmware included. The in-firmware WPA supplicant (FWSUP) is disabled,
  because its "connected" event never reaches the host with this firmware.
