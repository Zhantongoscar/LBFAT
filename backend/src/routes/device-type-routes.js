const express = require('express');
const router = express.Router();
const deviceTypeController = require('../controllers/device-type-controller');

// 获取所有设备类型
router.get('/', deviceTypeController.getAllTypes);

// 获取单个设备类型
router.get('/:id', deviceTypeController.getType);

// 创建设备类型
router.post('/', deviceTypeController.createType);

// 更新设备类型
router.put('/:id', deviceTypeController.updateType);

// 删除设备类型
router.delete('/:id', deviceTypeController.deleteType);

module.exports = router; 