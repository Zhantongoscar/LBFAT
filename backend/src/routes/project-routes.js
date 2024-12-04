const express = require('express');
const router = express.Router();
const projectController = require('../controllers/project-controller');

// 获取所有项目
router.get('/', async (req, res) => {
    try {
        const projects = await projectController.getAllProjects(req, res);
        res.json({
            code: 200,
            message: 'success',
            data: projects
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
});

// 创建新项目
router.post('/', projectController.createProject);

// 更新项目订阅状态
router.put('/:projectName/subscription', projectController.updateSubscription);

module.exports = router; 