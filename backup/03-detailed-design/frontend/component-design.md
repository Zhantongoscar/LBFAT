/**
 * 前端组件设计
 * @description 定义前端组件的结构设计和实现规范
 */

## 相关文档
+ - [系统架构设计](../../02-architecture/system-architecture.md)
+ - [数据格式标准](../00-common/data-format-standard.md)
+ - [开发规范](../../04-standards/development-standard.md)

# 组件设计

/**
 * 组件结构
 * @description 定义组件的层次结构和组织方式
 */
## 1. 组件结构

/**
 * 组件通信
 * @description 定义组件间的通信机制
 */
## 2. 组件通信

/**
 * 状态管理
 * @description 定义组件的状态管理方案
 */
## 3. 状态管理

interface DeviceData {
    deviceId: number;
    userProject: string;
    device: string;
    status: string;
    rssi: number;
    lastOnlineAt: string;  // ISO 8601格式
}

export default {
    name: 'DeviceStatus',
    data() {
        return {
            deviceData: {} as DeviceData
        }
    }
}