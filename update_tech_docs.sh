#!/bin/bash

# 设置基础路径
DOCS_DIR="/root/project/LBFAT/docs/03-detailed-design/06-tech-stack"

# 创建目录
mkdir -p "${DOCS_DIR}"

# 1. 创建技术栈文档
cat > "${DOCS_DIR}/tech-stack.md" << 'EOF_TECH'
# 技术栈说明

## 1. 前端技术栈
- Vue.js 3.0 (前端框架)
- Vite (构建工具)
- Element Plus (UI组件库)
- Pinia (状态管理)
- Axios (HTTP客户端)
- MQTT.js (MQTT客户端)

## 2. 后端技术栈
- Node.js (运行环境)
- Express (Web框架)
- MySQL (数据库)
- Redis (缓存)
- MQTT.js (MQTT客户端)

## 3. 中间件
- EMQX (MQTT Broker)
- Redis (缓存服务)
- MySQL (数据库服务)

## 4. 开发工具
- Git (版本控制)
- Docker (容器化)
- VS Code (IDE)
EOF_TECH

# 2. 创建学习路线文档
cat > "${DOCS_DIR}/learning-path.md" << 'EOF_LEARN'
# 学习路线指南

## 1. 基础知识
### 1.1 JavaScript基础
- 语法基础
- ES6+特性
- 异步编程
- Promise/async/await

### 1.2 Node.js基础
- 模块系统
- 事件循环
- npm包管理
- Express框架

### 1.3 Vue.js基础
- 组件系统
- 生命周期
- 响应式原理
- 路由管理

## 2. 进阶学习
### 2.1 后端开发
- Express应用开发
- MySQL数据库操作
- Redis缓存使用
- MQTT服务集成

### 2.2 前端开发
- Vue3组件开发
- Element Plus使用
- Pinia状态管理
- MQTT客户端集成

## 3. 项目实践
### 3.1 开发流程
1. 环境搭建
2. 后端API开发
3. 前端界面实现
4. 数据流处理
5. 测试和部署

### 3.2 推荐资源
- Vue.js官方文档: https://vuejs.org/
- Node.js官方文档: https://nodejs.org/
- Express官方文档: https://expressjs.com/
EOF_LEARN

# 3. 创建版本说明文档
cat > "${DOCS_DIR}/versions.md" << 'EOF_VER'
# 版本说明

## 1. 环境要求
- Node.js >= 18.0.0
- MySQL >= 8.0
- Redis >= 6.0
- EMQX >= 4.4.19

## 2. 前端依赖
{
  "dependencies": {
    "vue": "^3.3.4",
    "vue-router": "^4.2.4",
    "pinia": "^2.1.6",
    "axios": "^1.5.0",
    "element-plus": "^2.3.14",
    "mqtt": "^5.0.5"
  }
}

## 3. 后端依赖
{
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.1",
    "mqtt": "^5.0.5",
    "redis": "^4.6.8",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  }
}
EOF_VER

echo "技术栈文档创建完成！"
