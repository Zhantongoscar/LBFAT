const express = require('express')
const router = express.Router()
const controller = require('../controllers/test-instance-controller')

// 获取测试实例列表
router.get('/', controller.getTestInstances)

// 创建测试实例
router.post('/', controller.createTestInstance)

// 删除测试实例
router.delete('/:id', controller.deleteTestInstance)

// 开始测试
router.post('/:id/start', controller.startTest)

// 完成测试
router.post('/:id/complete', controller.completeTest)

// 获取测试项列表
router.get('/:id/items', controller.getTestItems)

// 创建测试项
router.post('/:id/items/create', controller.createInstanceItems)

// 执行测试项
router.post('/:id/items/:itemId/execute', controller.executeTestItem)

// 跳过测试项
router.post('/:id/items/:itemId/skip', controller.skipTestItem)

// 重置测试组
router.post('/:instanceId/groups/:groupId/reset', controller.resetGroupItems)

module.exports = router 