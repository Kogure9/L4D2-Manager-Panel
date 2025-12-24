#!/bin/bash
set -e

# ================= 配置区域 =================
# 游戏文件将存放的宿主机路径
# 对应 docker-compose.yml 里的 /root/docker-apps/l4d2/serverfiles
HOST_GAME_DIR="/root/docker-apps/l4d2/serverfiles"
HOST_STEAM_DIR="/root/docker-apps/l4d2/steamcmd"
HOST_APP_DIR="/root/docker-apps/l4d2/app"

# 镜像源 (已切换)
SOURCE_IMAGE="left4devops/l4d2:latest"
# ===========================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== 开始准备 L4D2 游戏文件 (源: left4devops) ===${NC}"

# 1. 检查必要命令
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未找到 Docker，请先安装。${NC}"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}错误: 未找到 git，请先安装 (apt install git / yum install git)。${NC}"
    exit 1
fi

# 2. 创建宿主机数据目录
echo -e "${YELLOW}>>> [1/5] 创建数据目录...${NC}"
mkdir -p "$HOST_GAME_DIR"
mkdir -p "$HOST_STEAM_DIR"
mkdir -p "$HOST_APP_DIR"

# 3. 提取游戏文件 (核心逻辑)
# 检查目录是否为空，防止重复提取覆盖
if [ -z "$(ls -A $HOST_GAME_DIR)" ]; then
    echo -e "${YELLOW}>>> [2/5] 正在从镜像提取游戏文件 (约 30GB)...${NC}"
    
    # 拉取镜像
    echo "拉取镜像: $SOURCE_IMAGE"
    docker pull $SOURCE_IMAGE
    
    # 清理旧容器
    docker rm -f temp_extractor 2>/dev/null || true
    
    # 启动临时容器
    # 注意：left4devops 镜像有特定的 entrypoint，我们需要覆盖它以确保容器只休眠不执行其他操作
    echo "启动临时容器..."
    docker run -d --name temp_extractor --entrypoint /bin/sh $SOURCE_IMAGE -c "sleep 3600"
    
    # 复制文件
    # left4devops 镜像中，游戏通常安装在 /home/louis/l4d2
    echo "正在复制核心文件 (请耐心等待)..."
    docker cp temp_extractor:/home/louis/l4d2/. "$HOST_GAME_DIR/"
    
    # === 特殊处理：修复可能的符号链接 ===
    # left4devops 镜像可能会把 addons 和 cfg 软链接到根目录的 /addons 和 /cfg
    # 如果直接复制出来，宿主机上会得到指向不存在路径的死链接
    echo "检查并修复目录结构..."
    
    # 处理 addons
    if [ -L "$HOST_GAME_DIR/left4dead2/addons" ]; then
        echo "发现 addons 是软链接，正在替换为实体目录..."
        rm "$HOST_GAME_DIR/left4dead2/addons"
        mkdir -p "$HOST_GAME_DIR/left4dead2/addons"
        # 尝试从容器根目录的 /addons 复制内容（如果存在）
        docker cp temp_extractor:/addons/. "$HOST_GAME_DIR/left4dead2/addons/" 2>/dev/null || true
    fi

    # 处理 cfg
    if [ -L "$HOST_GAME_DIR/left4dead2/cfg" ]; then
        echo "发现 cfg 是软链接，正在替换为实体目录..."
        rm "$HOST_GAME_DIR/left4dead2/cfg"
        mkdir -p "$HOST_GAME_DIR/left4dead2/cfg"
        # 尝试从容器根目录的 /cfg 复制内容
        docker cp temp_extractor:/cfg/. "$HOST_GAME_DIR/left4dead2/cfg/" 2>/dev/null || true
    fi
    # =======================================
    
    # 清理
    docker rm -f temp_extractor
    docker rmi $SOURCE_IMAGE
    
    echo -e "${GREEN}文件提取完成！${NC}"
else
    echo -e "${GREEN}>>> [2/5] 检测到游戏文件已存在，跳过提取。${NC}"
fi

# 4. 修复权限 (至关重要)
echo -e "${YELLOW}>>> [3/5] 修正权限 (适配 Steam 用户 ID 1000)...${NC}"
# 确保所有文件属于 UID 1000 (容器内的 steam 用户)
chown -R 1000:1000 "$HOST_GAME_DIR"
chown -R 1000:1000 "$HOST_STEAM_DIR"
chown -R 1000:1000 "$HOST_APP_DIR"
chmod -R 755 "$HOST_GAME_DIR"

# 5. 检查源码并进入目录
echo -e "${YELLOW}>>> [4/5] 检查面板源码...${NC}"
if [ ! -f "Dockerfile" ]; then
    echo -e "当前目录未检测到 Dockerfile，执行克隆..."
    git clone https://github.com/Q1en/L4D2-Manager-Panel.git
    cd L4D2-Manager-Panel
    echo -e "${GREEN}已进入目录: $(pwd)${NC}"
else
    echo -e "${GREEN}检测到 Dockerfile，跳过克隆。${NC}"
fi

# 6. 启动服务
echo -e "${YELLOW}>>> [5/5] 启动 Docker Compose...${NC}"
if [ -f "docker-compose.yml" ]; then
    docker compose up -d --build
    echo -e "${GREEN}=== 部署完成！ ===${NC}"
    echo -e "请访问: http://你的IP:27020 进行管理"
else
    echo -e "${RED}错误: 当前目录下 ($(pwd)) 未找到 docker-compose.yml${NC}"
    echo -e "请检查克隆是否成功或文件是否缺失。"
    exit 1
fi