const express = require('express');
const router = express.Router();
const TestItemController = require('../controllers/test-item-controller');

// 获取指定测试组的所有测试项
router.get('/group/:groupId', TestItemController.getByGroupId);

// 创建新测试项
router.post('/', TestItemController.create);

// 更新测试项
router.put('/:id', TestItemController.update);

// 删除测试项
router.delete('/:id', TestItemController.delete);

// 批量更新测试项顺序
router.put('/sequence/batch', TestItemController.updateSequences);

module.exports = router; 