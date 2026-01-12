#!/bin/bash
# init_cloud_storage.sh
# 自动格式化并挂载 Scratch Disk，并将其链接到项目目录

set -e

# 1. 查找未挂载的大容量 NVMe 磁盘 (通常是最大的那个非启动盘)
# 注意：在大多数云厂商，Scratch disk 可能是 /dev/vdb 或 /dev/nvme1n1
DISK_PATH=$(lsblk -dn -o NAME,SIZE,TYPE | grep "disk" | sort -h -k2 | tail -1 | awk '{print "/dev/"$1}')

echo "检测到大容量磁盘: $DISK_PATH"

# 2. 格式化并挂载 (如果尚未挂载)
MOUNT_POINT="/mnt/scratch"

if grep -qs "$MOUNT_POINT" /proc/mounts; then
    echo "磁盘已挂载到 $MOUNT_POINT"
else
    echo "正在格式化并挂载磁盘..."
    # 警告：这会格式化磁盘，确认为空盘或新实例
    sudo mkfs.ext4 -F "$DISK_PATH"
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount "$DISK_PATH" "$MOUNT_POINT"
    sudo chmod 777 "$MOUNT_POINT"
    echo "挂载成功。"
fi

# 3. 创建项目数据目录的软链接
# 我们不修改代码，而是欺骗代码，让它以为在读写本地 ./storage，实际在读写 /mnt/scratch
PROJECT_DIR=$(pwd)
LOCAL_STORAGE="$PROJECT_DIR/storage"
REMOTE_STORAGE="$MOUNT_POINT/eeg_storage"

echo "配置存储链接..."

# 如果本地已有 storage 文件夹，先备份或移动
if [ -d "$LOCAL_STORAGE" ] && [ ! -L "$LOCAL_STORAGE" ]; then
    echo "发现现有的 storage 目录，正在迁移数据..."
    mkdir -p "$REMOTE_STORAGE"
    cp -r "$LOCAL_STORAGE"/* "$REMOTE_STORAGE"/ 2>/dev/null || true
    rm -rf "$LOCAL_STORAGE"
fi

mkdir -p "$REMOTE_STORAGE"
mkdir -p "$REMOTE_STORAGE/input_data"
mkdir -p "$REMOTE_STORAGE/output_data"
mkdir -p "$REMOTE_STORAGE/logs"

# 创建软链接： ./storage -> /mnt/scratch/eeg_storage
ln -sfn "$REMOTE_STORAGE" "$LOCAL_STORAGE"

echo "✅ 存储配置完成！"
echo "实际数据存储位置: $REMOTE_STORAGE (5TB NVMe)"
echo "代码访问路径: $LOCAL_STORAGE"