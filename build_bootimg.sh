#!/bin/bash
# Allview V2 Viper i4G (MT6735) - Build Boot Image Script
# This script creates a ready-to-flash boot.img from the built kernel
#
# Usage: ./build_bootimg.sh
# Must be run from kernel source root (allview_mt6735/)
#
# Prerequisites:
#   1. Kernel must be built: make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
#   2. Original ramdisk extracted from stock boot.img to ramdisk_orig/
#   3. abootimg and mkbootimg tools installed
#
# Output: boot_allview_viper_i4g.img in current directory

set -e

KERNEL_DIR="$(cd "$(dirname "$0")" && pwd)"
RAMDISK_ORIG="$KERNEL_DIR/ramdisk_orig"
RAMDISK_FIXED="/tmp/fixed_ramdisk.img"
KERNEL_IMAGE="$KERNEL_DIR/arch/arm64/boot/Image.gz-dtb"
OUTPUT_BOOT="boot_allview_viper_i4g.img"

echo "=== Allview V2 Viper i4G Boot Image Builder ==="

# Check if kernel is built
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "ERROR: Kernel not built. Run 'make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-' first."
    exit 1
fi

# Check if ramdisk exists
if [ ! -d "$RAMDISK_ORIG" ]; then
    echo "ERROR: ramdisk_orig/ directory not found. Extract ramdisk from stock boot.img."
    exit 1
fi

echo "Step 1: Fix ramdisk structure (move files from subfolder to root)..."
cd /tmp
rm -rf rdfix
mkdir rdfix
cd rdfix
zcat "$KERNEL_DIR/ramdisk_new.cpio.gz" 2>/dev/null | cpio -idmv 2>/dev/null || \
    (cd "$RAMDISK_ORIG" && find . | cpio -H newc -o | gzip -9 > "$RAMDISK_FIXED")
cd ramdisk_orig
find . | cpio -H newc -o | gzip -9 > "$RAMDISK_FIXED"
echo "      Ramdisk fixed: $(ls -lh $RAMDISK_FIXED | awk '{print $5}')"

echo "Step 2: Create boot image with mkbootimg..."
cd "$KERNEL_DIR"
mkbootimg --kernel "$KERNEL_IMAGE" \
           --ramdisk "$RAMDISK_FIXED" \
           --cmdline "bootopt=64S3,32N2,64N2 androidboot.hardware=mt6735 vmalloc=496M slub_max_order=0 slub_debug=O console=ttyMT3,921600n1" \
           --base 0x40000000 \
           --kernel_offset 0x00008000 \
           --ramdisk_offset 0x04000000 \
           --tags_offset 0x4e000000 \
           --pagesize 2048 \
           --output "$OUTPUT_BOOT"

echo "Step 3: Fix load addresses with abootimg..."
abootimg -u "$OUTPUT_BOOT" -c "kerneladdr=0x40080000" -c "tagsaddr=0x4e000000"

echo "=== Boot image created successfully! ==="
echo "Output: $OUTPUT_BOOT"
abootimg -i "$OUTPUT_BOOT" | grep -E "kernel|ramdisk|tags|cmdline"

echo ""
echo "To flash to device:"
echo "  fastboot flash boot $OUTPUT_BOOT"
echo "  fastboot reboot"