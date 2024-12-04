const Project = require('../models/project');
const mqttService = require('../services/mqtt-service');

class ProjectController {
    // 获取所有项目
    static async getAllProjects(req, res) {
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
    }

    // 创建新项目
    static async createProject(req, res) {
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
    }

    // 更新项目订阅状态
    static async updateSubscription(req, res) {
        try {
            const { projectName } = req.params;
            const { isSubscribed } = req.body;

            const project = await Project.findByName(projectName);
            if (!project) {
                return res.status(404).json({
                    code: 404,
                    message: 'Project not found'
                });
            }

            await Project.updateSubscription(projectName, isSubscribed);

            // 更新MQTT订阅
            if (isSubscribed) {
                await mqttService.subscribeToProject(projectName);
            } else {
                await mqttService.unsubscribeFromProject(projectName);
            }

            res.json({
                code: 200,
                message: 'Subscription updated successfully'
            });
        } catch (error) {
            res.status(500).json({
                code: 500,
                message: error.message
            });
        }
    }
}

module.exports = ProjectController; 