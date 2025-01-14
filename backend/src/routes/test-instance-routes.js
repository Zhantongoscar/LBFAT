const express = require('express');
const router = express.Router();
const testInstanceController = require('../controllers/test-instance-controller');

// 获取测试实例列表
router.get('/', testInstanceController.getTestInstances);

// 创建测试实例
router.post('/', testInstanceController.createTestInstance);

// 获取测试实例的测试项
router.get('/:instanceId/items', testInstanceController.getTestInstanceItems);

// 获取单个测试实例详情
router.get('/:id', testInstanceController.getTestInstance);

// 开始测试
router.post('/:id/start', testInstanceController.startTest);

// 完成测试
router.post('/:id/complete', testInstanceController.completeTest);

// 更新测试项状态
router.put('/:id/items/:itemId', testInstanceController.updateTestItemStatus);

// 删除测试实例
router.delete('/:id', testInstanceController.deleteTestInstance);

// 创建测试项实例
router.post('/:id/items/create', testInstanceController.createTestItemInstances);

// 执行测试项
router.post('/:instanceId/items/:itemId/execute', testInstanceController.executeTestItem);

module.exports = router; 