const express = require('express')
const router = express.Router()
const testGroupController = require('../controllers/test-group-controller')

// 获取指定真值表下的所有测试组
router.get('/truth-table/:truth_table_id/groups', testGroupController.getTestGroups)

// 创建测试组
router.post('/groups', testGroupController.createTestGroup)

// 更新测试组
router.put('/groups/:id', testGroupController.updateTestGroup)

// 删除测试组
router.delete('/groups/:id', testGroupController.deleteTestGroup)

module.exports = router 