#!/bin/bash

# 设置基础路径
BASE_DIR="/root/project/LBFAT/projectroot"

# 创建项目基础结构
mkdir -p "${BASE_DIR}"/{frontend,backend,docker,scripts,docs}

# 前端项目结构
mkdir -p "${BASE_DIR}/frontend"/{src,public,tests}
mkdir -p "${BASE_DIR}/frontend/src"/{assets,components,views,store,utils,api}

# 后端项目结构
mkdir -p "${BASE_DIR}/backend"/{src,config,tests}
mkdir -p "${BASE_DIR}/backend/src"/{controllers,services,models,utils}

# Docker配置目录
mkdir -p "${BASE_DIR}/docker"/{frontend,backend,mysql,emqx}

# 创建目录说明文件
cat > "${BASE_DIR}/README.md" << 'EOF_README'
# LBFAT项目结构

projectroot/
├── frontend/                # 前端项目
│   ├── src/                # 源代码
│   │   ├── assets/        # 静态资源
│   │   ├── components/    # 组件
│   │   ├── views/         # 页面
│   │   ├── store/         # 状态管理
│   │   ├── utils/         # 工具函数
│   │   └── api/           # API接口
│   ├── public/            # 公共资源
│   ├── tests/             # 测试文件
│   ├── package.json       # 依赖配置
│   └── vue.config.js      # Vue配置
│
├── backend/                # 后端项目
│   ├── src/               # 源代码
│   │   ├── controllers/   # 控制器
│   │   ├── services/      # 服务层
│   │   ├── models/        # 数据模型
│   │   └── utils/         # 工具函数
│   ├── config/            # 配置文件
│   ├── tests/             # 测试文件
│   └── package.json       # 依赖配置
│
├── docker/                 # Docker配置
│   ├── frontend/          # 前端Docker配置
│   │   ├── Dockerfile
│   │   └── nginx.conf
│   ├── backend/           # 后端Docker配置
│   │   ├── Dockerfile
│   │   └── .env.example
│   ├── mysql/             # MySQL配置
│   │   ├── Dockerfile
│   │   ├── init.sql
│   │   └── my.cnf
│   └── emqx/              # EMQX配置
│       ├── Dockerfile
│       └── emqx.conf
│
├── scripts/               # 部署和维护脚本
│   ├── deploy.sh         # 部署脚本
│   ├── backup.sh         # 备份脚本
│   └── init-dev.sh       # 开发环境初始化
│
└── docker-compose.yml     # 容器编排配置

## 开发和部署说明

### 1. 开发环境设置
- 初始化开发环境: ./scripts/init-dev.sh
- 启动开发环境: docker-compose -f docker-compose.dev.yml up

### 2. 生产环境部署
- 部署应用: ./scripts/deploy.sh
- 备份数据: ./scripts/backup.sh

### 3. 容器说明
- frontend: Vue.js前端应用
- backend: Node.js后端服务
- mysql: 数据库服务
- emqx: MQTT消息服务
EOF_README

# 创建Docker配置文件
cat > "${BASE_DIR}/docker/frontend/Dockerfile" << 'EOF_FRONTEND'
FROM node:18-alpine as builder
WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf
EOF_FRONTEND

cat > "${BASE_DIR}/docker/backend/Dockerfile" << 'EOF_BACKEND'
FROM node:18-alpine
WORKDIR /app
COPY backend/package*.json ./
RUN npm install
COPY backend/ .
CMD ["npm", "start"]
EOF_BACKEND

# 创建docker-compose配置
cat > "${BASE_DIR}/docker-compose.yml" << 'EOF_COMPOSE'
version: '3'

services:
  frontend:
    build:
      context: .
      dockerfile: docker/frontend/Dockerfile
    ports:
      - "80:80"
    networks:
      - lbfat-network

  backend:
    build:
      context: .
      dockerfile: docker/backend/Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    networks:
      - lbfat-network

  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=lbfat
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - lbfat-network

  emqx:
    image: emqx/emqx:latest
    ports:
      - "1883:1883"
      - "8083:8083"
    volumes:
      - emqx_data:/opt/emqx/data
      - ./docker/emqx/emqx.conf:/opt/emqx/etc/emqx.conf
    networks:
      - lbfat-network

networks:
  lbfat-network:
    driver: bridge

volumes:
  mysql_data:
  emqx_data:
EOF_COMPOSE

# 删除docs中的docker-compose.yml
rm -f "${BASE_DIR}/../docs/03-detailed-design/05-deployment/docker-compose.yml"

# 在05-deployment目录中添加说明
cat > "${BASE_DIR}/../docs/03-detailed-design/05-deployment/container-deployment.md" << 'EOF_DEPLOY'
# 容器部署说明

## 配置文件位置
docker-compose.yml 位于项目根目录：/root/project/LBFAT/projectroot/docker-compose.yml

## 部署步骤
1. 确保所有配置文件就绪
2. 执行部署脚本
3. 验证服务状态

## 配置文件说明
具体的docker-compose配置请参考项目根目录下的docker-compose.yml文件
EOF_DEPLOY

echo "项目目录结构创建完成！" 