# Stock Kernel vs Custom Kernel Comparison

## Kernel Versions
| Property | Stock | Custom |
|----------|-------|--------|
| Version | Linux 3.10.65 | Linux 3.18.19 |
| Architecture | ARM (32-bit) | ARM/ARM64 |
| Source | Allview | allview_mt6735 |

## Device Nodes (from stock init.rc)

### Block Devices
| Stock Path | Purpose |
|------------|---------|
| /dev/block/platform/mtk-msdc.0/by-name/boot | Boot partition |
| /dev/block/platform/mtk-msdc.0/by-name/recovery | Recovery partition |
| /dev/block/platform/mtk-msdc.0/by-name/nvram | NVRAM |
| /dev/block/platform/mtk-msdc.0/by-name/para | Boot parameters |
| /dev/block/platform/mtk-msdc.0/by-name/logo | Logo |
| /dev/block/platform/mtk-msdc.0/by-name/userdata | User data |

### Hardware Devices
| Stock Path | Driver |
|------------|--------|
| /dev/ampc0 | Audio amplifier |
| /dev/akm8973_aot | Magnetometer (AKM8973) |
| /dev/akm8976_aot | Magnetometer (AKM8976) |
| /dev/alarm | RTC alarm |
| /dev/android_adb | ADB interface |
| /dev/binder | Binder IPC |
| /dev/cam | Camera |
| /dev/ccci* | Modem CCCI |
| /dev/ccci_aud | Modem audio |
| /dev/graphics/fb0 | Framebuffer |
| /dev/gsensor | G-sensor |
| /dev/gyroscope | Gyroscope |
| /dev/hotknot | Hotknot |
| /dev/ion | ION memory |
| /dev/kd_camera_hw | Camera hardware |
| /dev/kd_camera_flashlight | Flashlight |
| /dev/mali0 | Mali GPU |
| /dev/msensor | Magnetic sensor |
| /dev/mtk_* | MediaTek devices |
| /dev/touch | Touchscreen |
| /dev/rtc0 | RTC |

### Sysfs Paths (from stock init.rc)
| Stock Path | Purpose |
|------------|---------|
| /sys/devices/platform/mt_usb | USB controller |
| /sys/devices/platform/gsensor | G-sensor |
| /sys/devices/platform/msensor | M-sensor |
| /sys/devices/platform/als_ps | ALS/PS sensor |
| /sys/devices/platform/leds-mt65xx/leds/* | LEDs |
| /sys/devices/virtual/input/input* | Input devices |
| /sys/devices/virtual/usb_composite/* | USB composite |

## Custom Kernel Drivers (enabled in defconfig)

### Display (LCM)
- Driver: ili9881c_hd720_dsi_vdo_djn
- Resolution: 720x1280 HD
- DSI: 4 lanes, RGB888
- Config: CONFIG_MTK_LCM, CONFIG_CUSTOM_KERNEL_LCM

### Touchscreen
- Driver: FT8606
- Config: CONFIG_TOUCHSCREEN_MTK_FT8606, CONFIG_TINNO_FT8606
- Gesture: CONFIG_MTK_TP_WAKE_SWITCH (tp_wake_switch)

### Sensors
| Sensor | Driver | Config |
|--------|--------|--------|
| Accelerometer | mc3410 | CONFIG_MTK_MC3410_NEW |
| Magnetometer | akm09911 | CONFIG_MTK_AKM09911_NEW |
| ALS/PS | cm36652 | CONFIG_MTK_CM36652_NEW |

### Camera
| Camera | Sensor | Config |
|--------|--------|--------|
| Main | gc2355_mipi_raw | CONFIG_CUSTOM_KERNEL_IMGSENSOR |
| Front | s5k5e2ya_mipi_raw | CONFIG_CUSTOM_KERNEL_IMGSENSOR |

### Other Enabled Drivers
- USB: CONFIG_USB_MTK_OTG, CONFIG_USB_MTK_HDRC
- Audio: CONFIG_MTK_SPEAKER, CONFIG_MTK_AUDIO
- GPU: CONFIG_MTK_GPU (Mali)
- ION: CONFIG_MTK_ION
- M4U: CONFIG_MTK_M4U
- CCI: CONFIG_MTK_CCCI_DEVICES

## Boot Parameters
| Parameter | Stock | Custom |
|-----------|-------|--------|
| Cmdline | bootopt=64S3,32N2,64N2 | bootopt=64S3,32N2,64N2 |
| Base | 0x40000000 | 0x40000000 |
| Page Size | 2048 | 2048 |
| Tags | 0x4e000000 | 0x4e000000 |

## Notes
- Stock kernel 3.10.65 uses platform devices (sysfs paths like /sys/devices/platform/*)
- Custom kernel 3.18.19 uses device tree + platform drivers
- Both create device nodes via ueventd/udev at boot
- Custom drivers must match stock sysfs paths for init.rc compatibility
