#!/bin/bash

echo "开始重建前端服务..."
docker-compose build frontend

echo "重启前端服务..."
docker-compose up -d frontend

echo "完成！" 