#!/bin/bash
# 一键部署脚本 - DigitalOcean GPU Droplet (H100)
# 用于部署 EEG 非线性特征提取管道

set -e  # 遇到错误立即退出

echo "=========================================="
echo "EEG Pipeline 部署脚本"
echo "DigitalOcean GPU Droplet (H100)"
echo "=========================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color



# 更新系统
echo -e "${GREEN}[1/8] 更新系统包...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

# 安装基础依赖
echo -e "${GREEN}[2/8] 安装基础依赖...${NC}"
sudo apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    python3.11 \
    python3.11-dev \
    python3-pip \
    python3.11-venv \
     \
    ocl-icd-opencl-dev \
    opencl-headers \
    rclone \
    unzip

# 安装 CUDA (如果需要 GPU 加速)
echo -e "${GREEN}[3/8] 检查 CUDA 安装...${NC}"
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${YELLOW}警告: 未检测到 NVIDIA 驱动。请确保已安装 NVIDIA 驱动和 CUDA。${NC}"
    echo -e "${YELLOW}DigitalOcean GPU Droplet 通常已预装驱动，如果未检测到，请检查。${NC}"
else
    echo -e "${GREEN}NVIDIA 驱动已安装${NC}"
    nvidia-smi
fi

# 创建 Python 虚拟环境
echo -e "${GREEN}[4/8] 创建 Python 虚拟环境...${NC}"
if [ ! -d "venv" ]; then
    python3.11 -m venv venv
fi
source venv/bin/activate

# 升级 pip
echo -e "${GREEN}[5/8] 升级 pip...${NC}"
pip install --upgrade pip setuptools wheel

# 安装项目依赖
echo -e "${GREEN}[6/8] 安装项目依赖...${NC}"
pip install -r requirements.txt

# 安装项目本身（可编辑模式）
echo -e "${GREEN}[7/8] 安装项目...${NC}"
pip install -e .

# 创建必要的目录
echo -e "${GREEN}[8/8] 创建必要的目录...${NC}"
mkdir -p storage/input_data
mkdir -p storage/output_data
mkdir -p storage/logs
mkdir -p storage/images

# 设置权限
chmod +x onedrive_sync.sh
chmod +x run_rqa.sh

echo ""
echo -e "${GREEN}=========================================="
echo "部署完成！"
echo "==========================================${NC}"
echo ""
echo "下一步："
echo "1. 配置 OneDrive: 查看 ONEDRIVE_SETUP.md 获取详细配置步骤"
echo "   - 运行 'rclone config'"
echo "   - 选择 'OneDrive Business / Office 365' (选项 2)"
echo "   - 使用手动配置模式"
echo "2. 下载数据: 运行 './onedrive_sync.sh download'"
echo "3. 运行分析: 运行 './run_rqa.sh'"
echo "4. 上传结果: 运行 './onedrive_sync.sh upload'"
echo ""
echo "提示: 每次使用前请先激活虚拟环境: source venv/bin/activate"
echo ""
echo "OneDrive 路径: OneDrive - Concordia University - Canada/Creativity_EEG_Dataset"

