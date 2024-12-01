/**
 * 通信架构设计
 * @description 定义系统的通信机制、协议和数据格式
 */

## 1. 通信机制
- 采用MQTT协议作为统一通信方式
- 所有组件通过MQTT进行消息交换
- 实时数据通过MQTT主题订阅获取
- 设备控制通过MQTT指令下发

## 2. 消息流转
- 设备状态上报 -> MQTT服务器 -> 订阅方
- 控制指令下发 -> MQTT服务器 -> 设备执行
- 执行结果反馈 -> MQTT服务器 -> 订阅方

## 3. 通信参数（需求1.5.2）
- QoS级别：1
- 消息超时：3秒
- 重试次数：3次
- 心跳间隔：30秒
- 离线判定：90秒
- 设备响应时间
  * 命令响应：<1000ms
  * 数据上报：<2000ms
  * 异常通知：实时

## 4. 认证机制（需求1.9.1）
- MQTT基本认证（用户名密码）
- 用户权限控制
  * 系统管理员：系统配置和维护权
  * 测试管理员：测试任务管理权限
  * 测试人员：执行测试权限
  * 查看人员：查看报告权限
- 操作日志记录

## 5. 主题设计（需求1.14.1）
- 状态主题：{project}/{device_type}/{device_id}/status
- 命令主题：{project}/{device_type}/{device_id}/{unit_id}/command
- 响应主题：{project}/{device_type}/{device_id}/{unit_id}/response

## 6. 重传策略（需求1.14.6）
- 命令消息重传
  * 初次等待：500ms
  * 重传间隔：1s
  * 最大重试：3次
  * 超时时间：3s
- 状态消息重传
  * 心跳间隔：30s
  * 离线判定：90s
  * 最大重连：5次/分钟
  * 重连间隔：递增（1s, 2s, 4s...）

## 相关文档
- [需求分析-MQTT通信协议](../01-requirements/requirement-analysis.md#114-mqtt通信协议)
- [MQTT设计](../03-detailed-design/backend/mqtt-design.md)
- [数据格式标准](../03-detailed-design/00-common/data-format-standard.md)