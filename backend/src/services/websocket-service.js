const WebSocket = require('ws');
const logger = require('../utils/logger');
const EventEmitter = require('events');

class WebSocketService extends EventEmitter {
    constructor() {
        super();
        this.wss = null;
        this.clients = new Set();
        this.topicList = [];

        // 监听topic列表更新事件
        this.on('topicsUpdated', (topics) => {
            this.topicList = topics;
            this.broadcast({
                type: 'topic_list',
                topics: this.topicList
            });
        });
    }

    initialize(server) {
        this.wss = new WebSocket.Server({ server });

        this.wss.on('connection', (ws) => {
            logger.info('New WebSocket client connected');
            this.clients.add(ws);

            // 主动从MQTT服务获取主题列表
            const mqttService = require('./mqtt-service');
            if (mqttService.subscriptions && mqttService.subscriptions.length > 0) {
                this.topicList = mqttService.subscriptions;
            }

            // 发送当前topic列表
            this.sendTopicList(ws);

            // 处理来自客户端的消息
            ws.on('message', async (message) => {
                try {
                    const data = JSON.parse(message);
                    logger.info('收到WebSocket消息:', data);

                    if (data.type === 'mqtt_publish') {
                        const mqttService = require('./mqtt-service');
                        logger.info('准备发布MQTT消息:', {
                            topic: data.topic,
                            payload: data.payload
                        });
                        
                        await mqttService.publish(data.topic, data.payload);
                    }
                } catch (error) {
                    logger.error('处理WebSocket消息失败:', error);
                }
            });

            ws.on('close', () => {
                logger.info('WebSocket client disconnected');
                this.clients.delete(ws);
            });

            ws.on('error', (error) => {
                logger.error('WebSocket error:', error);
            });
        });

        logger.info('WebSocket服务已初始化');
    }

    sendTopicList(ws) {
        try {
            const message = {
                type: 'topic_list',
                topics: this.topicList
            };
            ws.send(JSON.stringify(message));
        } catch (error) {
            logger.error('发送Topic列表失败:', error);
        }
    }

    broadcast(message) {
        const messageStr = JSON.stringify(message);
        this.clients.forEach((client) => {
            try {
                if (client.readyState === WebSocket.OPEN) {
                    client.send(messageStr);
                }
            } catch (error) {
                logger.error('广播消息失败:', error);
            }
        });
    }

    broadcastDeviceStatus(data) {
        logger.info('广播设备状态消息:', {
            type: data.type,
            deviceId: `${data.device.projectName}/${data.device.moduleType}/${data.device.serialNumber}`,
            status: data.device.status,
            timestamp: new Date().toISOString()
        });
        this.broadcast(data);
    }

    broadcastDeviceCommand(data) {
        logger.info('广播设备命令消息:', {
            type: data.type,
            deviceId: data.deviceId,
            channel: data.channel,
            commandType: data.commandType,
            timestamp: new Date().toISOString()
        });
        this.broadcast(data);
    }

    updateTopicList(topics) {
        this.emit('topicsUpdated', topics);
    }
}

// 创建单例实例
const instance = new WebSocketService();

module.exports = instance; 