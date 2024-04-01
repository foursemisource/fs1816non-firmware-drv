#!/bin/bash
###
# Copyright (C) Shanghai FourSemi Semiconductor Co.,Ltd. 2016-2023. All rights reserved.
#
# 2023-07-20 File created.

#set -e

LOCAL_PATH=`pwd`
Q865_SRC=/home/nick/workspace/q865_v11
OUT_PATH=${Q865_SRC}/out/target/product/kona/obj/kernel/msm-4.19
MODULE_PATH=$LOCAL_PATH

#export MODSECKEY=$LOCAL_PATH/build/signing_key.pem
#export MODPUBKEY=$LOCAL_PATH/build/signing_key.x509
export MODSECKEY=$OUT_PATH/certs/signing_key.pem
export MODPUBKEY=$OUT_PATH/certs/signing_key.x509
export CONFIG_MODULE_SIG_HASH="sha512"

cd $OUT_PATH

GCC_PATH=${Q865_SRC}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin
CLANG_PATH=${Q865_SRC}/vendor/qcom/proprietary/llvm-arm-toolchain-ship/8.0/bin
export PATH=${GCC_PATH}:${CLANG_PATH}:$PATH
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-android-
export DTC_EXT=${Q865_SRC}/out/host/linux-x86/bin/dtc
export DTC_OVERLAY_TEST_EXT=${Q865_SRC}/out/host/linux-x86/bin/ufdt_apply_overlay
export HOSTCC=${Q865_SRC}/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-gcc
export HOSTAR=${Q865_SRC}/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ar
export HOSTLD=${Q865_SRC}/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ld
export CFLAGS="-I${Q865_SRC}/kernel/msm-4.19/include/uapi -I/usr/include -I/usr/include/x86_64-linux-gnu -L/usr/lib -L/usr/lib/x86_64-linux-gnu"
export LDFLAGS="L/usr/lib -L/usr/lib/x86_64-linux-gnu"
clang --version

if [ x$1 == "xclean" ]; then
	make clean REAL_CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CONFIG_BUILD_ARM64_DT_OVERLAY=y O=${OUT_PATH} M=${MODULE_PATH}
	exit 0;
else
	make REAL_CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CONFIG_BUILD_ARM64_DT_OVERLAY=y O=${OUT_PATH} M=${MODULE_PATH}
	find $MODULE_PATH/ -name *.ko -exec $OUT_PATH/scripts/sign-file ${CONFIG_MODULE_SIG_HASH} ${MODSECKEY} ${MODPUBKEY} {} \;
fi

PREFIX_FILE=$Q865_SRC/kernel/msm-4.19/Documentation/devicetree/bindings/vendor-prefixes.txt
if ! grep -q "foursemi" $PREFIX_FILE; then
	sed -i '/focaltech/a\foursemi	Shanghai FourSemi Semiconductor Co.,Ltd' $PREFIX_FILE
fi

rm -rf $Q865_SRC/kernel/msm-4.19/Documentation/devicetree/bindings/sound/foursemi*.txt
cp $MODULE_PATH/doc/foursemi*.txt $Q865_SRC/kernel/msm-4.19/Documentation/devicetree/bindings/sound/

cd $Q865_SRC
sed -i 's/LINUX_VERSION_CODE/LINUX_VER_CODE/g' $MODULE_PATH/fs1816.h
kernel/msm-4.19/scripts/checkpatch.pl --fix-inplace -f $MODULE_PATH/fs1816.h
sed -i 's/LINUX_VER_CODE/LINUX_VERSION_CODE/g' $MODULE_PATH/fs1816.h
kernel/msm-4.19/scripts/checkpatch.pl --fix-inplace -f $MODULE_PATH/fs1816.c

echo "#################################"
echo "## Build all Done!"
echo "#################################"
