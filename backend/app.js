const express = require('express');
const cors = require('cors');
const deviceStatusRoutes = require('./routes/deviceStatus.routes');
const mqttClient = require('./utils/mqtt');
const logger = require('./utils/logger');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// 根路径返回API信息
app.get('/', (req, res) => {
  res.json({
    name: 'LBFAT Backend API',
    version: '1.0.0',
    endpoints: {
      devices: '/api/devices',
      health: '/health'
    }
  });
});

// API路由
app.use('/api/devices', deviceStatusRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// 错误处理
app.use((err, req, res, next) => {
  logger.error('Error:', err);
  res.status(500).json({ error: err.message });
});

app.listen(port, () => {
  logger.info(`Server running on port ${port}`);
});

// 连接MQTT
mqttClient.connect();

module.exports = app; 