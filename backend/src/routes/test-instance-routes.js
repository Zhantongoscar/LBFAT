const express = require('express');
const router = express.Router();
const testInstanceController = require('../controllers/test-instance-controller');

// 创建测试实例
router.post('/', testInstanceController.createTestInstance);

// 开始测试
router.post('/:instanceId/start', testInstanceController.startTest);

// 更新测试项状态
router.put('/:instanceId/items/:itemId', testInstanceController.updateTestItemStatus);

// 完成测试
router.post('/:instanceId/complete', testInstanceController.completeTest);

// 获取测试实例详情
router.get('/:instanceId', testInstanceController.getTestInstance);

// 获取测试实例列表
router.get('/', testInstanceController.getTestInstances);

module.exports = router; 