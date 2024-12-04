const express = require('express');
const router = express.Router();
const projectController = require('../controllers/project-controller');

// 获取所有项目
router.get('/', projectController.getAllProjects);

// 创建新项目
router.post('/', projectController.createProject);

// 更新项目订阅状态
router.put('/:projectName/subscription', projectController.updateSubscription);

// 删除项目
router.delete('/:projectName', projectController.deleteProject);

module.exports = router; 