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
