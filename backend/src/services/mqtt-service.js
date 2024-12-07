const mqtt = require('mqtt');
const logger = require('../utils/logger');
const Device = require('../models/device');
const WebSocketService = require('./websocket-service');
const db = require('../utils/db');

class MQTTService {
    constructor() {
        if (!MQTTService.instance) {
            this.client = null;
            this.subscriptions = [];
            MQTTService.instance = this;
        }
        return MQTTService.instance;
    }

    // 添加订阅到数据库
    async addSubscriptionToDb(topic) {
        try {
            const sql = 'INSERT INTO mqtt_subscriptions (topic) VALUES (?) ON DUPLICATE KEY UPDATE topic = topic';
            await db.query(sql, [topic]);
            logger.info(`Added subscription to database: ${topic}`);
        } catch (error) {
            logger.error('Error adding subscription to database:', error);
            throw error;
        }
    }

    // 从数据库删除订阅
    async removeSubscriptionFromDb(topic) {
        try {
            const sql = 'DELETE FROM mqtt_subscriptions WHERE topic = ?';
            await db.query(sql, [topic]);
            logger.info(`Removed subscription from database: ${topic}`);
        } catch (error) {
            logger.error('Error removing subscription from database:', error);
            throw error;
        }
    }

    async connect() {
        const host = process.env.MQTT_HOST || 'emqx';
        const port = process.env.MQTT_PORT || 1883;
        const url = `mqtt://${host}:${port}`;

        logger.info(`Connecting to MQTT broker at ${url}`);

        return new Promise((resolve, reject) => {
            this.client = mqtt.connect(url);

            this.client.on('connect', () => {
                logger.info('MQTT connected successfully');
                this.subscribe().catch(logger.error);
                resolve();
            });

            this.client.on('message', async (topic, message) => {
                try {
                    const messageStr = message.toString();
                    let payload;
                    try {
                        payload = JSON.parse(messageStr);
                    } catch (error) {
                        logger.error('解析MQTT消息失败', { topic, message: messageStr, error: error.message });
                        return;
                    }

                    const parts = topic.split('/');
                    if (parts.length < 4) {
                        logger.warn('无效的���题格式', { topic, parts });
                        return;
                    }

                    const projectName = parts[0];
                    const moduleType = parts[1];
                    const serialNumber = parts[2];

                    // 处理状态消息
                    if (topic.endsWith('/status')) {
                        logger.info('处理设备状态消息', {
                            topic,
                            deviceId: `${projectName}/${moduleType}/${serialNumber}`,
                            status: payload.status,
                            rssi: payload.rssi
                        });

                        // 更新数据库中的设备状态
                        try {
                            await Device.upsert({
                                projectName,
                                moduleType,
                                serialNumber,
                                status: payload.status,
                                rssi: payload.rssi
                            });
                            logger.info('设备状态已更新到数据库', {
                                deviceId: `${projectName}/${moduleType}/${serialNumber}`,
                                status: payload.status
                            });
                        } catch (error) {
                            logger.error('更新设备状态失败', {
                                deviceId: `${projectName}/${moduleType}/${serialNumber}`,
                                error: error.message
                            });
                        }

                        // 广播到WebSocket
                        WebSocketService.broadcastDeviceStatus({
                            type: 'device_status',
                            topic,
                            rawMessage: messageStr,
                            device: {
                                projectName,
                                moduleType,
                                serialNumber,
                                status: payload.status,
                                rssi: payload.rssi
                            }
                        });
                    }
                    
                    // 处理响应消息
                    else if (topic.endsWith('/response')) {
                        const channel = parts[3];
                        const deviceId = `${projectName}/${moduleType}/${serialNumber}`;
                        
                        logger.info('处理设备响应消息', {
                            topic,
                            deviceId,
                            channel,
                            command: payload.command,
                            status: payload.status,
                            value: payload.value
                        });

                        const deviceCommand = {
                            type: 'device_command',
                            topic,
                            rawMessage: messageStr,
                            deviceId,
                            channel,
                            commandType: 'response',
                            content: payload,
                            timestamp: new Date().toISOString()
                        };

                        WebSocketService.broadcastDeviceCommand(deviceCommand);
                        logger.info('已广播设备响应消息', { deviceId, channel });
                    }
                } catch (error) {
                    logger.error('处理MQTT消息失败', {
                        topic,
                        message: message.toString(),
                        error: error.message
                    });
                }
            });

            this.client.on('error', (err) => {
                logger.error('MQTT connection error:', err);
                reject(err);
            });

            this.client.on('close', () => {
                logger.warn('MQTT connection closed');
            });
        });
    }

