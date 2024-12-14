const express = require('express')
const router = express.Router()
const testGroupController = require('../controllers/test-group-controller')

// 创建测试组
router.post('/test-groups', testGroupController.createTestGroup)

// 更新测试组
router.put('/test-groups/:id', testGroupController.updateTestGroup)

// 删除测试组
router.delete('/test-groups/:id', testGroupController.deleteTestGroup)

module.exports = router 