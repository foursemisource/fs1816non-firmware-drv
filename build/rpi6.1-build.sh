#!/bin/bash
###
# Copyright (C) Shanghai FourSemi Semiconductor Co.,Ltd. 2016-2023. All rights reserved.
#
# 2024-03-21 File created.

set -e

LOCAL_PATH=`pwd`

RPI_SRC=/home/nick/workspace/rpi/linux-6.1
OUT_PATH=${RPI_SRC}/out
MODULE_PATH=${LOCAL_PATH}

cd $OUT_PATH

KERNEL=kernel7
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export DTS_SUBDIR=broadcom

if [ x$1 == "xclean" ]; then
	make clean O=${OUT_PATH} M=${MODULE_PATH}
	exit 0;
else
	if [ ! -f ${OUT_PATH}/vmlinux ]; then
		make O=${OUT_PATH} bcm2709_defconfig -j4
		make O=${OUT_PATH} zImage modules dtbs -j4
	fi
	make O=${OUT_PATH} M=${MODULE_PATH} -j4
fi

PREFIX_TXT=$RPI_SRC/Documentation/devicetree/bindings/vendor-prefixes.txt
if ! grep -q "foursemi" $PREFIX_TXT; then
	sed -i '/focaltech/a\foursemi	Shanghai FourSemi Semiconductor Co.,Ltd' $PREFIX_TXT
fi

PREFIX_YAML=$RPI_SRC/Documentation/devicetree/bindings/vendor-prefixes.yaml
if ! grep -q "foursemi" $PREFIX_YAML; then
	sed -i '/FocalTech/a\  "^foursemi,.*":' $PREFIX_YAML
	sed -i '/foursemi/a\    description: Shanghai FourSemi Semiconductor Co.,Ltd' $PREFIX_YAML
fi

rm -rf $RPI_SRC/Documentation/devicetree/bindings/sound/foursemi*.txt
cp $MODULE_PATH/doc/foursemi*.txt $RPI_SRC/Documentation/devicetree/bindings/sound/

cd $RPI_SRC
sed -i 's/LINUX_VERSION_CODE/LINUX_VER_CODE/g' $MODULE_PATH/fs1816.h
scripts/checkpatch.pl --fix-inplace -f $MODULE_PATH/fs1816.h
sed -i 's/LINUX_VER_CODE/LINUX_VERSION_CODE/g' $MODULE_PATH/fs1816.h
scripts/checkpatch.pl --fix-inplace -f $MODULE_PATH/fs1816.c

echo "#################################"
echo "## Build all Done!"
echo "#################################"
