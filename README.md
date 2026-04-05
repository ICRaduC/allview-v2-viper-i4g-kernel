# Allview V2 Viper i4G (MT6735) Custom Kernel

Custom Linux kernel for Allview V2 Viper i4G phone with MT6735 SoC.

## Device Specifications

| Component | Specification |
|-----------|---------------|
| SoC | MediaTek MT6735 (ARM Cortex-A53, 4 cores) |
| RAM | 2GB |
| Display | 720x1280 HD |
| Storage | 16GB eMMC |
| Camera | gc2355 (main) + s5k5e2ya (secondary) |
| Touchscreen | FocalTech FT8606 |
| Android | 5.1 (Lollipop) |

## Kernel Information

- **Version**: Linux 3.18.19
- **Architecture**: ARM64 (AArch64)
- **Compiler**: GCC 9.4+ (aarch64-linux-gnu-)

## Features

- ✅ MT6735 SoC (correct CPU cores, eMMC, GIC)
- ✅ gc2355 + s5k5e2ya camera sensor drivers
- ✅ FocalTech FT8606 touchscreen driver (dedicated)
- ✅ 720x1280 HD display (r63417 LCM)
- ✅ USB gadget stack (ADB, MTP, RNDIS)
- ✅ Real USB20 PLL implementation
- ✅ No stubs - real MTK drivers

## Requirements

### Hardware
- Linux x86_64 host machine
- USB cable for fastboot/BROM mode
- Serial cable for UART debug (optional)

### Software

#### 1. Install ARM64 Cross Compiler
```bash
# Ubuntu/Debian
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# Or from ARM's website
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz
tar -xf gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz
export PATH=$PWD/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin:$PATH
```

#### 2. Install Build Tools
```bash
# Ubuntu/Debian
sudo apt-get install build-essential git bc bison flex libssl-dev libncurses5-dev
```

## Build Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/ICRaduC/allview-v2-viper-i4g-kernel.git
cd allview-v2-viper-i4g-kernel/allview_mt6735
```

### 2. Configure Build Environment
```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
```

### 3. Configure Kernel
```bash
# Use the dedicated Allview defconfig (RECOMMENDED)
make allview6735_v2_viper_i4g_defconfig

# Or use the working tinno defconfig
make tinno6753_65t_m0_defconfig

# Or customize
make menuconfig
```

### 4. Build Kernel
```bash
# Clean build (recommended for first time)
make clean
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-

# Or build just the image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image.gz-dtb
```

### 5. Create Boot Image
```bash
# Extract original ramdisk from stock boot.img first
# Then create boot image with:
mkbootimg --kernel arch/arm64/boot/Image.gz-dtb \
          --ramdisk /path/to/ramdisk.cpio.gz \
          --cmdline "bootopt=64S3,32N2,64N2 androidboot.hardware=mt6735 vmalloc=496M slub_max_order=0 slub_debug=O console=ttyMT3,921600n1" \
          --base 0x40000000 \
          --kernel_offset 0x00008000 \
          --ramdisk_offset 0x04000000 \
          --tags_offset 0x4e000000 \
          --pagesize 2048 \
          --output boot.img
```

### 6. Fix Boot Parameters (Important!)
```bash
# Fix kernel and tags addresses (critical!)
abootimg -u boot.img -c "kerneladdr=0x40080000" -c "tagsaddr=0x4e000000"

# Fix ramdisk structure (files must be at root, not in subfolder)
# This is already handled in the build process
```

## Flash to Device

### Method 1: Fastboot (Recommended)
```bash
# Boot into fastboot mode (power + volume down)
fastboot devices
fastboot flash boot boot.img
fastboot reboot
```

### Method 2: BROM Mode (Full Flash)
```bash
# Enter BROM (power + volume up + volume down)
# Use SP Flash Tool or mtkclient
mtkclient rl /path/to/dump/  # Read all partitions
```

## Critical Boot Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| bootopt | 64S3,32N2,64N2 | Boot mode for MT6735 |
| androidboot.hardware | mt6735 | Android HAL identification |
| console | ttyMT3,921600n1 | Serial console (ttyMT3!) |
| vmalloc | 496M | Memory for VMalloc |
| kernel addr | 0x40080000 | Kernel load address |
| tags addr | 0x4e000000 | ATAGs address (CRITICAL!) |

## Device Tree Configuration

The kernel uses these key configurations:
- **SoC**: CONFIG_ARCH_MT6735=y
- **Camera**: CONFIG_CUSTOM_KERNEL_IMGSENSOR="gc2355_mipi_raw s5k5e2ya_mipi_raw"
- **LCM**: CONFIG_CUSTOM_KERNEL_LCM="r63417_fhd_dsi_cmd_truly_nt50358"
- **Touchscreen**: CONFIG_TINNO_FT8606=y + CONFIG_MTK_TGESTURE=y
- **USB**: CONFIG_USB_MTK_HDRC=y + CONFIG_USB_MTK_OTG=y

## Troubleshooting

### Phone doesn't boot
1. Check serial output for errors (ttyMT3 @ 921600 baud)
2. Verify kernel load address (0x40080000)
3. Verify tags address (0x4e000000) - MOST COMMON ISSUE!
4. Check DTB uses mt6735.dtsi (not mt6753)

### USB not working
1. Ensure androidboot.hardware=mt6735 in cmdline
2. Check CONFIG_USB_MTK_HDRC=y

### Touchscreen not working
1. Verify I2C address in DTS (FT8606 @ 0x38)
2. Check CONFIG_TINNO_FT8606=y

### Display not working
1. Check LCM driver in DTB matches panel
2. Current: r63417_fhd_dsi_cmd_truly_nt50358

## Partition Layout (MT6735)

| Partition | Size | Purpose |
|-----------|------|---------|
| preloader | 4MB | Bootloader stage 1 |
| lk | 512KB | Bootloader |
| boot | 16MB | Kernel + initramfs |
| system | ~2.8GB | Android system |
| userdata | ~11GB | Data partition |

## Tools for Data Extraction

### BROM Mode (Full Access)
- **SP Flash Tool**: Windows tool for reading/writing all partitions
- **mtkclient**: Linux tool for MTK devices

### Fastboot (Limited Access)
```bash
fastboot oem info        # Get device info
fastboot flash recovery recovery.img
fastboot flash boot boot.img
```

## Quick Build Commands

```bash
# Full build from scratch
cd allview_mt6735
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- allview6735_v2_viper_i4g_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)

# Create boot image (after obtaining original ramdisk)
mkbootimg --kernel arch/arm64/boot/Image.gz-dtb \
          --ramdisk ramdisk.cpio.gz \
          --cmdline "bootopt=64S3,32N2,64N2 androidboot.hardware=mt6735 vmalloc=496M slub_max_order=0 slub_debug=O console=ttyMT3,921600n1" \
          --base 0x40000000 --kernel_offset 0x00008000 --ramdisk_offset 0x04000000 --tags_offset 0x4e000000 --pagesize 2048 -o boot.img

# Fix addresses
abootimg -u boot.img -c "kerneladdr=0x40080000" -c "tagsaddr=0x4e000000"
```

## License

This kernel is based on Allview/Mediatek sources. License follows original GPL v2.

## Credits

- Original kernel sources: Allview/Mediatek
- Camera drivers: gc2355, s5k5e2ya from MT6735 sources
- Build fixes and porting: Custom work