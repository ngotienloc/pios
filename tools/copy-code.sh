#!/bin/bash
# Script: copy-code.sh
# Mục đích: Sao chép mã nguồn MLFQ mới nhất từ thư mục phát triển sạch (scheduler/)
#           vào cây mã nguồn Kernel Source (kernel/linux/) để biên dịch.

# Thoát ngay lập tức nếu bất kỳ lệnh nào thất bại
set -e

# 1. ĐỊNH NGHĨA ĐƯỜNG DẪN
PROJECT_ROOT=$(dirname "$(dirname "$0")")
KERNEL_SOURCE_DIR="$PROJECT_ROOT/kernel/linux"
SCHEDULER_SRC="$PROJECT_ROOT/scheduler"

echo "=== 🔄 SAO CHÉP MÃ NGUỒN MLFQ VÀO KERNEL SOURCE ==="

# 2. KIỂM TRA TÍNH SẴN SÀNG
if [ ! -d "$KERNEL_SOURCE_DIR" ]; then
    echo "LỖI: Không tìm thấy thư mục mã nguồn kernel ($KERNEL_SOURCE_DIR)."
    echo "Vui lòng chạy tools/setup.sh và tools/download.sh trước."
    exit 1
fi

# 3. SAO CHÉP FILE HEADER (.h)
echo "1. Sao chép mlfq.h vào include/linux/..."
cp "$SCHEDULER_SRC/mlfq.h" "$KERNEL_SOURCE_DIR/include/linux/"

# 4. SAO CHÉP FILE SOURCE (.c)
echo "2. Sao chép mlfq.c vào kernel/sched/..."
cp "$SCHEDULER_SRC/mlfq.c" "$KERNEL_SOURCE_DIR/kernel/sched/"

echo "=== ✅ SAO CHÉP CODE HOÀN TẤT ==="

# NHẮC NHỞ QUAN TRỌNG: 
# Bước này chỉ sao chép code, không cập nhật patch.
# Nếu bạn sửa đổi các file cấu trúc Kernel (như sched.h, Makefile), 
# bạn cần chạy quy trình tạo patch thủ công để lưu lại những thay đổi đó vào mlfq.patch.