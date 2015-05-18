################################################################################
#
# hi3518-mpp2
#
################################################################################

HIMPP_HI3518_VERSION = 1.0.9.0
HIMPP_HI3518_TARBALL = $(TOPDIR)/package/himpp/himpp-hi3518/mpp2.tgz
HIMPP_HI3518_SITE_METHOD = file
HIMPP_HI3518_SITE = $(patsubst %/,%,$(dir $(HIMPP_HI3518_TARBALL)))
HIMPP_HI3518_SOURCE = $(notdir $(HIMPP_HI3518_TARBALL))
HIMPP_HI3518_INSTALL_STAGING = YES
HIMPP_HI3518_DEPENDENCIES = linux

SENSOR_TYPE = $(call qstrip,$(BR2_PACKAGE_HIMPP_SNS_TYPE))

HIMPP_HI3518_MAKE_OPTS = ARCH=arm
HIMPP_HI3518_MAKE_OPTS += HIARCH=hi3518
HIMPP_HI3518_MAKE_OPTS += LIBC=uclibc
HIMPP_HI3518_MAKE_OPTS += CROSS=$(TARGET_CROSS)
HIMPP_HI3518_MAKE_OPTS += CROSS_COMPILE=$(TARGET_CROSS)
HIMPP_HI3518_MAKE_OPTS += LINUX_ROOT=$(LINUX_DIR)
HIMPP_HI3518_MAKE_OPTS += MPP_PATH=$(@D)/mpp2
HIMPP_HI3518_MAKE_OPTS += SENSOR_TYPE=$(SENSOR_TYPE)

define build_sample_cmds
	cd $(@D)/mpp2/sample/$(1); $(MAKE1) $(HIMPP_HI3518_MAKE_OPTS);
endef

ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_AUDIO),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,audio)
	SAMPLES_TO_INSTALL += audio/sample_audio
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_HIFB),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,hifb)
	SAMPLES_TO_INSTALL += hifb/sample_hifb
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_IQ),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,iq)
	SAMPLES_TO_INSTALL += iq/sample_iq
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_IVE),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,ive)
	SAMPLES_TO_INSTALL += ive/sample_ive_canny
	SAMPLES_TO_INSTALL += ive/sample_ive_detect
	SAMPLES_TO_INSTALL += ive/sample_ive_FPN
	SAMPLES_TO_INSTALL += ive/sample_ive_sobel_with_cached_mem
	SAMPLES_TO_INSTALL += ive/sample_ive_test_memory
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_REGION),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,region)
	SAMPLES_TO_INSTALL += region/sample_region
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_TDE),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,tde)
	SAMPLES_TO_INSTALL += tde/sample_tde
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_VDA),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,vda)
	SAMPLES_TO_INSTALL += vda/sample_vda
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_VENC),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,venc)
	SAMPLES_TO_INSTALL += venc/sample_venc
endif
ifeq ($(BR2_PACKAGE_HIMPP_SAMPLES_VIO),y)
	HIMPP_HI3518_BUILD_CMDS += $(call build_sample_cmds,vio)
	SAMPLES_TO_INSTALL += vio/sample_vio
endif


HIMPP_PREFIX = /opt/himpp2

define HIMPP_HI3518_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)$(HIMPP_PREFIX)
	$(RM) -r $(TARGET_DIR)$(HIMPP_PREFIX)/include
	cp -a $(@D)/mpp2/include $(STAGING_DIR)$(HIMPP_PREFIX)
	$(RM) -r $(TARGET_DIR)$(HIMPP_PREFIX)/lib
	cp -a $(@D)/mpp2/lib $(STAGING_DIR)$(HIMPP_PREFIX)
endef

DRVS_TO_INSTALL = $(shell cd $(@D)/mpp2 && find ko/ -name *.ko)

SCRS_TO_INSTALL = $(shell cd $(@D)/mpp2 && find ko/ -name *.sh)

LIBS_TO_INSTALL = $(shell cd $(@D)/mpp2 && find lib/ -name *.so*)

define HIMPP_HI3518_INSTALL_TARGET_CMDS
	# install kernel modules and scripts
	$(RM) -r $(TARGET_DIR)$(HIMPP_PREFIX)/ko
	for f in $(DRVS_TO_INSTALL); do \
	  $(INSTALL) -D $(@D)/mpp2/$$f $(TARGET_DIR)$(HIMPP_PREFIX)/$$f \
	             || exit 1; \
	done
	for f in $(SCRS_TO_INSTALL); do \
	  $(INSTALL) -D $(@D)/mpp2/$$f $(TARGET_DIR)$(HIMPP_PREFIX)/$$f \
	             || exit 1; \
	  sed -r -i -e "s/himm([[:space:]]*[^[:space:]]*)/devmem \1 32/" \
	      $(TARGET_DIR)$(HIMPP_PREFIX)/$$f; \
	done
	$(INSTALL) -m 755 -D package/himpp/himpp-hi3518/load3518e.sh \
	           $(TARGET_DIR)$(HIMPP_PREFIX)/ko

	# install libraries
	$(RM) -r $(TARGET_DIR)$(HIMPP_PREFIX)/lib
	for f in $(LIBS_TO_INSTALL); do \
	  $(INSTALL) -D -m 755 $(@D)/mpp2/$$f $(TARGET_DIR)$(HIMPP_PREFIX)/$$f \
	             || exit 1; \
	done

	# install samples
	$(RM) -r $(TARGET_DIR)$(HIMPP_PREFIX)/bin
	for f in $(SAMPLES_TO_INSTALL); do \
	  $(INSTALL) -D -m 755 $(@D)/mpp2/sample/$$f \
	             $(TARGET_DIR)$(HIMPP_PREFIX)/bin/$$f \
	             || exit 1; \
	  $(TARGET_STRIP) -s \
	             $(TARGET_DIR)$(HIMPP_PREFIX)/bin/$$f; \
	done
endef

$(eval $(generic-package))

