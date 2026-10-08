#!/bin/sh

set -e

# Copy the fwup includes and per-slot boot configurations to the images dir.
# fwup.conf and fwup-ops.conf both reference them from there.
cp -rf $NERVES_DEFCONFIG_DIR/fwup_include $BINARIES_DIR
cp -f $NERVES_DEFCONFIG_DIR/board/extlinux.a.conf $NERVES_DEFCONFIG_DIR/board/extlinux.b.conf $BINARIES_DIR

# Never discard when formatting. Discard on this eMMC runs at ~3 MB/s, so
# nerves_runtime's first-boot `mkfs.f2fs -f /dev/mmcblk0p4` would keep the eMMC
# busy for over an hour. Rootfs reads stall meanwhile, heart misses its
# deadline and the tablet resets before the format finishes.
if [ -f $TARGET_DIR/usr/sbin/mkfs.f2fs ] && [ ! -f $TARGET_DIR/usr/sbin/mkfs.f2fs.real ]; then
    mv $TARGET_DIR/usr/sbin/mkfs.f2fs $TARGET_DIR/usr/sbin/mkfs.f2fs.real
fi
cat > $TARGET_DIR/usr/sbin/mkfs.f2fs <<'EOF'
#!/bin/sh
# Wrapper installed by nerves_system_nexus7: always format without discard.
exec /usr/sbin/mkfs.f2fs.real -t 0 "$@"
EOF
chmod 755 $TARGET_DIR/usr/sbin/mkfs.f2fs

# Create the fwup ops script to handling eMMC operations at runtime
# NOTE: revert.fw is the previous, more limited version of this. ops.fw is
#       backwards compatible.
mkdir -p $TARGET_DIR/usr/share/fwup
NERVES_SDK_IMAGES=$BINARIES_DIR $HOST_DIR/usr/bin/fwup -c -f $NERVES_DEFCONFIG_DIR/fwup-ops.conf -o $TARGET_DIR/usr/share/fwup/ops.fw
ln -sf ops.fw $TARGET_DIR/usr/share/fwup/revert.fw
