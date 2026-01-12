#!/bin/bash
# OneDrive 同步脚本 - 针对 DigitalOcean Droplet 优化
# 功能：下载特定范围的 .mat 数据并上传结果

set -e

# --- 配置区域 ---

# 1. 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 2. Rclone 远程名称
ONEDRIVE_REMOTE="onedrive"

# 3. 远程路径配置
# 注意：在云端，路径通常不包含 "OneDrive - Concordia...", 直接从文件夹名开始
# 如果你的 rclone lsd onedrive: 显示的就是 Creativity_EEG_Dataset，请使用下面的设置：
REMOTE_FOLDER_NAME="Creativity_EEG_Dataset"

ONEDRIVE_DATA_PATH="${REMOTE_FOLDER_NAME}"
ONEDRIVE_OUTPUT_PATH="${REMOTE_FOLDER_NAME}/output_data"

# 4. 本地路径 (Droplet 上的路径)
LOCAL_INPUT_DIR="storage/input_data"
LOCAL_OUTPUT_DIR="storage/output_data"

# --- 检查与初始化 ---

# 检查 rclone
if ! command -v rclone &> /dev/null; then
    echo -e "${RED}错误: rclone 未安装。${NC}"
    echo "请运行: sudo -v ; curl https://rclone.org/install.sh | sudo bash"
    exit 1
fi

# 检查配置
if ! rclone listremotes | grep -q "^${ONEDRIVE_REMOTE}:$"; then
    echo -e "${RED}错误: 未找到名为 '${ONEDRIVE_REMOTE}' 的远程配置。${NC}"
    echo "请运行 'rclone config' 并按照 'Headless Auth' (无头认证) 步骤操作。"
    exit 1
fi

# --- 功能函数 ---

download_data() {
    echo -e "${GREEN}=== 开始下载数据 ===${NC}"
    echo "远程源: ${ONEDRIVE_REMOTE}:${ONEDRIVE_DATA_PATH}"
    echo "本地目标: ${LOCAL_INPUT_DIR}"
    
    mkdir -p "${LOCAL_INPUT_DIR}"
    
    # 构造过滤规则：只下载 Sub_1 到 Sub_28
    # 方法：使用 --include 匹配模式。
    # 为了精确匹配 1-28，我们使用通配符匹配所有该模式的文件，
    # 如果文件夹里只有 1-28，这是最高效的方法。
    
    echo "正在同步 Data_Creativity_Sub_*.mat 文件..."

    rclone sync "${ONEDRIVE_REMOTE}:${ONEDRIVE_DATA_PATH}" "${LOCAL_INPUT_DIR}" \
        --include "Data_Creativity_Sub_*.mat" \
        --progress \
        --transfers 8 \
        --checkers 16 \
        --drive-chunk-size 64M 
    
    # 统计下载数量
    COUNT=$(find "${LOCAL_INPUT_DIR}" -name "Data_Creativity_Sub_*.mat" | wc -l)
    echo -e "${GREEN}下载完成！本地共有 ${COUNT} 个数据文件。${NC}"
}

upload_results() {
    echo -e "${GREEN}=== 开始上传结果 ===${NC}"
    
    if [ ! -d "${LOCAL_OUTPUT_DIR}" ] || [ -z "$(ls -A ${LOCAL_OUTPUT_DIR})" ]; then
        echo -e "${YELLOW}警告: 输出目录为空或不存在，跳过上传。${NC}"
        return 0
    fi

    echo "正在将结果上传至: ${ONEDRIVE_REMOTE}:${ONEDRIVE_OUTPUT_PATH}"
    
    rclone copy "${LOCAL_OUTPUT_DIR}" "${ONEDRIVE_REMOTE}:${ONEDRIVE_OUTPUT_PATH}" \
        --progress \
        --transfers 4
    
    echo -e "${GREEN}上传完成！${NC}"
}

# --- 主逻辑 ---

case "${1}" in
    download)
        download_data
        ;;
    upload)
        upload_results
        ;;
    all)
        download_data
        # 在这里可以插入处理脚本，例如: python3 process_data.py
        upload_results
        ;;
    *)
        echo "用法: $0 {download|upload|all}"
        exit 1
        ;;
esac