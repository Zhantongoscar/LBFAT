#!/bin/bash

echo "开始更新详细设计文档结构..."

# 设置基础路径
BASE_DIR="/root/project/LBFAT/docs/03-detailed-design"

# 创建目录结构
mkdir -p "${BASE_DIR}"/{00-common,01-core,02-modules/{device,test},03-protocols,04-database,05-deployment}

# 1. 更新文档索引
cat > "${BASE_DIR}/index.md" << 'EOF1'
# 详细设计文档

## 1. 系统架构
### 1.1 容器架构
- Frontend Container (Vue.js)
- Backend Container (Node.js)
- MySQL Container
- EMQX Container

### 1.2 容器通信
- Frontend <-> Backend: HTTP/WebSocket
- Backend <-> MySQL: TCP 3306
- Backend <-> EMQX: MQTT 1883
- Frontend <-> EMQX: MQTT over WebSocket 8083

## 2. 模块设计
### 2.1 前端模块 (Frontend)
- 设备管理界面
- 测试任务管理
- 数据可视化
- WebSocket实时更新

### 2.2 后端模块 (Backend)
- RESTful API服务
- MQTT客户端服务
- 数据处理服务
- 缓存管理

### 2.3 EMQX配置
- MQTT主题设计
- WebSocket支持
- 认证配置
- 规则引擎

### 2.4 数据库设计
- 设备管理表
- 测试数据表
- 任务管理表

## 3. 部署架构
### 3.1 Docker配置
EOF1

# 2. 添加协议设计文档
cat > "${BASE_DIR}/03-protocols/mqtt-topics.md" << 'EOF2'
# MQTT主题设计

## 1. 主题命名规范
### 1.1 设备相关主题
- 设备数据：device/{deviceId}/data
- 设备状态：device/{deviceId}/status
- 设备控制：device/{deviceId}/control

### 1.2 测试相关主题
- 测试数据：test/{testId}/data
- 测试状态：test/{testId}/status
- 测试结果：test/{testId}/result

## 2. QoS级别设计
- QoS 1：设备数据和测试数据

## 3. 消息持久化策略
- 设备状态：保留最新状态
- 测试数据：持久化存储
EOF2

# 3. 添加数据库设计文档
cat > "${BASE_DIR}/04-database/schema.md" << 'EOF3'
# 数据库设计

## 1. 设备相关表
### 1.1 设备基本信息表
EOF3

# 4. 添加容器化部署约定文档
mkdir -p "${BASE_DIR}/05-deployment"
cat > "${BASE_DIR}/05-deployment/container-specs.md" << 'EOF_CONTAINER'
# 容器化部署规范

## 1. 容器结构
/root/project/LBFAT/
├── docker/
│   ├── frontend/          # 前端容器配置
│   │   ├── Dockerfile
│   │   └── nginx.conf
│   ├── backend/           # 后端容器配置
│   │   ├── Dockerfile
│   │   └── .env
│   ├── mysql/            # MySQL容器配置
│   │   ├── Dockerfile
│   │   ├── init.sql
│   │   └── my.cnf
│   └── emqx/             # EMQX容器配置
│       ├── Dockerfile
│       └── emqx.conf
└── docker-compose.yml    # 容器编排配置

## 2. 容器配置约定

### 2.1 Frontend容器
- 基础镜像: nginx:alpine
- 端口映射: 80:80
- 环境变量:
  - VUE_APP_API_URL
  - VUE_APP_WS_URL

### 2.2 Backend容器
- 基础镜像: node:18-alpine
- 端口映射: 3000:3000
- 环境变量:
  - NODE_ENV=production
  - DB_HOST=mysql
  - DB_PORT=3306
  - MQTT_HOST=emqx
  - MQTT_PORT=1883

### 2.3 MySQL容器
- 基础镜像: mysql:8.0
- 端口映射: 3306:3306
- 环境变量:
  - MYSQL_ROOT_PASSWORD
  - MYSQL_DATABASE
- 数据卷: mysql_data:/var/lib/mysql

### 2.4 EMQX容器
- 基础镜像: emqx/emqx:latest
- 端口映射: 
  - 1883:1883 (MQTT)
  - 8083:8083 (WebSocket)
- 环境变量:
  - EMQX_NAME=emqx
  - EMQX_HOST=0.0.0.0

## 3. 网络配置
所有容器都将加入自定义网络：lbfat-network
- 网络类型：bridge
- 容器间通过服务名互相访问
- 外部访问通过端口映射

