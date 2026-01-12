#!/bin/bash
# 完整一键部署和运行脚本
# 自动完成：部署 -> 下载数据 -> 运行分析 -> 上传结果

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "EEG Pipeline 完整自动化部署"
echo "==========================================${NC}"
echo ""

# 检查是否已部署
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}[步骤 1/5] 首次部署，运行 setup.sh...${NC}"
    chmod +x setup.sh
    ./setup.sh
else
    echo -e "${GREEN}[步骤 1/5] 检测到已部署环境，跳过安装${NC}"
fi

# 检查 OneDrive 配置
echo -e "${YELLOW}[步骤 2/5] 检查 OneDrive 配置...${NC}"
if ! rclone listremotes | grep -q "^onedrive:$"; then
    echo -e "${RED}错误: OneDrive 未配置${NC}"
    echo ""
    echo "请按照以下步骤配置 OneDrive:"
    echo "1. 运行 'rclone config'"
    echo "2. 选择 'OneDrive Business / Office 365' (选项 2)"
    echo "3. 使用手动配置模式 (Use auto config? n)"
    echo "4. 详细步骤请查看: ONEDRIVE_SETUP.md"
    echo ""
    exit 1
fi
echo -e "${GREEN}OneDrive 配置正常${NC}"

# 下载数据
echo ""
echo -e "${YELLOW}[步骤 3/5] 从 OneDrive 下载数据...${NC}"
chmod +x onedrive_sync.sh
./onedrive_sync.sh download

# 运行分析
echo ""
echo -e "${YELLOW}[步骤 4/5] 运行 RQA 分析...${NC}"
chmod +x run_rqa.sh
./run_rqa.sh

# 上传结果
echo ""
echo -e "${YELLOW}[步骤 5/5] 上传结果到 OneDrive...${NC}"
./onedrive_sync.sh upload

echo ""
echo -e "${GREEN}=========================================="
echo "✅ 所有步骤完成！"
echo "==========================================${NC}"
echo ""
echo "结果已上传到 OneDrive:"
echo "  OneDrive - Concordia University - Canada/Creativity_EEG_Dataset/output_data/"
echo ""

