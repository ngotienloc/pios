#!/bin/bash

# =========================================================
# SCRIPT ĐỂ MOUNT IMAGE RASPBIAN/RASPIOS
# Tự động tìm loop device và mount boot + rootfs
# =========================================================

IMG_NAME="raspios_arm64.img"
IMG_PATH="$(pwd)/images/$IMG_NAME"
BOOT_MOUNT_DIR="/mnt/boot"
ROOT_MOUNT_DIR="/mnt/root"

# --- Kiểm tra IMAGE ---
if [ ! -f "$IMG_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy file image tại: $IMG_PATH"
    exit 1
fi

echo "--- 1. Thiết lập Loop Device cho Image ---"
LOOP_DEV=$(sudo losetup --show -fP "$IMG_PATH")

if [ -z "$LOOP_DEV" ]; then
    echo "❌ Không tạo được loop device!"
    exit 1
fi

echo "✅ Loop device: $LOOP_DEV"

# --- Hàm cleanup khi thoát ---
cleanup() {
    echo "--- Đang unmount & detach loop device ---"
    sudo umount $BOOT_MOUNT_DIR 2>/dev/null
    sudo umount $ROOT_MOUNT_DIR 2>/dev/null
    sudo losetup -d "$LOOP_DEV" 2>/dev/null
    echo "✔ Done."
}
trap cleanup EXIT

echo "--- 2. Tạo thư mục mount ---"
sudo mkdir -p $BOOT_MOUNT_DIR $ROOT_MOUNT_DIR

echo "--- 3. Mount phân vùng ---"

# Boot partition
echo "→ Mount ${LOOP_DEV}p1 → $BOOT_MOUNT_DIR"
sudo mount "${LOOP_DEV}p1" $BOOT_MOUNT_DIR
if [ $? -ne 0 ]; then
    echo "❌ Lỗi mount phân vùng boot!"
    exit 1
fi

# Root partition
echo "→ Mount ${LOOP_DEV}p2 → $ROOT_MOUNT_DIR"
sudo mount "${LOOP_DEV}p2" $ROOT_MOUNT_DIR
if [ $? -ne 0 ]; then
    echo "❌ Lỗi mount phân vùng root!"
    exit 1
fi

echo "=========================================================="
echo "🎉 MOUNT THÀNH CÔNG!"
echo "  /boot → $BOOT_MOUNT_DIR"
echo "  /root → $ROOT_MOUNT_DIR"
echo ""
echo "👉 Hãy cài Kernel mới hoặc chỉnh sửa file hệ thống."
echo ""
echo "⚠️ Khi bạn thoát script hoặc nhấn Ctrl+C, nó sẽ tự unmount."
echo "=========================================================="

# Lưu loop device để tham khảo
echo $LOOP_DEV > /tmp/pios_loop_dev
