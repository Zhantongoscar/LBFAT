const mqtt = require('mqtt');
const logger = require('../utils/logger');

class MQTTService {
    constructor() {
        this.client = null;
        this.subscriptions = [];
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

    publish(topic, message) {
        if (!this.client) {
            throw new Error('MQTT client not connected');
        }
        this.client.publish(topic, JSON.stringify(message));
    }
}

module.exports = new MQTTService(); 