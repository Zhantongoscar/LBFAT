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
