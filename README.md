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

```bash
# 1. Cài đặt các gói cần thiết
sudo apt update
sudo apt install -y build-essential bc bison flex libssl-dev libncurses-dev \
    libelf-dev libelf1 dwarves device-tree-compiler \
    git rsync python3 python3-pip crossbuild-essential-arm64

# 2. Tải Kernel Source (Source Kernel Gốc)
cd kernel/
git clone --depth=1 --branch rpi-6.12.y [https://github.com/raspberrypi/linux.git](https://github.com/raspberrypi/linux.git) linux
cd ../

# 3. Tải Image Mẫu (Nếu cần triển khai)
mkdir -p images
cd images/
wget [https://downloads.raspberrypi.org/raspios_lite_arm64_latest](https://downloads.raspberrypi.org/raspios_lite_arm64_latest) -O raspios_arm64.img.xz
unxz raspios_arm64.img.xz
cd ../