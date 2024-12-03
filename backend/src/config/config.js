module.exports = {
    database: {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 3306,
        username: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '13701033228',
        database: process.env.DB_NAME || 'lbfat'
    },
    mqtt: {
        host: process.env.MQTT_HOST || 'localhost',
        port: process.env.MQTT_PORT || 1883,
        clientId: 'lbfat_backend_' + Math.random().toString(16).substring(2, 8)
    },
    server: {
        port: process.env.PORT || 3000
    }
}; 