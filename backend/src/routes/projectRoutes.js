const express = require('express');
const router = express.Router();
const projectController = require('../controllers/projectController');

// 获取所有项目列表
router.get('/', projectController.getAllProjects);

// 添加新项目
router.post('/', projectController.addProject);

// 更新项目订阅状态
router.put('/:project_name/subscription', projectController.updateSubscription);

// 删除项目
router.delete('/:project_name', projectController.deleteProject);

module.exports = router; 