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
// 获取指定真值表下的所有测试组
router.get('/:truth_table_id/groups', testGroupController.getTestGroups);

// 创建测试组
router.post('/:truth_table_id/groups', testGroupController.createTestGroup);

// 更新测试组
router.put('/:truth_table_id/groups/:id', testGroupController.updateTestGroup);

// 删除测试组
router.delete('/:truth_table_id/groups/:id', testGroupController.deleteTestGroup);

module.exports = router; 