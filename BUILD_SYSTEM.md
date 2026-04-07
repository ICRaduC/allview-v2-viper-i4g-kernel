# Allview V2 Viper i4G (MT6735) - Kernel Build System

## Overview

This directory contains kernel sources for the Allview V2 Viper i4G phone (MT6735 SoC).
The build system supports both 32-bit and 64-bit kernel builds.

## Build Scripts

### 64-bit Build (Primary - for custom ROMs)
```bash
# Build kernel
./build_64bit.sh

# Create boot image
./build_64bit_bootimg.sh

# Output: boot_64bit.img
```

### 32-bit Build (For stock ROM compatibility)
```bash
# Build kernel
./build_32bit.sh

# Create boot image
./build_32bit_bootimg.sh

# Output: boot_32bit.img
```

### Combined Build (64-bit, default)
```bash
# Build kernel + boot image in one go
./build_bootimg.sh
```

## Requirements

- **64-bit**: `aarch64-linux-gnu-gcc` (install: `sudo apt install gcc-aarch64-linux-gnu`)
- **32-bit**: `arm-linux-gnueabihf-gcc` (install: `sudo apt install gcc-arm-linux-gnueabihf`)
- Tools: `mkbootimg`, `abootimg`

## Kernel Versions

- **Stock**: Linux 3.10.65 (32-bit ARM)
- **Custom**: Linux 3.18.19 (32-bit or 64-bit ARM)

## Boot Image Parameters

| Parameter | Value |
|-----------|-------|
| Base | 0x40000000 |
| Kernel Offset | 0x00008000 |
| Ramdisk Offset | 0x04000000 |
| Tags Offset | 0x4e000000 |
| Page Size | 2048 |
| Cmdline | bootopt=64S3,32N2,64N2 |

## Usage

### Quick Start (64-bit)
```bash
cd allview_mt6735
./build_64bit.sh
./build_64bit_bootimg.sh
fastboot flash boot boot_64bit.img
```

### Quick Start (32-bit)
```bash
cd allview_mt6735
./build_32bit.sh
./build_32bit_bootimg.sh
fastboot flash boot boot_32bit.img
```

## Output Locations

- 64-bit kernel: `output_64bit/Image.gz-dtb`
- 32-bit kernel: `output_32bit/zImage`
- Boot images: `boot_*.img` (in kernel directory)

## Notes

- Stock ROM uses 32-bit kernel (3.10.65). For stock ROM compatibility, use 32-bit build.
- For custom AOSP/LineageOS ROMs, use 64-bit build.
- The `ramdisk_orig/` directory contains the stock ramdisk (extracted from boot.img).
- Driver alignment: Custom drivers must match stock kernel's sysfs paths.
- 32-bit build requires ARM GCC 4.9 toolchain (see below)

## Required Toolchain (32-bit only)

For 32-bit build, you need the ARM GCC 4.9 toolchain:

```bash
sudo git clone --depth 1 https://github.com/KudProject/arm-linux-androideabi-4.9.git /opt/arm-linux-androideabi-4.9
```

The build script automatically uses: `/opt/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-`

## Troubleshooting

### 32-bit Build Errors

If you get errors like `Error: .err encountered` during 32-bit build, this is due to GCC incompatibility.
The Ubuntu `arm-linux-gnueabihf-gcc` (GCC 9+) is not fully compatible with kernel 3.18.

**Solutions:**

1. **Use older GCC** - Install a compatible ARM toolchain (GCC 4.9)
2. **Try different defconfig** - Some configs may work better:
   ```bash
   make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- tinno6735_35u_m0_defconfig
   ```

3. **Build from source** - Build your own ARM toolchain (GCC 4.9.x)

### Required Toolchains

For 32-bit build, ideally use:
- `arm-eabi-` from Android NDK (recommended)
- Or `arm-linux-gnueabi-` from older GCC (4.8-4.9)
