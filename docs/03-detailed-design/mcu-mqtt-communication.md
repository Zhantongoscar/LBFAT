# MCU MQTT通信设计文档

## 1. 设备上下线场景

### 1.1 MQTT主题设计
- 主题格式: `{project}/{module_type}/{serial_number}/status`
- 示例: `lb_test/EDB/4/status`
- 消息格式:
```json
{
    "status": "online|offline",  // 设备状态
    "rssi": number              // 信号强度
}
```

### 1.2 数据流程
1. MCU发布状态
   - 设备上线时发布 online 消息
   - 设备离线通过MQTT遗嘱机制发送 offline 消息

2. 后端处理
   - 根据项目订阅配置订阅相应主题
   - 接收状态消息后自动创建或更新设备信息
   - 通过WebSocket向前端推送状态变更

3. 数据库设计
```sql
-- 项目订阅表
CREATE TABLE project_subscriptions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(32) NOT NULL COMMENT '项目名称',
    is_subscribed TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否订阅',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_project_name (project_name)
);

-- 设备表
CREATE TABLE devices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(32) NOT NULL COMMENT '项目名称',
    module_type VARCHAR(32) NOT NULL COMMENT '模块类型',
    serial_number VARCHAR(32) NOT NULL COMMENT '序列号',
    status VARCHAR(16) NOT NULL DEFAULT 'offline' COMMENT '当前状态',
    rssi INT COMMENT '信号强度',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_device (project_name, module_type, serial_number)
);
``` 