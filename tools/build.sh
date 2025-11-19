#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# =========================================================
# PIOS MLFQ: BUILD & DEPLOY KERNEL VÀO IMAGE MẪU (RPi4-tuned)
# =========================================================

# --- CẤU HÌNH HỆ THỐNG ---
ARCH="arm64"
CROSS_COMPILE="aarch64-linux-gnu-"
NUM_JOBS="$(nproc)"

KERNEL_DIR="$(pwd)/kernel/linux"
OUTPUT_DIR="$(pwd)/build_artifacts"
IMG_NAME="raspios_arm64.img"
IMG_PATH="$(pwd)/images/$IMG_NAME"

# 🛑 ĐIỂM MOUNT (Phải khớp với logic copy bên dưới)
MOUNT_BOOT_PATH="/mnt/boot"
MOUNT_ROOT_PATH="/mnt/root"

# --- HÀM DỌN DẸP (CLEANUP) ---
cleanup() {
    echo ""
    echo "--- BẮT ĐẦU CLEANUP (UNMOUNT & DETACH LOOP DEVICE) ---"
    sudo umount "$MOUNT_BOOT_PATH" 2>/dev/null || true
    sudo umount "$MOUNT_ROOT_PATH" 2>/dev/null || true

    if [ -n "${LOOP_DEV:-}" ]; then
        sudo losetup -d "$LOOP_DEV" 2>/dev/null || true
    fi
    echo "✔ CLEANUP HOÀN TẤT."
}

trap cleanup EXIT INT TERM

# --- 1. THIẾT LẬP LOOP DEVICE VÀ MOUNT IMAGE ---
echo "--- 1. THIẾT LẬP VÀ MOUNT IMAGE ---"

if [ ! -f "$IMG_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy file image tại: $IMG_PATH"
    echo "Vui lòng chạy './tools/download.sh' hoặc chuẩn bị file image."
    exit 1
fi

# tạo loop device với partition scanning (-P)
LOOP_DEV="$(sudo losetup --show -fP "$IMG_PATH")"
if [ -z "$LOOP_DEV" ]; then
    echo "❌ Không tạo được loop device!"
    exit 1
fi
echo "✅ Loop device: $LOOP_DEV"

# Tạo thư mục mount nếu chưa có
sudo mkdir -p "$MOUNT_BOOT_PATH" "$MOUNT_ROOT_PATH"

# Mount partition (giả định p1=boot(p fat), p2=root(ext4))
sudo mount "${LOOP_DEV}p1" "$MOUNT_BOOT_PATH" || { echo "❌ Lỗi mount phân vùng boot!"; exit 1; }
sudo mount "${LOOP_DEV}p2" "$MOUNT_ROOT_PATH" || { echo "❌ Lỗi mount phân vùng root!"; exit 1; }

echo "🎉 MOUNT THÀNH CÔNG!"
echo "   /boot → $MOUNT_BOOT_PATH"
echo "   /root → $MOUNT_ROOT_PATH"

# --------------------------------------------------------------------------
# --- 2. BIÊN DỊCH KERNEL (BUILD) ---
# --------------------------------------------------------------------------
echo "--- 2. BẮT ĐẦU BIÊN DỊCH KERNEL ARCH=${ARCH} ---"
cd "$KERNEL_DIR"

# 2.1: Sử dụng config cho Raspberry Pi 4 (bcm2711)
echo "1. Sử dụng bcm2711_defconfig (RPi4)"
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" bcm2711_defconfig

# 2.2 Build Image, dtbs, modules cùng lúc
echo "2. Build Image, dtbs, modules"
make -j"$NUM_JOBS" ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" Image dtbs modules

# 2.3 Chuẩn bị thư mục output
echo "3. Chuẩn bị thư mục output"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/dtbs"

# 2.4 Install modules into output
echo "4. Cài đặt Modules vào $OUTPUT_DIR"
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" INSTALL_MOD_PATH="$OUTPUT_DIR" modules_install

# 2.5 Copy kernel & dtb
IMAGE_SRC="arch/$ARCH/boot/Image"
DTB_SRC="arch/$ARCH/boot/dts/broadcom/bcm2711-rpi-4-b.dtb"

if [ ! -f "$IMAGE_SRC" ]; then
    echo "❌ Không tìm thấy kernel Image: $IMAGE_SRC"
    exit 1
fi
if [ ! -f "$DTB_SRC" ]; then
    echo "❌ Không tìm thấy DTB: $DTB_SRC"
    exit 1
fi

cp "$IMAGE_SRC" "$OUTPUT_DIR/kernel.img"
cp "$DTB_SRC" "$OUTPUT_DIR/dtbs/"

echo "--- HOÀN TẤT BUILD KERNEL ---"

# --------------------------------------------------------------------------
# --- 3. TRIỂN KHAI (DEPLOYMENT) ---
# --------------------------------------------------------------------------
echo "--- 3. TRIỂN KHAI KERNEL VÀO IMAGE ĐÃ MOUNT ---"

KERNEL_IMG="$OUTPUT_DIR/kernel.img"
RPI4_DTB="$OUTPUT_DIR/dtbs/bcm2711-rpi-4-b.dtb"

# Kiểm tra tồn tại file trước khi copy
if [ ! -f "$KERNEL_IMG" ]; then
    echo "❌ Thiếu $KERNEL_IMG"
    exit 1
fi
if [ ! -f "$RPI4_DTB" ]; then
    echo "❌ Thiếu $RPI4_DTB"
    exit 1
fi
if [ ! -d "$OUTPUT_DIR/lib/modules" ]; then
    echo "❌ Thiếu thư mục modules ở $OUTPUT_DIR/lib/modules"
    exit 1
fi

# Đảm bảo lib/modules trên rootfs tồn tại
sudo mkdir -p "$MOUNT_ROOT_PATH/lib/modules"

echo "   -> Copy kernel8.img..."
sudo cp "$KERNEL_IMG" "$MOUNT_BOOT_PATH/kernel8.img"

echo "   -> Copy bcm2711-rpi-4-b.dtb..."
sudo cp "$RPI4_DTB" "$MOUNT_BOOT_PATH/"

echo "   -> Copy modules vào rootfs..."
# Xóa modules cũ (cẩn trọng) và copy modules mới
sudo rm -rf "$MOUNT_ROOT_PATH/lib/modules/"*
sudo cp -r "$OUTPUT_DIR/lib/modules/"* "$MOUNT_ROOT_PATH/lib/modules/"

echo "--- TRIỂN KHAI HOÀN TẤT! ---"
