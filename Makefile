###
# Copyright (C) Shanghai FourSemi Semiconductor Co.,Ltd. 2016-2024. All rights reserved.
#
# 2023-07-19 File created.

ifeq ($(CONFIG_SND_SOC_FS1816),)
CONFIG_SND_SOC_FS1816 := m
endif

ifneq ($(KERNELRELEASE),)

# TOPLEVEL=$(PWD)
# EXTRA_CFLAGS += -I$(TOPLEVEL)
# EXTRA_CFLAGS += -DDEBUG -DFSM_DEBUG

EXTRA_CFLAGS += -Wall -Werror
MODFLAGS = -fno-pic
CFLAGS_MODULE = $(MODFLAGS)
AFLAGS_MODULE = $(MODFLAGS)

snd-soc-fs1816-objs := fs1816.o
obj-$(CONFIG_SND_SOC_FS1816) += snd-soc-fs1816.o

else # ndef KERNELRELEASE

PWD := $(shell pwd)

MAKEARCH := $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)

all:
	@echo CONFIG_SND_SOC_FS1816 = $(CONFIG_SND_SOC_FS1816)
	$(MAKEARCH) -C $(KERNEL_DIR) M=$(PWD) modules

clean:
	$(MAKEARCH) -C $(KERNEL_DIR) M=$(PWD) clean
	rm -rf .*.cmd *.o *.mod.c *.ko .tmp_versions *.order *symvers

endif
