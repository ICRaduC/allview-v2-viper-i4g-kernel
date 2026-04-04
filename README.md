# Allview V2 Viper i4G (MT6735) Custom Kernel

Custom Linux kernel for Allview V2 Viper i4G phone with MT6735 SoC.

## Device Specifications

| Component | Specification |
|-----------|---------------|
| SoC | MediaTek MT6735 (ARM Cortex-A53, 4 cores) |
| RAM | 2GB |
| Display | 720x1280 HD |
| Storage | 16GB eMMC |
| Camera | Samsung S5K5E2YA (5MP) |
| Touchscreen | FocalTech FT8606 |
| Android | 5.1+ (Lollipop/Marshmallow) |

## Kernel Information

- **Version**: Linux 3.18.19
- **Architecture**: ARM64 (AArch64)
- **Compiler**: GCC 9.4+ (aarch64-linux-gnu-)

## Features

- ✅ MT6735 DTB (correct CPU count, eMMC, GIC)
- ✅ Samsung S5K5E2YA camera sensor driver
- ✅ FocalTech FT6x06 touchscreen driver
- ✅ 720x1280 HD display (hx8392a LCM)
- ✅ USB gadget stack (ADB, MTP, RNDIS)
- ✅ USB PHY driver (mt6735)
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
cd allview-v2-viper-i4g-kernel
```

### 2. Configure Build Environment
```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
```

### 3. Configure Kernel
```bash
# Use the included defconfig
make tinno6753_65t_m0_defconfig

# Or customize
make menuconfig
```

### 4. Build Kernel
```bash
# Clean build (recommended)
make clean
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image.gz-dtb
```

### 5. Create Boot Image
```bash
# Requires original ramdisk (extract from stock boot.img)
mkbootimg --kernel arch/arm64/boot/Image.gz-dtb \
          --ramdisk original_ramdisk.bin \
          --cmdline "bootopt=64S3,32N2,64N2 androidboot.hardware=mt6735 vmalloc=496M slub_max_order=0 slub_debug=O console=ttyMT3,921600n1" \
          --base 0x40000000 \
          --kernel_offset 0x00080000 \
          --ramdisk_offset 0x04000000 \
          --tags_offset 0x4e0000 \
          --output boot.img
```

### 6. Fix Load Addresses (if needed)
```bash
abootimg -u boot.img -c "kernel_addr=0x40080000" -c "tags_addr=0x4e000000"
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

## Important Notes

### Critical Boot Parameters
- `bootopt=64S3,32N2,64N2` - Boot mode for MT6735
- `androidboot.hardware=mt6735` - Android HAL identification
- `console=ttyMT3,921600n1` - Serial console (not ttyMT0!)
- kernel_addr = 0x40080000
- tags_addr = 0x4e000000 (NOT 0x40080000!)

### Device Tree Fixes Applied
- CPU cores: 8 → 4 (MT6735 has 4 A53 cores)
- eMMC: mt6753-mmc → mt6735-mmc
- GIC: mediatek,mt6735-gic (correct)
- PSCI: disabled (MT6735 uses mt-boot method)

### Partition Layout (MT6735)
| Partition | Size | Purpose |
|-----------|------|---------|
| preloader | 4MB | Bootloader stage 1 |
| lk | 512KB | Bootloader |
| boot | 16MB | Kernel + initramfs |
| system | ~2.8GB | Android system |
| userdata | ~11GB | Data partition |

## Troubleshooting

### Phone doesn't boot
1. Check serial output for errors (ttyMT3 @ 921600 baud)
2. Verify kernel load address (0x40080000)
3. Verify tags address (0x4e000000)
4. Check DTB uses mt6735.dtsi (not mt6753)

### USB not working
1. Ensure androidboot.hardware=mt6735 in cmdline
2. Check CONFIG_USB_MTK_HDRC=y

### Touchscreen not working
1. Verify I2C address in DTS (FT6x06 @ 0x38)
2. Check CONFIG_TINNO_FT6X06=y

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

## License

This kernel is based on Allview/Mediatek sources. License follows original GPL v2.

## Credits

- Original kernel sources: Allview/Mediatek
- S5K5E2YA driver: Adapted from Lenovo Marino kernel
- Build fixes and porting: Custom work