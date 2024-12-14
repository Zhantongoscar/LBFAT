const express = require('express');
const router = express.Router();
const truthTableController = require('../controllers/truth-table-controller');
// const auth = require('../middleware/auth');  // 暂时注释掉认证中间件

// 获取所有真值表
router.get('/', truthTableController.getAllTables);

// 获取单个真值表
router.get('/:id', truthTableController.getTable);

// 创建真值表
router.post('/', truthTableController.createTable);

// 更新真值表
router.put('/:id', truthTableController.updateTable);

// 删除真值表
router.delete('/:id', truthTableController.deleteTable);

module.exports = router; 