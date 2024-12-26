const express = require('express');
const router = express.Router();
const truthTableController = require('../controllers/truth-table-controller');
const testGroupController = require('../controllers/test-group-controller');

// 获取真值表列表
router.get('/', truthTableController.getTruthTables);

// 获取可用的图纸列表
router.get('/available-drawings', truthTableController.getAvailableDrawings);

// 获取真值表详情
router.get('/:id', truthTableController.getTruthTable);

// 创建真值表
router.post('/', truthTableController.createTruthTable);

// 更新真值表
router.put('/:id', truthTableController.updateTruthTable);

// 删除真值表
router.delete('/:id', truthTableController.deleteTruthTable);

// 测试组相关路由
router.get('/:id/groups', testGroupController.getTestGroups);
router.post('/:id/groups', testGroupController.createTestGroup);
router.put('/:id/groups/:group_id', testGroupController.updateTestGroup);
router.delete('/:id/groups/:group_id', testGroupController.deleteTestGroup);

module.exports = router; 