#!/bin/bash

# 停止并删除现有的MySQL容器
echo "Stopping MySQL container..."
docker-compose stop mysql
docker-compose rm -f mysql

# 删除MySQL数据卷（如果需要完全重置数据）
echo "Removing MySQL volume..."
docker volume rm lbfat_mysql_data

# 重新创建并启动MySQL容器
echo "Starting new MySQL container..."
docker-compose up -d mysql

# 等待MySQL启动
echo "Waiting for MySQL to start..."
sleep 30

echo "Database update completed!" 