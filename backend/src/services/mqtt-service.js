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

    async connect(retries = 5, delay = 5000) {
        const host = process.env.MQTT_HOST || 'lbfat_emqx';
        const port = process.env.MQTT_PORT || 1883;
        const url = `mqtt://${host}:${port}`;

        logger.info(`Connecting to MQTT broker at ${url}`);

        for (let i = 0; i < retries; i++) {
            try {
                await new Promise((resolve, reject) => {
                    this.client = mqtt.connect(url, {
                        clientId: `backend_${process.pid}_${Date.now()}`,
                        clean: true,
                        connectTimeout: 4000,
                        reconnectPeriod: 1000
                    });

                    this.client.on('connect', async () => {
                        logger.info('MQTT connected successfully');
                        try {
                            await this.subscribe();
                            // 连接成功后立即发送主题列表
                            WebSocketService.updateTopicList(this.subscriptions);
                            resolve();
                        } catch (error) {
                            logger.error('MQTT初始订阅失败:', error);
                            reject(error);
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

                // 如果成功连接，直接返回
                return;
            } catch (error) {
                logger.error(`MQTT连接尝试 ${i + 1}/${retries} 失败:`, error);
                if (i < retries - 1) {
                    logger.info(`等待 ${delay/1000} 秒后重试...`);
                    await new Promise(resolve => setTimeout(resolve, delay));
                } else {
                    throw error;
                }
            }
        }
    }

    async subscribe() {
        try {
            // 订阅设备状态和命令响应主题
            const statusTopic = 'lb_test/+/+/status';
            const responseTopic = 'lb_test/+/+/+/response';
            
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
            const responseTopic = `${projectName}/+/+/+/response`;
            
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
            const responseTopic = `${projectName}/+/+/+/response`;
            
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
                    this.subscriptions = this.subscriptions.filter(
                        topic => topic !== statusTopic && topic !== responseTopic
                    );
                    WebSocketService.updateTopicList(this.subscriptions);
                    
                    // 从数据库删除
                    await this.removeSubscriptionFromDb(statusTopic);
                    await this.removeSubscriptionFromDb(responseTopic);
                }
            });
        } catch (error) {
            logger.error(`取消订阅项目 ${projectName} 失败:`, error);
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

    // 发布MQTT消息
    async publish(topic, payload) {
        if (!this.client) {
            logger.error('MQTT客户端未连接，无法发布息');
            throw new Error('MQTT client not connected');
        }

        logger.info('准备发布MQTT消息:', {
            topic,
            payload,
            clientConnected: this.client.connected,
            clientId: this.client.options.clientId
        });

        return new Promise((resolve, reject) => {
            this.client.publish(topic, JSON.stringify(payload), { qos: 1 }, (error) => {
                if (error) {
                    logger.error('发布MQTT消息失败:', {
                        error,
                        topic,
                        payload
                    });
                    reject(error);
                } else {
                    logger.info('MQTT消息发布成功:', {
                        topic,
                        payload
                    });
                    resolve();
                }
            });
        });
    }
}

// 创建单例实例
const instance = new MQTTService();

module.exports = instance; 