    async subscribe() {
        try {
            // 订阅设备状态和命令响应主题
            const statusTopic = 'lb_test/+/+/status';
            const responseTopic = 'lb_test/+/+/channel/+/response';
            
            this.client.subscribe([statusTopic, responseTopic], { qos: 1 });
            logger.info(`Subscribed to topics: ${statusTopic}, ${responseTopic}`);
            
            // 更新订阅列表
            this.subscriptions = [statusTopic, responseTopic];
            WebSocketService.updateTopicList(this.subscriptions);

            // 添加到数据库
            await this.addSubscriptionToDb(statusTopic);
            await this.addSubscriptionToDb(responseTopic);
        } catch (error) {
            logger.error('Error subscribing to topics:', error);
            throw error;
        }
    }

    async subscribeToProject(projectName) {
        try {
            if (!this.client) {
                logger.error(`MQTT客户端未连接，无法订阅项目 ${projectName}`);
                throw new Error('MQTT client not connected');
            }

            logger.info(`开始订阅项目 ${projectName} 的MQTT主题`);
            const statusTopic = `${projectName}/+/+/status`;
            const responseTopic = `${projectName}/+/+/channel/+/response`;
            
            logger.info(`MQTT客户端状态:`, {
                connected: this.client.connected,
                clientId: this.client.options.clientId
            });

            this.client.subscribe([statusTopic, responseTopic], { qos: 1 }, async (err) => {
                if (err) {
                    logger.error(`订阅失败:`, err);
                } else {
                    logger.info(`订阅成功: ${statusTopic}, ${responseTopic}`);
                    // 更新订阅列表
                    this.subscriptions.push(statusTopic, responseTopic);
                    WebSocketService.updateTopicList(this.subscriptions);
                    
                    // 添加到数据库
                    await this.addSubscriptionToDb(statusTopic);
                    await this.addSubscriptionToDb(responseTopic);
                }
            });
        } catch (error) {
            logger.error(`订阅项目 ${projectName} 失败:`, error);
            logger.error('错误堆栈:', error.stack);
            throw error;
        }
    }

    async unsubscribeFromProject(projectName) {
        try {
            if (!this.client) {
                logger.error(`MQTT客户端未连接，无法取消订阅项目 ${projectName}`);
                throw new Error('MQTT client not connected');
            }

            logger.info(`开始取消订阅项 ${projectName} 的MQTT主题`);
            const statusTopic = `${projectName}/+/+/status`;
            const responseTopic = `${projectName}/+/+/channel/+/response`;
            
            logger.info(`MQTT客户端状态:`, {
                connected: this.client.connected,
                clientId: this.client.options.clientId
            });

            this.client.unsubscribe([statusTopic, responseTopic], async (err) => {
                if (err) {
                    logger.error(`取消订阅失败:`, err);
                } else {
                    logger.info(`取消订阅成功: ${statusTopic}, ${responseTopic}`);
                    // 更新订阅列表
                    this.subscriptions = this.subscriptions.filter(t => t !== statusTopic && t !== responseTopic);
                    WebSocketService.updateTopicList(this.subscriptions);
                    
                    // 从数据库删除
                    await this.removeSubscriptionFromDb(statusTopic);
                    await this.removeSubscriptionFromDb(responseTopic);
                }
            });
        } catch (error) {
            logger.error(`取消订阅项目 ${projectName} 失败:`, error);
            logger.error('错误堆栈:', error.stack);
            throw error;
        }
    }

    // 发送命令到设备
    sendCommand(projectName, moduleType, serialNumber, channel, command) {
        if (!this.client) {
            throw new Error('MQTT client not connected');
        }
        const topic = `${projectName}/${moduleType}/${serialNumber}/${channel}/command`;
        const message = { command };
        this.client.publish(topic, JSON.stringify(message));
        logger.info(`Sent command to topic ${topic}:`, message);
    }
}

// 创建单例实例
const instance = new MQTTService();

module.exports = instance; 