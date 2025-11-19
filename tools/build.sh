#!/bin/bash

# =========================================================
# BUILD SCRIPT CHO LINUX KERNEL (ARM64)
# Biên dịch Kernel sau khi tích hợp MLFQ
# =========================================================

ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-
NUM_JOBS=$(nproc)

KERNEL_DIR=$(pwd)/kernel/linux
OUTPUT_DIR=$(pwd)/build_artifacts

# 🛑 CẦN CẬP NHẬT: Thay thế các placeholder này bằng đường dẫn mount thực tế của bạn
# Ví dụ: /mnt/boot hoặc /media/user/BOOT
MOUNT_BOOT_PATH="/mnt/boot" 
# Ví dụ: /mnt/root hoặc /media/user/ROOTFS
MOUNT_ROOT_PATH="/mnt/root"

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

# 5. Cài đặt Modules & copy output
echo "5. Cài đặt Modules & copy output"
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/dtbs

make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$OUTPUT_DIR modules_install

cp arch/$ARCH/boot/Image $OUTPUT_DIR/kernel.img
cp arch/$ARCH/boot/dts/*.dtb $OUTPUT_DIR/dtbs/

echo "--- HOÀN TẤT BUILD KERNEL ---"

# =========================================================
# 6. TRIỂN KHAI (DEPLOYMENT) - Cần quyền sudo
# =========================================================

echo "--- 6. Bắt đầu triển khai Kernel Image và Modules vào thẻ SD/ổ đĩa ---"

# Kiểm tra đường dẫn mount
if [ ! -d "$MOUNT_BOOT_PATH" ]; then
    echo "⚠️ Lỗi: Đường dẫn BOOT ($MOUNT_BOOT_PATH) không tồn tại. Đảm bảo phân vùng đã được mount."
    exit 1
fi
if [ ! -d "$MOUNT_ROOT_PATH" ]; then
    echo "⚠️ Lỗi: Đường dẫn ROOT ($MOUNT_ROOT_PATH) không tồn tại. Đảm bảo phân vùng đã được mount."
    exit 1
fi

# Copy Kernel Image mới
echo "   -> Copy Kernel Image mới vào boot partition..."
sudo cp $OUTPUT_DIR/kernel.img $MOUNT_BOOT_PATH/kernel8.img

# Copy Device Tree (DTB) Pi4 (Giả định bạn đang build cho Pi4)
echo "   -> Copy Device Tree bcm2711-rpi-4-b.dtb..."
# Lấy DTB cụ thể cho Pi4 từ thư mục dtbs đã build
sudo cp $OUTPUT_DIR/dtbs/bcm2711-rpi-4-b.dtb $MOUNT_BOOT_PATH/

# Copy Modules vào rootfs
echo "   -> Copy Modules vào rootfs..."
# Đường dẫn modules_install tạo ra thư mục lib/modules
sudo cp -r $OUTPUT_DIR/lib/modules/* $MOUNT_ROOT_PATH/lib/modules/

echo "--- TRIỂN KHAI HOÀN TẤT ---"