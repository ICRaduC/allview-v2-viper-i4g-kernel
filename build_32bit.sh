#!/bin/bash
# 32-bit Kernel Build Script for Allview V2 Viper i4G (MT6735)
# This script builds a 32-bit ARM kernel for stock ROM compatibility
set -e

KERNEL_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$KERNEL_DIR/output_32bit"
TOOLCHAIN_PREFIX="/opt/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"

echo "=== Building 32-bit Kernel for MT6735 ==="
echo "Kernel: Linux 3.18.19 (32-bit ARM)"
echo "Target: Allview V2 Viper i4G (MT6735)"
echo "Display: 720x1280 HD (ili9881c_hd720_dsi_vdo_djn)"
echo ""

# Check if toolchain is available
if ! command -v ${TOOLCHAIN_PREFIX}gcc &> /dev/null; then
    echo "ERROR: ${TOOLCHAIN_PREFIX}gcc not found."
    echo "Please run: sudo git clone --depth 1 https://github.com/KudProject/arm-linux-androideabi-4.9.git /opt/arm-linux-androideabi-4.9"
    exit 1
fi

# Create symlinks for include paths if they don't exist
echo "Setting up include symlinks..."
if [ ! -L "$KERNEL_DIR/include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit" ]; then
    sudo rm -f "$KERNEL_DIR/include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit" 2>/dev/null || true
    sudo ln -sf p6601 "$KERNEL_DIR/include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit"
fi

if [ ! -L "$KERNEL_DIR/drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit" ]; then
    sudo rm -f "$KERNEL_DIR/drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit" 2>/dev/null || true
    sudo ln -sf p6601 "$KERNEL_DIR/drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit"
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
if [ -f "arch/arm/configs/allview6735_v2_viper_i4g_32bit_defconfig" ]; then
    cp arch/arm/configs/allview6735_v2_viper_i4g_32bit_defconfig .config
    make ARCH=arm CROSS_COMPILE=${TOOLCHAIN_PREFIX} olddefconfig
else
    echo "ERROR: Defconfig not found"
    exit 1
fi

# Build
echo "Building 32-bit kernel..."
make ARCH=arm CROSS_COMPILE=${TOOLCHAIN_PREFIX} -j$(nproc)

# Check output
if [ -f "arch/arm/boot/zImage" ]; then
    echo ""
    echo "=== Build Successful ==="
    cp arch/arm/boot/zImage "$OUTPUT_DIR/"
    echo "Output: $OUTPUT_DIR/zImage ($(ls -lh $OUTPUT_DIR/zImage | awk '{print $5}'))"
else
    echo "ERROR: zImage not found"
    exit 1
fi

echo ""
echo "To create boot image run: ./build_32bit_bootimg.sh"
