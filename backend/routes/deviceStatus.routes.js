const express = require('express');
const router = express.Router();
const deviceStatusController = require('../controllers/deviceStatus.controller');

// 获取所有设备列表
router.get('/', deviceStatusController.getAllDevices);

// 获取设备当前状态
router.get('/:deviceId/status', deviceStatusController.getDeviceStatus);

// 获取设备状态历史记录
router.get('/:deviceId/status/history', deviceStatusController.getDeviceStatusHistory);

// 获取设备心跳历史
router.get('/:deviceId/heartbeats', deviceStatusController.getDeviceHeartbeats);

// 获取设备统计信息
router.get('/:deviceId/stats', deviceStatusController.getDeviceStats);

module.exports = router; 