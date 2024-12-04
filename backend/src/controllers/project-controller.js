const Project = require('../models/project');
const mqttService = require('../services/mqtt-service');

// 获取所有项目
exports.getAllProjects = async (req, res) => {
    try {
        const projects = await Project.findAll();
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
};

// 创建新项目
exports.createProject = async (req, res) => {
    try {
        const { projectName } = req.body;
        if (!projectName) {
            return res.status(400).json({
                code: 400,
                message: 'Project name is required'
            });
        }

        await Project.create(projectName);
        res.json({
            code: 200,
            message: 'Project created successfully'
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
};

// 更新项目订阅状态
exports.updateSubscription = async (req, res) => {
    try {
        const { projectName } = req.params;
        const { isSubscribed } = req.body;

        console.log('Updating subscription:', { projectName, isSubscribed }); // 添加日志

        const project = await Project.findByName(projectName);
        if (!project) {
            return res.status(404).json({
                code: 404,
                message: 'Project not found'
            });
        }

        await Project.updateSubscription(projectName, isSubscribed);

        // 更新MQTT订阅
        try {
            if (isSubscribed) {
                await mqttService.subscribeToProject(projectName);
            } else {
                await mqttService.unsubscribeFromProject(projectName);
            }
        } catch (mqttError) {
            console.error('MQTT操作失败，但数据库更新成功:', mqttError);
            // 继续执行，不影响数据库更新
        }

        res.json({
            code: 200,
            message: 'Subscription updated successfully'
        });
    } catch (error) {
        console.error('更新订阅状态失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
};

// 删除项目
exports.deleteProject = async (req, res) => {
    try {
        const { projectName } = req.params;
        
        const project = await Project.findByName(projectName);
        if (!project) {
            return res.status(404).json({
                code: 404,
                message: 'Project not found'
            });
        }

        // 取消MQTT订阅
        try {
            await mqttService.unsubscribeFromProject(projectName);
        } catch (mqttError) {
            console.error('MQTT取消订阅失败:', mqttError);
            // 继续执行，不影响数据库操作
        }

        // 删除项目
        await Project.delete(projectName);

        res.json({
            code: 200,
            message: 'Project deleted successfully'
        });
    } catch (error) {
        console.error('删除项目失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
}; 