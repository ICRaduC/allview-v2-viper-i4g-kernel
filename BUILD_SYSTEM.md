# Allview V2 Viper i4G (MT6735) - Kernel Build System

## Overview

This directory contains kernel sources for the Allview V2 Viper i4G phone (MT6735 SoC).
The build system supports both 32-bit and 64-bit kernel builds.

## Hardware Specifications

| Component | Value |
|-----------|-------|
| **Phone** | Allview V2 Viper i4G |
| **SoC** | MediaTek MT6735 |
| **Display** | 720×1280 HD (ILI9881C) |
| **Touchscreen** | FT8606 |
| **Main Camera** | gc2355 (MIPI RAW) |
| **Secondary Camera** | s5k5e2ya (MIPI RAW) |

## Kernel Versions

| Build | Kernel Version | Architecture | For |
|-------|---------------|--------------|-----|
| **32-bit** | Linux 3.18.19 | ARM (32-bit) | Stock ROM compatibility |
| **64-bit** | Linux 3.18.19 | ARM64 (64-bit) | Custom ROMs (AOSP/LineageOS) |

## Build Scripts

### 64-bit Build (for custom ROMs)
```bash
# Clean build
make distclean

# Build kernel
./build_64bit.sh

# Create boot image
./build_64bit_bootimg.sh
```

### 32-bit Build (for stock ROM)
```bash
# Clean build
make distclean

# Build kernel
./build_32bit.sh

# Create boot image
./build_32bit_bootimg.sh
```

## Build Requirements

### 64-bit Toolchain
```bash
sudo apt install gcc-aarch64-linux-gnu
```

### 32-bit Toolchain
```bash
sudo git clone --depth 1 https://github.com/KudProject/arm-linux-androideabi-4.9.git /opt/arm-linux-androideabi-4.9
```

## Build Parameters

### 64-bit Build Parameters
| Parameter | Value |
|-----------|-------|
| **ARCH** | arm64 |
| **CROSS_COMPILE** | aarch64-linux-gnu- |
| **Defconfig** | allview6735_v2_viper_i4g_64bit_defconfig |
| **DTS** | allview6735_v2_viper_i4g_64bit.dts |
| **Output** | output_64bit/Image.gz-dtb |
| **Boot Image** | boot_64bit.img |

### 32-bit Build Parameters
| Parameter | Value |
|-----------|-------|
| **ARCH** | arm |
| **CROSS_COMPILE** | /opt/arm-linux-androideabi-4.9/bin/arm-linux-androideabi- |
| **Defconfig** | allview6735_v2_viper_i4g_32bit_defconfig |
| **DTS** | allview6735_v2_viper_i4g_32bit.dts |
| **Output** | output_32bit/zImage |
| **Boot Image** | boot_32bit.img |

## Boot Image Parameters

Both 32-bit and 64-bit use the same boot image parameters:

| Parameter | Value |
|-----------|-------|
| **Base** | 0x40000000 |
| **Kernel Offset** | 0x00008000 |
| **Ramdisk Offset** | 0x04000000 (32-bit) / 0x44000000 (64-bit) |
| **Tags Offset** | 0x4e000000 |
| **Page Size** | 2048 |
| **Cmdline** | bootopt=64S3,32N2,64N2 |

## Display (LCM) Configuration

Both builds use the same LCM driver:
- **Driver**: ili9881c_hd720_dsi_vdo_djn
- **Resolution**: 720×1280 (HD)
- **DSI Lanes**: 4
- **DSI Format**: RGB888
- **PLL Clock**: 207 MHz

## Include Symlinks

The build scripts automatically create these symlinks:

**32-bit:**
- `include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit` → `p6601`
- `drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_32bit` → `p6601`

**64-bit:**
- `include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit` → `p6601`
- `drivers/misc/mediatek/include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit` → `p6601`

## Quick Start

### Build 64-bit
```bash
cd allview_mt6735
./build_64bit.sh
./build_64bit_bootimg.sh
fastboot flash boot boot_64bit.img
```

### Build 32-bit
```bash
cd allview_mt6735
./build_32bit.sh
./build_32bit_bootimg.sh
fastboot flash boot boot_32bit.img
```

## Output Files

- **64-bit kernel**: `output_64bit/Image.gz-dtb` (~7.2 MB)
- **32-bit kernel**: `output_32bit/zImage` (~8.0 MB)
- **64-bit boot**: `boot_64bit.img` (~8.6 MB)
- **32-bit boot**: `boot_32bit.img` (~9.5 MB)

## Notes

- Stock ROM uses 32-bit kernel - for stock ROM compatibility, use 32-bit build
- Custom ROMs (AOSP/LineageOS) use 64-bit kernel - use 64-bit build
- The `ramdisk_orig/` directory contains the stock ramdisk
- Driver alignment: Custom drivers must match stock kernel's sysfs paths

## Troubleshooting

### 32-bit Build Errors

If you get errors during 32-bit build, check that:
1. Toolchain is installed at `/opt/arm-linux-androideabi-4.9/`
2. Fingerprint drivers are disabled in defconfig (if causing issues)

### Include Path Errors

If you get errors like `cust_charging.h: No such file or directory`:
- Run the build script which automatically creates symlinks
- Or manually create: `sudo ln -sf p6601 include/mt-plat/mt6735/allview6735_v2_viper_i4g_64bit`
