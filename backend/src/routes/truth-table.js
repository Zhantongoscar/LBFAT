const express = require('express');
const router = express.Router();
const truthTableController = require('../controllers/truth-table-controller');

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

module.exports = router; 