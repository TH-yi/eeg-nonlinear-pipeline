#!/bin/bash
# 运行 RQA 分析脚本
# 使用 main.py 的默认参数运行 RQA 分析

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo -e "${RED}错误: 虚拟环境不存在。请先运行 setup.sh 进行部署。${NC}"
    exit 1
fi

# 激活虚拟环境
echo -e "${GREEN}激活虚拟环境...${NC}"
source venv/bin/activate

# 检查输入数据
INPUT_DIR="storage/input_data"
if [ ! -d "${INPUT_DIR}" ] || [ -z "$(ls -A ${INPUT_DIR}/*.mat 2>/dev/null)" ]; then
    echo -e "${YELLOW}警告: 输入目录为空或不存在。${NC}"
    echo "请先运行 './onedrive_sync.sh download' 下载数据。"
    exit 1
fi

# 创建输出目录
OUTPUT_DIR="storage/output_data"
mkdir -p "${OUTPUT_DIR}"

# 显示配置信息
echo -e "${GREEN}=========================================="
echo "RQA 分析配置"
echo "==========================================${NC}"
echo "输入目录: ${INPUT_DIR}"
echo "输出目录: ${OUTPUT_DIR}"
echo "方法: rqa"
echo "默认参数:"
echo "  - fs: 500 Hz"
echo "  - tau: 10"
echo "  - lag: 1"
echo "  - emb_dim: 2"
echo "=========================================="
echo ""

# 检查输入文件数量
FILE_COUNT=$(ls -1 ${INPUT_DIR}/*.mat 2>/dev/null | wc -l)
echo -e "${GREEN}找到 ${FILE_COUNT} 个输入文件${NC}"
echo ""

# 运行分析
echo -e "${GREEN}开始运行 RQA 分析...${NC}"
echo ""

# 使用 main.py 的默认参数运行
# 根据 main.py，默认参数是：
# - fs=500 (FS)
# - tau=10 (TAU)
# - lag=1 (LAG)
# - emb_dim=2 (EMB_DIM)
# - method=rqa

python main.py process \
    --data-dir "${INPUT_DIR}" \
    --output-dir "${OUTPUT_DIR}" \
    --method rqa \
    --save-mat

# 检查运行结果
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo "RQA 分析完成！"
    echo "==========================================${NC}"
    echo ""
    echo "输出文件:"
    ls -lh "${OUTPUT_DIR}"/*.json "${OUTPUT_DIR}"/*.mat 2>/dev/null | tail -5
    echo ""
    echo "下一步: 运行 './onedrive_sync.sh upload' 上传结果"
else
    echo ""
    echo -e "${RED}=========================================="
    echo "分析过程中出现错误！"
    echo "==========================================${NC}"
    echo "请检查日志文件: storage/logs/main.log"
    exit 1
fi

