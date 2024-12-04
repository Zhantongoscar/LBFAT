#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 函数：显示帮助信息
show_help() {
    echo "使用方法:"
    echo "  ./docker-control.sh [命令]"
    echo ""
    echo "可用命令:"
    echo "  start     - 启动所有容器"
    echo "  stop      - 停止所有容器"
    echo "  restart   - 重启所有容器"
    echo "  status    - 查看容器状态"
    echo "  logs      - 查看容器日志"
    echo "  clean     - 清理未使用的资源"
}

# 函数：启动容器
start_containers() {
    echo -e "${GREEN}启动容器...${NC}"
    docker-compose up -d
    docker-compose ps
}

# 函数：停止容器
stop_containers() {
    echo -e "${RED}停止容器...${NC}"
    docker-compose down
}

# 函数：重启容器
restart_containers() {
    echo -e "${GREEN}重启容器...${NC}"
    docker-compose restart
    docker-compose ps
}

# 函数：查看状态
show_status() {
    echo -e "${GREEN}容器状态:${NC}"
    docker-compose ps
    echo -e "\n${GREEN}资源使用情况:${NC}"
    docker stats --no-stream
}

# 函数：查看日志
show_logs() {
    echo -e "${GREEN}容器日志:${NC}"
    docker-compose logs --tail=100
}

# 函数：清理资源
clean_resources() {
    echo -e "${RED}清理未使用的资源...${NC}"
    docker system prune -f
    docker volume prune -f
}

# 主逻辑
case "$1" in
    "start")
        start_containers
        ;;
    "stop")
        stop_containers
        ;;
    "restart")
        restart_containers
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "clean")
        clean_resources
        ;;
    *)
        show_help
        ;;
esac 