## 4. 数据卷配置
### 4.1 MySQL数据卷
- 卷名：mysql_data
- 挂载点：/var/lib/mysql
- 用途：持久化数据库数据

### 4.2 EMQX数据卷
- 卷名：emqx_data
- 挂载点：/opt/emqx/data
- 用途：持久化MQTT数据

## 5. 容器间通信
### 5.1 通信方式
- Frontend -> Backend: HTTP/WebSocket (3000)
- Backend -> MySQL: TCP (3306)
- Backend -> EMQX: MQTT (1883)
- Frontend -> EMQX: WebSocket (8083)

### 5.2 服务发现
- 使用Docker内置DNS
- 通过服务名访问
- 自动负载均衡

## 6. 开发流程
1. 本地开发
   - 克隆代码仓库
   - 安装Docker和Docker Compose
   - 启动开发环境

2. 测试部署
   - 构建测试镜像
   - 运行容器测试
   - 验证功能

3. 生产部署
   - 准备环境变量
   - 构建生产镜像
   - 部署服务
   - 监控运行状态
EOF_CONTAINER

# 添加docker-compose示例
cat > "${BASE_DIR}/05-deployment/docker-compose.yml" << 'EOF_COMPOSE'
version: '3'

services:
  frontend:
    build:
      context: ./docker/frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      - VUE_APP_API_URL=http://localhost:3000
      - VUE_APP_WS_URL=ws://localhost:8083
    networks:
      - lbfat-network

  backend:
    build:
      context: ./docker/backend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_PORT=3306
      - MQTT_HOST=emqx
      - MQTT_PORT=1883
    networks:
      - lbfat-network

  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=your_password
      - MYSQL_DATABASE=lbfat
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - lbfat-network

  emqx:
    image: emqx/emqx:latest
    ports:
      - "1883:1883"
      - "8083:8083"
    volumes:
      - emqx_data:/opt/emqx/data
    networks:
      - lbfat-network

networks:
  lbfat-network:
    driver: bridge

volumes:
  mysql_data:
  emqx_data:
EOF_COMPOSE

echo "容器化部署文档更新完成！"

# 补充数据类型定义
cat > "${BASE_DIR}/00-common/data-types.md" << 'EOF_TYPES'
# 数据类型定义

## 1. 基础数据类型
### 1.1 设备数据
{
    "deviceId": "string",    // 设备唯一标识
    "timestamp": "number",   // 时间戳
    "data": {
        "temperature": "number",
        "humidity": "number",
        "status": "string"
    }
}

### 1.2 测试数据
{
    "testId": "string",      // 测试ID
    "deviceId": "string",    // 设备ID
    "startTime": "number",   // 开始时间
    "endTime": "number",     // 结束时间
    "results": [{
        "type": "string",    // 测试类型
        "value": "number",   // 测试值
        "status": "string"   // 测试状态
    }]
}
EOF_TYPES

# 补充错误码定义
cat > "${BASE_DIR}/00-common/error-codes.md" << 'EOF_ERRORS'
# 错误码定义

## 1. 系统错误 (1000-1999)
- 1000: 系统内部错误
- 1001: 数据库操作失败
- 1002: MQTT连接失败

## 2. 业务错误 (2000-2999)
- 2000: 设备不存在
- 2001: 设备离线
- 2002: 测试执行失败

## 3. 数据错误 (3000-3999)
- 3000: 数据格式错误
- 3001: 数据超出范围
- 3002: 数据不完整
EOF_ERRORS

# 补充01-core文档
cat > "${BASE_DIR}/01-core/data-sync.md" << 'EOF_SYNC'
# 数据同步机制设计

## 1. EMQX -> MySQL同步
### 1.1 实时数据同步
- EMQX规则引擎触发
- 数据格式转换
- MySQL写入操作

### 1.2 状态同步
- 设备状态变更触发
- Redis缓存更新
- MySQL定期同步

## 2. 数据一致性保证
### 2.1 实时数据处理
- 消息队列缓冲
- 批量写入策略
- 失败重试机制

### 2.2 异常处理
- 网络断开处理
- 数据补偿机制
- 状态恢复策略
EOF_SYNC

cat > "${BASE_DIR}/01-core/cache-strategy.md" << 'EOF_CACHE'
# 缓存策略设计

## 1. Redis缓存设计
### 1.1 缓存内容
- 设备实时状态
- 最新测试数据
- 热点配置信息

### 1.2 缓存策略
- 写入策略：实时更新
- 过期策略：定时过期
- 淘汰策略：LRU

