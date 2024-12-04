# MCU MQTT通信协议

## 1. 通信概述

### 1.1 连接信息
- MQTT Broker: EMQX
- 端口: 1883 (TCP) / 8083 (WebSocket)
- 认证: 无（开发环境）

### 1.2 主题格式
```
{project_name}/{module_type}/{serial_number}/{message_type}
```
- project_name: 项目名称，如 `lb_test`
- module_type: 模块类型，如 `EDB`
- serial_number: 设备序列号，如 `4`
- message_type: 消息类型，如 `status`

## 2. 消息格式

### 2.1 设备状态消息
主题：`{project_name}/{module_type}/{serial_number}/status`

在线状态：
```json
{
    "status": "online",
    "rssi": -71
}
```

离线状态（遗嘱消息）：
```json
{
    "status": "offline",
    "rssi": 0
}
```

参数说明：
- status: 设备状态
  * online: 在线
  * offline: 离线
- rssi: 信号强度（dBm）
  * 范围：0 ~ -100
  * 0表示离线或未知

### 2.2 消息处理流程
1. 设备上线：
   - 连接MQTT服务器
   - 发送上线状态消息
   - 设置遗嘱消息
   - 数据库自动记录通信时间（updated_at字段）

2. 设备离线：
   - 断开连接时，Broker自动发送遗嘱消息
   - 更新设备状态为离线
   - 保持最后通信时间不变（不更新updated_at字段）

3. 异常处理：
   - 如果连接断开但未收到遗嘱消息
   - 60秒后自动将设备标记为离线
   - 最后通信时间保持为最后一次成功通信的时间

### 2.3 状态显示要求
1. 设备基本信息：
   - 项目名称（project_name）
   - 模块类型（module_type）
   - 序列号（serial_number）

2. 通信状态：
   - 在线/离线状态标签（status）
   - RSSI信号强度进度条（rssi）
   - 最后通信时间（数据库updated_at字段）

3. 时间显示格式：
   - 数据来源：设备表（devices）的updated_at字段
   - 字段类型：TIMESTAMP，自动更新
   - 显示格式：本地时间，如 `2023-12-03 10:30:45`
   - 更新规则：
     * 收到在线消息时自动更新
     * 收到离线消息时保持不变
     * 超时离线时保持不变

## 3. 示例

### 3.1 设备上线
```
Topic: lb_test/EDB/4/status
Payload: {"status":"online","rssi":-71}
数据库记录：updated_at = 2023-12-03 10:30:45
```

### 3.2 设备离线
```
Topic: lb_test/EDB/4/status
Payload: {"status":"offline","rssi":0}
数据库记录：updated_at = 2023-12-03 10:30:45（保持不变）
```