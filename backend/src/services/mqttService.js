const mqtt = require('mqtt');
const config = require('../config/config');
const { Device, ProjectSubscription } = require('../models');

class MqttService {
    constructor() {
        this.client = null;
        this.subscriptions = new Set();
    }

    async connect() {
        const { host, port, clientId } = config.mqtt;
        const url = `mqtt://${host}:${port}`;

        this.client = mqtt.connect(url, {
            clientId,
            clean: true,
            connectTimeout: 4000,
            reconnectPeriod: 1000
        });

        this.client.on('connect', () => {
            console.log('Connected to MQTT broker');
            this.loadSubscriptions();
        });

        this.client.on('message', this.handleMessage.bind(this));
    }

    async loadSubscriptions() {
        try {
            const projects = await ProjectSubscription.findAll({
                where: { is_subscribed: true }
            });

            projects.forEach(project => {
                const topic = `${project.project_name}/#`;
                if (!this.subscriptions.has(topic)) {
                    this.client.subscribe(topic);
                    this.subscriptions.add(topic);
                    console.log(`Subscribed to ${topic}`);
                }
            });
        } catch (error) {
            console.error('Error loading subscriptions:', error);
        }
    }

    async handleMessage(topic, message) {
        try {
            const [project_name, module_type, serial_number, status_type] = topic.split('/');
            if (status_type !== 'status') return;

            const data = JSON.parse(message.toString());
            
            const [device, created] = await Device.findOrCreate({
                where: { project_name, module_type, serial_number },
                defaults: {
                    status: data.status,
                    rssi: data.rssi
                }
            });

            if (!created) {
                await device.update({
                    status: data.status,
                    rssi: data.rssi
                });
            }

            console.log(`Device ${created ? 'created' : 'updated'}: ${project_name}/${module_type}/${serial_number}`);
        } catch (error) {
            console.error('Error handling message:', error);
        }
    }

    async subscribe(project_name) {
        const topic = `${project_name}/#`;
        if (!this.subscriptions.has(topic)) {
            this.client.subscribe(topic);
            this.subscriptions.add(topic);
            console.log(`Subscribed to ${topic}`);
        }
    }

    async unsubscribe(project_name) {
        const topic = `${project_name}/#`;
        if (this.subscriptions.has(topic)) {
            this.client.unsubscribe(topic);
            this.subscriptions.delete(topic);
            console.log(`Unsubscribed from ${topic}`);

            // Mark all devices in this project as offline
            await Device.update(
                { status: 'offline' },
                { where: { project_name } }
            );
        }
    }
}

module.exports = new MqttService(); 