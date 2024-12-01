const mqtt = require('mqtt');
const logger = require('./logger');
const deviceMonitorService = require('../services/deviceMonitor.service');

class MQTTClient {
  constructor() {
    this.client = null;
    this.options = {
      host: process.env.MQTT_HOST || 'emqx',
      port: process.env.MQTT_PORT || 1883,
      clientId: 'lbfat_backend_' + Math.random().toString(16).substr(2, 8)
    };
  }

  connect() {
    this.client = mqtt.connect(`mqtt://${this.options.host}:${this.options.port}`, {
      clientId: this.options.clientId
    });

    this.client.on('connect', () => {
      logger.info('MQTT connected successfully');
      this.subscribe();
    });

    this.client.on('error', (err) => {
      logger.error('MQTT connection error:', err);
    });

    this.client.on('message', async (topic, message) => {
      try {
        const payload = JSON.parse(message.toString());
        logger.info(`Received message on ${topic}:`, payload);
        await this.handleMessage(topic, payload);
      } catch (err) {
        logger.error('Error handling MQTT message:', err);
      }
    });
  }

  subscribe() {
    const topics = [
      'myproject/+/+/status',  // 设备状态主题
      'myproject/+/+/heartbeat'  // 设备心跳主题
    ];

    topics.forEach(topic => {
      this.client.subscribe(topic, (err) => {
        if (err) {
          logger.error(`Failed to subscribe to ${topic}:`, err);
        } else {
          logger.info(`Subscribed to ${topic}`);
        }
      });
    });
  }

  async handleMessage(topic, payload) {
    // 解析主题
    const [project, deviceType, deviceId, messageType] = topic.split('/');
    
    if (messageType === 'status') {
      // 处理状态消息
      await deviceMonitorService.updateDeviceStatus(deviceType, deviceId, payload);
    } else if (messageType === 'heartbeat') {
      // 处理心跳消息
      await deviceMonitorService.updateDeviceHeartbeat(deviceType, deviceId, payload);
    }
  }
}

module.exports = new MQTTClient(); 