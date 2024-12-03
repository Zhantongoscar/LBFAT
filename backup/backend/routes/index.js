const express = require('express');
const router = express.Router();
const deviceRoutes = require('./device.routes');

router.get('/test', (req, res) => {
  res.json({
    message: 'API is working',
    timestamp: new Date().toISOString()
  });
});

// 设备相关路由
router.use('/devices', deviceRoutes);

module.exports = router;
