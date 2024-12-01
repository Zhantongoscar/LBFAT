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
