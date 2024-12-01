# 数据类型定义

## 1. 基础数据类型
### 1.1 设备数据
{
    "deviceId": "string",    // 设备唯一标识
    "timestamp": "number",   // 时间戳
    "data": {
        "temperature": "number",
        "humidity": "number",
        "status": "string"
    }
}

### 1.2 测试数据
{
    "testId": "string",      // 测试ID
    "deviceId": "string",    // 设备ID
    "startTime": "number",   // 开始时间
    "endTime": "number",     // 结束时间
    "results": [{
        "type": "string",    // 测试类型
        "value": "number",   // 测试值
        "status": "string"   // 测试状态
    }]
}
