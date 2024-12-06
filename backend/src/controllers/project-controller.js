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

        console.log('开始处理订阅更新:', { projectName, isSubscribed });
        console.log('MQTT服务实例:', {
            hasClient: !!mqttService.client,
            hasSubscribeMethod: !!mqttService.subscribeToProject,
            hasUnsubscribeMethod: !!mqttService.unsubscribeFromProject,
            subscriptions: mqttService.subscriptions
        });

        const project = await Project.findByName(projectName);
        if (!project) {
            console.log('项目不存在:', projectName);
            return res.status(404).json({
                code: 404,
                message: 'Project not found'
            });
        }

        console.log('更新数据库订阅状态...');
        await Project.updateSubscription(projectName, isSubscribed);
        console.log('数据库更新成功');

        // 更新MQTT订阅
        try {
            console.log('开始处理MQTT订阅...');
            if (isSubscribed) {
                console.log(`准备订阅项目 ${projectName} 的MQTT主题`);
                await mqttService.subscribeToProject(projectName);
                console.log(`成功订阅项目 ${projectName} 的MQTT主题`);
            } else {
                console.log(`准备取消订阅项目 ${projectName} 的MQTT主题`);
                await mqttService.unsubscribeFromProject(projectName);
                console.log(`成功取消订阅项目 ${projectName} 的MQTT主题`);
            }
        } catch (mqttError) {
            console.error('MQTT操作失败，详细错误:', mqttError);
            console.error('MQTT错误堆栈:', mqttError.stack);
            console.error('MQTT服务状态:', {
                hasClient: !!mqttService.client,
                methods: Object.keys(mqttService),
                subscriptions: mqttService.subscriptions
            });
        }

        console.log('订阅更新处理完成');
        res.json({
            code: 200,
            message: 'Subscription updated successfully'
        });
    } catch (error) {
        console.error('更新订阅状态失败:', error);
        console.error('错误堆栈:', error.stack);
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
        console.error('删除项目���败:', error);
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
}; 