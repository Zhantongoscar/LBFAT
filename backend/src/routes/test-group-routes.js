const express = require('express')
const router = express.Router()
const testGroupController = require('../controllers/test-group-controller')

// 创建测试组
router.post('/', testGroupController.createTestGroup)

// 更新测试组
router.put('/:id', testGroupController.updateTestGroup)

// 删除测试组
router.delete('/:id', testGroupController.deleteTestGroup)

module.exports = router 