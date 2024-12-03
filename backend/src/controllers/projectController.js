const { ProjectSubscription } = require('../models');
const mqttService = require('../services/mqttService');

class ProjectController {
    // 获取所有项目列表
    async getAllProjects(req, res) {
        try {
            const projects = await ProjectSubscription.findAll({
                order: [['created_at', 'DESC']]
            });
            res.json(projects);
        } catch (error) {
            console.error('Error getting projects:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    // 更新项目订阅状态
    async updateSubscription(req, res) {
        const { project_name } = req.params;
        const { is_subscribed } = req.body;

        try {
            const [project, created] = await ProjectSubscription.findOrCreate({
                where: { project_name },
                defaults: { is_subscribed }
            });

            if (!created) {
                await project.update({ is_subscribed });
            }

            // 更新MQTT订阅
            if (is_subscribed) {
                await mqttService.subscribe(project_name);
            } else {
                await mqttService.unsubscribe(project_name);
            }

            res.json(project);
        } catch (error) {
            console.error('Error updating subscription:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    // 手动添加新项目
    async addProject(req, res) {
        const { project_name, is_subscribed = true } = req.body;

        try {
            const [project, created] = await ProjectSubscription.findOrCreate({
                where: { project_name },
                defaults: { is_subscribed }
            });

            if (!created) {
                return res.status(400).json({ error: 'Project already exists' });
            }

            // 如果创建时就订阅
            if (is_subscribed) {
                await mqttService.subscribe(project_name);
            }

            res.status(201).json(project);
        } catch (error) {
            console.error('Error adding project:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    // 删除项目
    async deleteProject(req, res) {
        const { project_name } = req.params;

        try {
            const project = await ProjectSubscription.findOne({
                where: { project_name }
            });

            if (!project) {
                return res.status(404).json({ error: 'Project not found' });
            }

            // 如果项目当前是订阅状态，先取消订阅
            if (project.is_subscribed) {
                await mqttService.unsubscribe(project_name);
            }

            await project.destroy();
            res.json({ message: 'Project deleted successfully' });
        } catch (error) {
            console.error('Error deleting project:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }
}

module.exports = new ProjectController(); 