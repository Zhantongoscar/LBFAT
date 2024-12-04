# 测试指南

## 1. 环境准备

### 1.1 启动服务
1. 启动所有Docker容器：
```bash
docker-compose up -d
```

2. 确认服务状态：
- EMQX: http://localhost:18083 (默认用户名/密码: admin/public)
- MySQL: 端口3306可访问
- 后端: http://localhost:3000/health 返回正常
- 前端: http://localhost:8080 可访问

### 1.2 配置项目订阅
1. 访问前端页面：http://localhost:8080
2. 在项目管理页面：
   - 确认 `lb_test` 项目存在
   - 确认订阅状态为"已订阅"

## 2. 运行测试客户端

### 2.1 安装依赖
```bash
cd tests
npm install mqtt readline
```

### 2.2 运行测试
```bash
node mqtt-client.js
```

### 2.3 测试命令
- `1`: 发送上线状态
- `2`: 发送离线状态
- `3`: 更新RSSI值（随机）
- `q`: 退出程序（自动发送离线状态）

## 3. 验证测试结果

### 3.1 数据库验证
```sql
-- 查看设备状态
SELECT * FROM devices WHERE project_name = 'lb_test' ORDER BY updated_at DESC;
```

### 3.2 前端验证
1. 访问设备列表页面
2. 选择 `lb_test` 项目
3. 观察设备状态变化：
   - 状态标签（在线/离线）
   - RSSI值变化
   - 最后通信时间更新

### 3.3 预期结果
1. 发送上线状态时：
   - 数据库记录 status = 'online'
   - 前端显示绿色"在线"标签
   - 更新最后通信时间

2. 发送离线状态时：
   - 数据库记录 status = 'offline'
   - 前端显示红色"离线"标签
   - 保持最后通信时间不变

3. 更新RSSI时：
   - 数据库记录新的RSSI值
   - 前端进度条显示更新
   - 更新最后通信时间 