## 2. 缓存同步
### 2.1 MySQL同步
- 定期同步
- 按需同步
- 异常恢复

### 2.2 一致性保证
- 先更新数据库
- 再更新缓存
- 失效通知机制
EOF_CACHE

cat > "${BASE_DIR}/01-core/mqtt-service.md" << 'EOF_MQTT'
# MQTT服务设计

## 1. 连接管理
### 1.1 连接认证
- 设备ID验证
- Token认证
- 连接限制

### 1.2 会话管理
- 会话保持
- 离线消息
- 心跳检测

## 2. 消息处理
### 2.1 消息流转
- 消息接收
- 规则处理
- 数据转发

### 2.2 QoS策略
- QoS0：最多一次
- QoS1：至少一次（默认）
- QoS2：精确一次（关键数据）
EOF_MQTT

# 补充02-modules/device文档
cat > "${BASE_DIR}/02-modules/device/device-management.md" << 'EOF_DEVICE'
# 设备管理流程

## 1. 设备生命周期
### 1.1 设备注册
- 生成设备ID
- 配置设备信息
- 生成访问Token

### 1.2 设备运行
- 状态监控
- 数据采集
- 命令下发

### 1.3 设备离线
- 状态更新
- 数据保存
- 告警处理

## 2. 设备控制
### 2.1 远程控制
- 命令下发
- 执行确认
- 结果反馈

### 2.2 状态管理
- 在线状态
- 运行状态
- 告警状态
EOF_DEVICE

cat > "${BASE_DIR}/02-modules/device/data-collection.md" << 'EOF_COLLECT'
# 数据采集流程

## 1. 采集配置
### 1.1 采集点配置
- 采集项定义
- 采集频率
- 数据类型

### 1.2 存储配置
- 实时数据
- 历史数据
- 统计数据

## 2. 数据处理
### 2.1 数据验证
- 格式验证
- 范围检查
- 有效性验证

### 2.2 数据转换
- 单位转换
- 格式转换
- 数据压缩
EOF_COLLECT

# 补充02-modules/test文档
cat > "${BASE_DIR}/02-modules/test/test-execution.md" << 'EOF_TEST'
# 测试执行流程

## 1. 测试准备
### 1.1 任务创建
- 测试计划
- 参数配置
- 设备准备

### 1.2 前置检查
- 设备状态
- 环境检查
- 参数验证

## 2. 测试执行
### 2.1 执行控制
- 启动测试
- 监控执行
- 异常处理

### 2.2 数据采集
- 实时采集
- 数据存储
- 状态更新
EOF_TEST

cat > "${BASE_DIR}/02-modules/test/test-report.md" << 'EOF_REPORT'
# 测试报告生成

## 1. 数据处理
### 1.1 数据分析
- 数据统计
- 趋势分析
- 异常检测

### 1.2 结果评估
- 合格判定
- 异常标记
- 结果分类

## 2. 报告生成
### 2.1 报告内容
- 基本信息
- 测试数据
- 分析结果
- 结论建议

### 2.2 报告格式
- PDF格式
- Excel格式
- 在线查看
EOF_REPORT

# 补充04-database文档
cat > "${BASE_DIR}/04-database/table-relations.md" << 'EOF_RELATIONS'
# 数据库表关系设计

## 1. 核心表关系
### 1.1 设备相关
- devices -> device_data (1:n)
- devices -> device_status (1:1)
- devices -> device_config (1:1)

### 1.2 测试相关
- test_tasks -> test_results (1:n)
- test_tasks -> devices (n:1)
- test_results -> device_data (1:n)

## 2. 索引设计
### 2.1 主要索引
- devices: device_code (uk)
- device_data: device_id + collect_time (idx)
- test_tasks: device_id + start_time (idx)
EOF_RELATIONS

cat > "${BASE_DIR}/04-database/data-sync.md" << 'EOF_DB_SYNC'
# 数据同步策略

## 1. 实时同步
### 1.1 设备数据
- EMQX规则引擎触发
- 批量写入优化
- 异常重试机制

### 1.2 状态同步
- Redis实时更新
- MySQL定期同步
- 状态校验机制

## 2. 历史数据
### 2.1 数据归档
- 定期归档
- 分表策略
- 清理策略

### 2.2 数据恢复
- 备份策略
- 恢复流程
- 一致性校验
EOF_DB_SYNC

echo "补充设计文档完成！"

echo "详细设计文档更新完成！"
