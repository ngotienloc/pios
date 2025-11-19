#!/bin/bash
# Script: setup.sh
# Mục đích: Tạo lại cấu trúc thư mục rỗng cần thiết cho dự án PIOS.

# Dừng script nếu có bất kỳ lệnh nào thất bại
set -e

# Định nghĩa thư mục gốc của dự án (từ vị trí hiện tại của script)
PROJECT_ROOT=$(dirname "$(dirname "$0")")

echo "=== 🏗️ BẮT ĐẦU KHÔI PHỤC CẤU TRÚC THƯ MỤC ==="

# 1. TẠO CẤU TRÚC THƯ MỤC
echo "Tạo lại các thư mục chính: kernel/linux, build_artifacts, images, mnt, v.v."

mkdir -p "$PROJECT_ROOT"/kernel/patches \
         "$PROJECT_ROOT"/build_artifacts \
         "$PROJECT_ROOT"/images \
         "$PROJECT_ROOT"/sdcard \
         "$PROJECT_ROOT"/scheduler/test

echo "=== ✅ KHÔI PHỤC CẤU TRÚC HOÀN TẤT ==="
