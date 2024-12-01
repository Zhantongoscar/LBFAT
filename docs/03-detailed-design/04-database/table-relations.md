# 数据库表关系设计

## 1. 核心表关系
### 1.1 设备相关
- devices -> device_data (1:n)
- devices -> device_status (1:1)
- devices -> device_config (1:1)

### 1.2 测试相关
- test_tasks -> test_results (1:n)
- test_tasks -> devices (n:1)
- test_results -> device_data (1:n)

## 2. 索引设计
### 2.1 主要索引
- devices: device_code (uk)
- device_data: device_id + collect_time (idx)
- test_tasks: device_id + start_time (idx)
