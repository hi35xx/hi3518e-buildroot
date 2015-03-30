################################################################################
#
# linux-fusion
#
################################################################################

MT7601U_VERSION = 85514f099415fbcb40c2bde3eb928057e5a64fe1
MT7601U_SITE = $(call github,hi35xx,mt7601,$(MT7601U_VERSION))
#MT7601U_INSTALL_STAGING = YES
MT7601U_DEPENDENCIES = linux
MT7601U_LICENSE = GPLv2+
MT7601U_LICENSE_FILES = LICENSE

LINUX_CUSTOM_VERSION = $(shell make -s kernelversion -C $(LINUX_DIR))
MT7601U_MAKE_OPTS = PLATFORM=SMDK
MT7601U_MAKE_OPTS += LINUX_SRC=$(LINUX_DIR)
MT7601U_MAKE_OPTS += SYSROOT=$(TARGET_DIR)
MT7601U_MAKE_OPTS += ARCH=$(KERNEL_ARCH)
MT7601U_MAKE_OPTS += CROSS_COMPILE=$(TARGET_CROSS)

TARGET_INSTALL_MOD_PATH = \
	/lib/modules/$(LINUX_CUSTOM_VERSION)/kernel/drivers/net/wireless

define MT7601U_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) $(MT7601U_MAKE_OPTS) -C $(@D)/src
endef

define MT7601U_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 664 $(@D)/src/os/linux/mt7601Usta.ko \
		$(TARGET_DIR)$(TARGET_INSTALL_MOD_PATH)/mt7601Usta.ko
	$(TARGET_CROSS)strip -g \
		$(TARGET_DIR)$(TARGET_INSTALL_MOD_PATH)/mt7601Usta.ko
	$(HOST_DIR)/sbin/depmod -a -b $(TARGET_DIR) $(LINUX_CUSTOM_VERSION)
	$(INSTALL) -D -m 644 $(@D)/src/RT2870STA.dat \
		$(TARGET_DIR)/etc/Wireless/RT2870STA/RT2870STA.dat
endef

$(eval $(generic-package))
