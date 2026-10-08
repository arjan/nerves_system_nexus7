#!/bin/sh

set -e

# Copy the fwup includes and per-slot boot configurations to the images dir.
# fwup.conf and fwup-ops.conf both reference them from there.
cp -rf $NERVES_DEFCONFIG_DIR/fwup_include $BINARIES_DIR
cp -f $NERVES_DEFCONFIG_DIR/board/extlinux.a.conf $NERVES_DEFCONFIG_DIR/board/extlinux.b.conf $BINARIES_DIR

# Create the fwup ops script to handling eMMC operations at runtime
# NOTE: revert.fw is the previous, more limited version of this. ops.fw is
#       backwards compatible.
mkdir -p $TARGET_DIR/usr/share/fwup
NERVES_SDK_IMAGES=$BINARIES_DIR $HOST_DIR/usr/bin/fwup -c -f $NERVES_DEFCONFIG_DIR/fwup-ops.conf -o $TARGET_DIR/usr/share/fwup/ops.fw
ln -sf ops.fw $TARGET_DIR/usr/share/fwup/revert.fw
