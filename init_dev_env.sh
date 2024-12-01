#!/bin/bash

# 设置基础路径
BASE_DIR="/root/project/LBFAT/projectroot"
echo "开始初始化开发环境..."

# 1. 创建前端项目
echo "初始化前端项目..."
cd "${BASE_DIR}/frontend"
cat > package.json << 'EOF_FE'
{
  "name": "lbfat-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "serve": "vite preview"
  },
  "dependencies": {
    "vue": "^3.3.4",
    "vue-router": "^4.2.4",
    "pinia": "^2.1.6",
    "axios": "^1.5.0",
    "element-plus": "^2.3.14",
    "mqtt": "^5.0.5"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.3.4",
    "vite": "^4.4.9"
  }
}
EOF_FE

# 创建前端配置文件
cat > vite.config.js << 'EOF_VITE'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  }
})
EOF_VITE

# 2. 创建后端项目
echo "初始化后端项目..."
cd "${BASE_DIR}/backend"
cat > package.json << 'EOF_BE'
{
  "name": "lbfat-backend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "nodemon src/app.js",
    "start": "node src/app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.1",
    "mqtt": "^5.0.5",
    "redis": "^4.6.8",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF_BE

# 创建后端环境配置
cat > .env.example << 'EOF_ENV'
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=lbfat

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# MQTT
MQTT_HOST=localhost
MQTT_PORT=1883
MQTT_USERNAME=
MQTT_PASSWORD=
EOF_ENV

# 3. 创建Docker配置
echo "创建Docker配置..."

# Frontend Dockerfile
cd "${BASE_DIR}/docker/frontend"
cat > Dockerfile << 'EOF_DOCKERFILE_FE'
# Build stage
FROM node:18-alpine as builder
WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf
EOF_DOCKERFILE_FE

cat > nginx.conf << 'EOF_NGINX'
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF_NGINX

# Backend Dockerfile
cd "${BASE_DIR}/docker/backend"
cat > Dockerfile << 'EOF_DOCKERFILE_BE'
FROM node:18-alpine
WORKDIR /app
COPY backend/package*.json ./
RUN npm install
COPY backend/ .
CMD ["npm", "start"]
EOF_DOCKERFILE_BE

# MySQL配置
cd "${BASE_DIR}/docker/mysql"
cat > init.sql << 'EOF_SQL'
CREATE DATABASE IF NOT EXISTS lbfat;
USE lbfat;

-- 设备表
CREATE TABLE devices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_code VARCHAR(32) NOT NULL COMMENT '设备编码',
    device_name VARCHAR(64) NOT NULL COMMENT '设备名称',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-离线 1-在线',
    last_online_time DATETIME COMMENT '最后在线时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_device_code (device_code)
);

-- 设备数据表
CREATE TABLE device_data (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    temperature DECIMAL(5,2) COMMENT '温度',
    humidity DECIMAL(5,2) COMMENT '湿度',
    collect_time DATETIME NOT NULL COMMENT '采集时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device_time (device_id, collect_time)
);

-- 测试任务表
CREATE TABLE test_tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    task_name VARCHAR(64) NOT NULL COMMENT '任务名称',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待执行 1-执行中 2-已完成',
    start_time DATETIME COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device (device_id)
);

-- 设备告警表
CREATE TABLE device_alerts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    alert_type VARCHAR(32) NOT NULL COMMENT '告警类型',
    alert_level TINYINT NOT NULL COMMENT '告警级别：1-提示 2-警告 3-错误 4-严重',
    alert_content TEXT NOT NULL COMMENT '告警内容',
    is_handled TINYINT NOT NULL DEFAULT 0 COMMENT '是否处理：0-未处理 1-已处理',
    handle_time DATETIME COMMENT '处理时间',
    handle_note TEXT COMMENT '处理说明',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device_time (device_id, create_time)
);

-- 设备通信质量表
CREATE TABLE device_connection_quality (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    check_time DATETIME NOT NULL COMMENT '检测时间',
    packet_loss_rate DECIMAL(5,2) COMMENT '丢包率(%)',
    network_delay INT COMMENT '网络延迟(ms)',
    signal_strength INT COMMENT '信号强度(dBm)',
    connection_score INT COMMENT '连接质量评分(0-100)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device_check (device_id, check_time)
);
EOF_SQL

# EMQX配置
cd "${BASE_DIR}/docker/emqx"
cat > emqx.conf << 'EOF_EMQX'
node {
  name = "emqx@127.0.0.1"
  cookie = "emqxsecretcookie"
}

listeners.tcp.default {
  bind = "0.0.0.0:1883"
}

listeners.ws.default {
  bind = "0.0.0.0:8083"
}
EOF_EMQX

# 4. 创建docker-compose开发环境配置
cd "${BASE_DIR}"
cat > docker-compose.dev.yml << 'EOF_COMPOSE_DEV'
version: '3'

services:
  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=your_password
      - MYSQL_DATABASE=lbfat
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - lbfat-network

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    networks:
      - lbfat-network

  emqx:
    image: emqx/emqx:latest
    ports:
      - "1883:1883"
      - "8083:8083"
      - "18083:18083"
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
EOF_COMPOSE_DEV

# 5. 创建开发辅助脚本
mkdir -p "${BASE_DIR}/scripts"
cd "${BASE_DIR}/scripts"

# 开发环境启动脚本
cat > start-dev.sh << 'EOF_START'
#!/bin/bash
docker-compose -f ../docker-compose.dev.yml up -d
cd ../frontend && npm run dev &
cd ../backend && npm run dev
EOF_START

chmod +x start-dev.sh

echo "开发环境初始化完成！"
echo "请按以下步骤操作："
echo "1. cd ${BASE_DIR}"
echo "2. 在frontend和backend目录下分别执行 npm install"
echo "3. 执行 ./scripts/start-dev.sh 启动开发环境" 