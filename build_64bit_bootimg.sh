#!/bin/bash
# 64-bit Boot Image Build Script
# Usage: ./build_64bit_bootimg.sh
set -e

KERNEL_DIR="$(cd "$(dirname "$0")" && pwd)"
KERNEL_IMAGE="$KERNEL_DIR/output_64bit/Image.gz-dtb"
RAMDISK_FIXED="/tmp/ramdisk_64bit.img"
OUTPUT_BOOT="$KERNEL_DIR/boot_64bit.img"

echo "=== Building 64-bit Boot Image ==="

# Check if kernel is built
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "ERROR: Kernel not built. Run './build_64bit.sh' first."
    exit 1
fi

# Check if ramdisk exists
if [ ! -d "$KERNEL_DIR/ramdisk_orig" ]; then
    echo "ERROR: ramdisk_orig/ directory not found."
    exit 1
fi

echo "Creating ramdisk..."
cd "$KERNEL_DIR/ramdisk_orig"
find . | cpio -H newc -o | gzip -9 > "$RAMDISK_FIXED"
echo "  Ramdisk: $(ls -lh $RAMDISK_FIXED | awk '{print $5}')"

echo "Creating boot image..."
cd "$KERNEL_DIR"
mkbootimg --kernel "$KERNEL_IMAGE" \
           --ramdisk "$RAMDISK_FIXED" \
           --cmdline "bootopt=64S3,32N2,64N2" \
           --base 0x40000000 \
           --kernel_offset 0x00008000 \
           --ramdisk_offset 0x04000000 \
           --tags_offset 0x4e000000 \
           --pagesize 2048 \
           --output "$OUTPUT_BOOT"

abootimg -u "$OUTPUT_BOOT" -c "kerneladdr=0x40080000" -c "tagsaddr=0x4e000000"

echo "=== Done ==="
echo "Output: $OUTPUT_BOOT"
abootimg -i "$OUTPUT_BOOT" | grep -E "kernel|ramdisk|tags|cmdline"

echo ""
echo "To flash:"
echo "  fastboot flash boot $OUTPUT_BOOT"
