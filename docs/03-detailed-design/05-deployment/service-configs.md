# 服务配置说明

## 1. MySQL配置

### 1.1 基础配置
- 版本：MySQL 5.7
- 端口：3306
- 数据库名：lbfat
- 字符集：utf8mb4
- 排序规则：utf8mb4_unicode_ci

### 1.2 认证配置
- 认证方式：mysql_native_password（传统认证）
- Root密码：13701033228
- Root访问权限：root@%（允许远程访问）

### 1.3 重要配置文件
1. docker-compose.yml中的MySQL配置：
```yaml
mysql:
  image: mysql:5.7
  environment:
    - MYSQL_ROOT_PASSWORD=13701033228
    - MYSQL_DATABASE=lbfat
    - MYSQL_ROOT_HOST=%
  command:
    - --default-authentication-plugin=mysql_native_password
    - --character-set-server=utf8mb4
    - --collation-server=utf8mb4_unicode_ci
```

2. my.cnf配置：
```ini
[mysqld]
skip-host-cache
skip-name-resolve
default-authentication-plugin=mysql_native_password
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
```

### 1.4 注意事项
1. MySQL 8.0版本有鉴权问题，必须使用5.7版本
2. 必须允许root用户远程访问（root@%）
3. 必须使用传统密码认证方式
4. 必须设置正确的字符集和排序规则

## 2. EMQX配置

### 2.1 基础配置
- 版本：EMQX Latest
- 端口映射：
  - 1883 -> 11883 (MQTT)
  - 18083 -> 18083 (Dashboard)
  - 8083 -> 18084 (WebSocket)

### 2.2 MQTT主题设计
1. 设备状态主题：
   - 格式：`myproject/{device_type}/{device_id}/status`
   - 示例：`myproject/EDB/4/status`
   - Payload示例：
     ```json
     {
       "status": "online",
       "rssi": -71
     }
     ```

2. 设备遗嘱消息：
   - 与状态主题相同
   - Payload示例：
     ```json
     {
       "status": "offline",
       "rssi": 0
     }
     ```

### 2.3 注意事项
1. MQTT端口使用11883避免与其他服务冲突
2. WebSocket端口使用18084
3. 确保设备遗嘱消息正确配置
4. 注意主题格式的一致性

## 3. Backend配置

### 3.1 基础配置
- 运行环境：Node.js
- 端口：3000
- 开发模式：development

### 3.2 数据库连接配置
```yaml
environment:
  - NODE_ENV=development
  - DB_HOST=mysql
  - DB_PORT=3306
  - DB_USER=root
  - DB_PASSWORD=13701033228
  - DB_NAME=lbfat
```

### 3.3 MQTT连接配置
```yaml
environment:
  - MQTT_HOST=emqx
  - MQTT_PORT=1883
```

### 3.4 API路由设计
1. 设备状态相关：
   - GET /:deviceId/status - 获取设备当前状态
   - GET /:deviceId/status/history - 获取状态历史
   - GET /:deviceId/heartbeats - 获取心跳历史

2. 设备告警相关：
   - GET /:deviceId/alerts - 获取告警列表
   - PUT /alerts/:alertId/handle - 处理告警

3. 通信质量相关：
   - GET /:deviceId/connection-quality/history - 获取质量历史
   - GET /:deviceId/connection-quality/stats - 获取质量统计

### 3.5 注意事项
1. 确保数据库连接配置与MySQL配置一致
2. 确保MQTT连接配置与EMQX配置一致
3. API路由需要添加适当的错误处理
4. 注意数据库事务的完整性

## 4. 设备通信规范

### 4.1 设备标识
- 设备类型：EDB（测试模块）
- 设备ID：从1开始的整数
- 设备编码格式：{type}_{id}，例如：EDB_4

### 4.2 通信要求
1. 连接要求：
   - 使用MQTT协议
   - 必须配置遗嘱消息
   - 保持定期心跳

2. 消息格式：
   - 使用JSON格式
   - UTF-8编码
   - 必须包含状态信息
   - 必须包含信号强度(RSSI)

### 4.3 状态定义
- online：设备在线
- offline：设备离线
- error：设备错误

## 5. 其他服务配置待补充
- Frontend配置
- Redis配置

## 6. Docker操作规范

### 6.1 容器管理注意事项
1. 检查容器状态：
   - 使用 `docker ps -a` 而不是 `docker ps`
   - 原因：停止的容器可能仍然占用端口
   - 示例：`docker ps -a | grep emqx`

2. 清理容器步骤：
   ```bash
   # 1. 查看所有容器（包括停止的）
   docker ps -a
   
   # 2. 停止所有容器
   docker-compose down
   
   # 3. 删除所有停止的容器
   docker rm $(docker ps -aq)
   
   # 4. 清理网络和卷
   docker system prune -f
   docker volume prune -f
   ```

3. 端口占用处理：
   - 先用 `docker ps -a` 检查是否有停止的容器占用端口
   - 确保完全删除相关容器后再重新启动服务
   - 不要只依赖 `docker-compose down`

### 6.2 常见问题处理
1. 端口已被占用：
   ```bash
   # 错误方式：
   netstat -tunlp | grep <port>  # 这可能看不到Docker停止容器占用的端口
   
   # 正确方式：
   docker ps -a  # 检查所有容器
   docker rm <container_id>  # 删除特定容器
   ```

2. 容器无法删除：
   ```bash
   # 强制删除容器
   docker rm -f <container_id>
   ```

3. 服务启动失败：
   ```bash
   # 1. 检查所有容器状态
   docker ps -a
   
   # 2. 查看容器日志
   docker logs <container_id>
   ```