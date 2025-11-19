#!/bin/bash

# =========================================================
# BUILD SCRIPT CHO LINUX KERNEL (ARM64)
# Biên dịch Kernel sau khi tích hợp MLFQ
# =========================================================

ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-
NUM_JOBS=$(nproc)

KERNEL_DIR=$(pwd)/kernel/linux
OUTPUT_DIR=$(pwd)/output

echo "--- BẮT ĐẦU BIÊN DỊCH KERNEL ARCH=${ARCH} ---"
cd $KERNEL_DIR

# 1. Cập nhật cấu hình
if [ ! -f .config ]; then
    echo "1. Không thấy .config → chạy defconfig"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
else
    echo "1. Update cấu hình (oldconfig)"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE oldconfig
fi

# 2. Build Image
echo "2. Build Kernel Image"
make -j$NUM_JOBS ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE Image

# 3. Build dtbs
echo "3. Build Device Tree"
make -j$NUM_JOBS ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE dtbs

# 4. Build modules
echo "4. Build Modules"
make -j$NUM_JOBS ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules

# 5. Cài đặt
echo "5. Cài đặt Modules & copy output"
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/dtbs

make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$OUTPUT_DIR modules_install

cp arch/$ARCH/boot/Image $OUTPUT_DIR/kernel.img
cp arch/$ARCH/boot/dts/*.dtb $OUTPUT_DIR/dtbs/

echo "--- HOÀN TẤT BUILD KERNEL ---"
