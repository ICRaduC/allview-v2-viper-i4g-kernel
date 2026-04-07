#!/bin/bash
# 64-bit Kernel Build Script for Allview V2 Viper i4G (MT6735)
# Usage: ./build_64bit.sh
set -e

KERNEL_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$KERNEL_DIR/output_64bit"
TOOLCHAIN_PREFIX="aarch64-linux-gnu-"

echo "=== Building 64-bit Kernel for MT6735 ==="

# Check if toolchain is available
if ! command -v ${TOOLCHAIN_PREFIX}gcc &> /dev/null; then
    echo "ERROR: ${TOOLCHAIN_PREFIX}gcc not found. Install with:"
    echo "  sudo apt install gcc-aarch64-linux-gnu"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
cd "$KERNEL_DIR"

# Clean if needed
if [ "$1" = "clean" ]; then
    echo "Cleaning..."
    make ARCH=arm64 CROSS_COMPILE=${TOOLCHAIN_PREFIX} distclean
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

# Configure
echo "Configuring 64-bit kernel..."
make ARCH=arm64 CROSS_COMPILE=${TOOLCHAIN_PREFIX} allview6735_v2_viper_i4g_64bit_defconfig

# Build
echo "Building 64-bit kernel..."
make ARCH=arm64 CROSS_COMPILE=${TOOLCHAIN_PREFIX} -j$(nproc)

# Check output
if [ -f "arch/arm64/boot/Image.gz-dtb" ]; then
    echo "=== Build Successful ==="
    cp arch/arm64/boot/Image.gz-dtb "$OUTPUT_DIR/"
    echo "Output: $OUTPUT_DIR/Image.gz-dtb ($(ls -lh $OUTPUT_DIR/Image.gz-dtb | awk '{print $5}'))"
else
    echo "ERROR: Image.gz-dtb not found"
    exit 1
fi

echo ""
echo "To create boot image:"
echo "  mkbootimg --kernel $OUTPUT_DIR/Image.gz-dtb --ramdisk <ramdisk.img> ..."
