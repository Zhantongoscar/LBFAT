const mqtt = require('mqtt');
const logger = require('../utils/logger');
const Device = require('../models/device');
const WebSocketService = require('./websocket-service');

class MQTTService {
    constructor() {
        if (!MQTTService.instance) {
            this.client = null;
            this.subscriptions = [];
            MQTTService.instance = this;
        }
        return MQTTService.instance;
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
                    const payload = JSON.parse(message.toString());
                    logger.info(`Received message on topic ${topic}:`, payload);

                    // 解析主题格式：projectName/moduleType/serialNumber/status
                    const [projectName, moduleType, serialNumber] = topic.split('/');
                    
                    // 更新设备状态
                    await Device.upsert({
                        projectName,
                        moduleType,
                        serialNumber,
                        status: payload.status,
                        rssi: payload.rssi
                    });

                    // 通过WebSocket广播设备状态更新
                    WebSocketService.broadcast({
                        type: 'device_status',
                        device: {
                            project_name: projectName,
                            module_type: moduleType,
                            serial_number: serialNumber,
                            status: payload.status,
                            rssi: payload.rssi
                        }
                    });
                } catch (error) {
                    logger.error('Error processing MQTT message:', error);
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
            // 订阅所有设备状态主题
            const topic = 'lb_test/+/+/status';
            this.client.subscribe(topic, { qos: 1 });
            logger.info(`Subscribed to topic: ${topic}`);
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
            const topic = `${projectName}/+/+/status`;
            
            logger.info(`MQTT客户端状态:`, {
                connected: this.client.connected,
                clientId: this.client.options.clientId
            });

            this.client.subscribe(topic, { qos: 1 }, (err) => {
                if (err) {
                    logger.error(`订阅失败:`, err);
                } else {
                    logger.info(`订阅成功: ${topic}`);
                }
            });

            this.subscriptions.push(topic);
            logger.info(`当前订阅列表:`, this.subscriptions);
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

            logger.info(`开始取消订阅项目 ${projectName} 的MQTT主题`);
            const topic = `${projectName}/+/+/status`;
            
            logger.info(`MQTT客户端状态:`, {
                connected: this.client.connected,
                clientId: this.client.options.clientId
            });

            this.client.unsubscribe(topic, (err) => {
                if (err) {
                    logger.error(`取消订阅失败:`, err);
                } else {
                    logger.info(`取消订阅成功: ${topic}`);
                }
            });

            this.subscriptions = this.subscriptions.filter(t => t !== topic);
            logger.info(`更新后的订阅列表:`, this.subscriptions);
        } catch (error) {
            logger.error(`取消订阅项目 ${projectName} 失败:`, error);
            logger.error('错误堆栈:', error.stack);
            throw error;
        }
    }

    publish(topic, message) {
        if (!this.client) {
            throw new Error('MQTT client not connected');
        }
        this.client.publish(topic, JSON.stringify(message));
    }
}

// 创建单例实例
const instance = new MQTTService();

module.exports = instance; 