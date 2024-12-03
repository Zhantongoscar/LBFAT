module.exports = {
    host: process.env.MQTT_HOST || 'localhost',
    port: process.env.MQTT_PORT || 11883,
    clientId: `backend_${process.pid}_${Date.now()}`,
    clean: true,
    connectTimeout: 4000,
    reconnectPeriod: 1000,
    qos: 1
}; 