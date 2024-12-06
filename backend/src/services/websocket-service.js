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

            // 发送当前topic列表
            this.sendTopicList(ws);

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

    broadcastDeviceStatus(device) {
        this.broadcast({
            type: 'device_status',
            device
        });
    }

    broadcastDeviceCommand(deviceId, channel, commandType, content) {
        this.broadcast({
            type: 'device_command',
            deviceId,
            channel,
            commandType,
            content
        });
    }

    updateTopicList(topics) {
        this.emit('topicsUpdated', topics);
    }
}

// 创建单例实例
const instance = new WebSocketService();

module.exports = instance; 