subdir-ccflags-y += -I$(srctree)/drivers/misc/mediatek/include \
					-I$(srctree)/drivers/misc/mediatek/include/mt-plat \
					-I$(srctree)/drivers/misc/mediatek/include/mt-plat/mt6735/include \
					-I$(srctree)/include/mt-plat \
					-I$(srctree)/include/mach
ifeq ($(CONFIG_TRUSTONIC_TEE_SUPPORT),y)
subdir-ccflags-y += -I$(srctree)/drivers/spi/trustzone/spi/Tlspi/inc
endif

ifeq ($(CONFIG_TRUSTONIC_TEE_SUPPORT),y)
	include $(srctree)/drivers/misc/mediatek/gud/Makefile.include
endif

obj-$(CONFIG_MTK_SPI) += spi.o spi-dev.o
