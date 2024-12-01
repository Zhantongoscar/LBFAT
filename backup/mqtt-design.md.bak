/**
 * MQTT实现设计
 * @description 定义MQTT服务实现
 */

## 1. 接口定义
interface IMQTTService {
   /**
    * MQTT连接管理
    */
   void connect();
   void disconnect();
   
   /**
    * 消息发布订阅
    */
   void publish(String topic, String payload, QoSLevel qos);
   void subscribe(String topic, QoSLevel qos);
   void unsubscribe(String topic);
   
   /**
    * 连接状态管理
    */
   boolean isConnected();
   void reconnect();
   
   /**
    * 消息处理
    */
   void onMessage(MessageHandler handler);
   void onError(ErrorHandler handler);
}

## 2. 配置定义
/**
 * MQTT配置常量
 */
const MQTTConfig = {
    clientId: "backend",
    keepAlive: 60,
    cleanSession: true,
    reconnectPeriod: 1000,
    connectTimeout: 30000,
    defaultQoS: 1,
    retryTimes: 3,
    retryInterval: 1000,
    username: "user",
    password: "password"
};

## 3. 主题定义
/**
 * MQTT主题格式
 * 参考需求文档 1.14.1 节
 */
const MQTT_TOPICS = {
    status: "{project}/{device_type}/{device_id}/status",
    command: "{project}/{device_type}/{device_id}/{unit_id}/command",
    response: "{project}/{device_type}/{device_id}/{unit_id}/response"
};

## 4. 消息格式
/**
 * MQTT消息格式
 * 参考需求文档 1.14.4 节
 */
interface MQTTMessage {
    messageId: string;
    timestamp: string;
    type: 'status' | 'command' | 'response';
    deviceId: number;
    project: string;
    deviceType: string;
    payload: any;
}

## 5. 重传机制
/**
 * 重传策略
 * 参考需求文档 1.14.6 节
 */
const RetryStrategy = {
    command: {
        initialWait: 500,
        retryInterval: 1000,
        maxRetries: 3,
        timeout: 3000
    },
    status: {
        heartbeatInterval: 30000,
        offlineTimeout: 90000,
        maxReconnects: 5,
        reconnectInterval: [1000, 2000, 4000, 8000, 16000]
    }
};

## 相关文档
+ - [通信架构设计](../../02-architecture/communication-design.md)
+ - [数据格式标准](../00-common/data-format-standard.md)
+ - [开发规范](../../04-standards/development-standard.md)
+ - [后端服务设计](./service-design.md) 