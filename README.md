# 🤖 PIOS - Raspberry Pi OS with Custom MLFQ Scheduler

## 💡 Giới thiệu Dự án

Dự án này tùy chỉnh **nhân Linux (Kernel) 6.12.y** cho Raspberry Pi 4 để tích hợp bộ lập lịch mới: **Multi-Level Feedback Queue (MLFQ)**.

Mục tiêu là chèn MLFQ (có cơ chế **Aging** và **Time Slicing động**) vào hệ thống lập lịch hiện tại nhằm cải thiện tính **phản hồi (responsiveness)** của hệ thống.

---

## 📂 Cấu trúc Repository (Chỉ các file code)

Repository chỉ lưu trữ mã nguồn tùy chỉnh và các script, loại bỏ mã nguồn kernel gốc (hàng GB) nhờ file `.gitignore`:

| Thư mục/File | Mục đích |
| :--- | :--- |
| **`kernel/patches/mlfq.patch`** | File cốt lõi chứa **toàn bộ thay đổi kernel** của MLFQ. |
| **`scheduler/`** | Mã nguồn C của thuật toán MLFQ (`mlfq.c`, `mlfq.h`) và ứng dụng test. |
| **`tools/`** | Các script hỗ trợ triển khai. |

---

## 🛠️ Hướng dẫn Thiết lập và Build

Thực hiện các lệnh sau trong terminal, bắt đầu từ thư mục gốc của dự án (`~/pios`).

### A. Chuẩn bị Môi trường

Cài đặt các gói phụ thuộc và Cross-Compiler cho kiến trúc ARM64:

Clone dự án: https://github.com/ngotienloc/pios.git

```bash
# 1. Cài đặt các gói cần thiết (Lần đầu sử dụng)
sudo apt update
sudo apt install -y build-essential bc bison flex libssl-dev libncurses-dev \
    libelf-dev libelf1 dwarves device-tree-compiler \
    git rsync python3 python3-pip crossbuild-essential-arm64

# 2. Chạy lệnh khởi tạo lại cây thư mục: 
chmod +x tools/setup.sh
./tools/setup.sh

# 3. Downloads các kernel và images cơ bản: 
chmod +x tools/downloads.sh 
./tools/downloads.sh 

# 4. Chạy copy code để cập nhật mlfq
chmod +x tools/copy-code.sh 
./tools/copy-code.sh

# 5. Nếu clone lần đầu, bạn cần chạy các lệnh sau để chỉnh sửa các file trong sched: 
cd ~/pios/kernel/linux
git init
git add include/linux/sched.h kernel/sched/core.c kernel/sched/Makefile
git commit -m "MLFQ: Final structural integration"
git format-patch -1 --stdout > ../patches/mlfq.patch
rm -rf .git

# 6. Thực hiện build kernel:
cd ~/pios
chmod +x tools/build.sh 
./tools tools/build.sh

# 7. Thực hiện mount vào image:
chmod +x tools/mount_image.sh 
./tools/mount_image.sh 

// Ấn Ctrl C để unmount