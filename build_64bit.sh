#!/bin/bash
# 64-bit Kernel Build Script for Allview V2 Viper i4G (MT6735)
# This script builds a 64-bit ARM64 kernel for custom ROMs
set -e

KERNEL_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$KERNEL_DIR/output_64bit"
TOOLCHAIN_PREFIX="aarch64-linux-gnu-"

echo "=== Building 64-bit Kernel for MT6735 ==="
echo "Kernel: Linux 3.18.19 (64-bit ARM64)"
echo "Target: Allview V2 Viper i4G (MT6735)"
echo "Display: 720x1280 HD (ili9881c_hd720_dsi_vdo_djn)"
echo ""

# Check if toolchain is available
if ! command -v ${TOOLCHAIN_PREFIX}gcc &> /dev/null; then
    echo "ERROR: ${TOOLCHAIN_PREFIX}gcc not found. Install with:"
    echo "  sudo apt install gcc-aarch64-linux-gnu"
    exit 1
fi

# Create symlinks for include paths if they don't exist
echo "Setting up include symlinks..."
if [ ! -L "$KERNEL_DIR/include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit" ]; then
    sudo rm -f "$KERNEL_DIR/include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit" 2>/dev/null || true
    sudo ln -sf p6601 "$KERNEL_DIR/include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit"
fi

if [ ! -L "$KERNEL_DIR/drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit" ]; then
    sudo rm -f "$KERNEL_DIR/drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit" 2>/dev/null || true
    sudo ln -sf p6601 "$KERNEL_DIR/drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit"
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
    echo ""
    echo "=== Build Successful ==="
    cp arch/arm64/boot/Image.gz-dtb "$OUTPUT_DIR/"
    echo "Output: $OUTPUT_DIR/Image.gz-dtb ($(ls -lh $OUTPUT_DIR/Image.gz-dtb | awk '{print $5}'))"
else
    echo "ERROR: Image.gz-dtb not found"
    exit 1
fi

echo ""
echo "To create boot image run: ./build_64bit_bootimg.sh"
