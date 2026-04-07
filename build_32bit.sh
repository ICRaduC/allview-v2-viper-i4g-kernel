#!/bin/bash
# 32-bit Kernel Build Script for Allview V2 Viper i4G (MT6735)
# Usage: ./build_32bit.sh
set -e

KERNEL_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$KERNEL_DIR/output_32bit"
TOOLCHAIN_PREFIX="/opt/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"

echo "=== Building 32-bit Kernel for MT6735 ==="

# Check if toolchain is available
if ! command -v ${TOOLCHAIN_PREFIX}gcc &> /dev/null; then
    echo "ERROR: ${TOOLCHAIN_PREFIX}gcc not found."
    echo "Please run: sudo git clone --depth 1 https://github.com/KudProject/arm-linux-androideabi-4.9.git /opt/arm-linux-androideabi-4.9"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
cd "$KERNEL_DIR"

# Clean if needed
if [ "$1" = "clean" ]; then
    echo "Cleaning..."
    make ARCH=arm CROSS_COMPILE=${TOOLCHAIN_PREFIX} distclean
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

# Configure
echo "Configuring 32-bit kernel..."
make ARCH=arm CROSS_COMPILE=${TOOLCHAIN_PREFIX} allview6735_v2_viper_i4g_32bit_defconfig

# Build
echo "Building 32-bit kernel..."
make ARCH=arm CROSS_COMPILE=${TOOLCHAIN_PREFIX} -j$(nproc)

# Check output
if [ -f "arch/arm/boot/zImage" ]; then
    echo "=== Build Successful ==="
    cp arch/arm/boot/zImage "$OUTPUT_DIR/"
    echo "Output: $OUTPUT_DIR/zImage ($(ls -lh $OUTPUT_DIR/zImage | awk '{print $5}'))"
else
    echo "ERROR: zImage not found"
    exit 1
fi

echo ""
echo "To create boot image:"
echo "  mkbootimg --kernel $OUTPUT_DIR/zImage --ramdisk <ramdisk.img> ..."
