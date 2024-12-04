const db = require('../utils/db');

class Project {
    // 获取所有项目
    static async findAll() {
        const sql = 'SELECT * FROM project_subscriptions ORDER BY created_at DESC';
        return await db.query(sql);
    }

    // 获取单个项目
    static async findByName(projectName) {
        const sql = 'SELECT * FROM project_subscriptions WHERE project_name = ?';
        const results = await db.query(sql, [projectName]);
        return results[0];
    }

    // 更新项目订阅状态
    static async updateSubscription(projectName, isSubscribed) {
        const sql = 'UPDATE project_subscriptions SET is_subscribed = ? WHERE project_name = ?';
        return await db.query(sql, [isSubscribed, projectName]);
    }

    // 创建新项目
    static async create(projectName) {
        const sql = 'INSERT INTO project_subscriptions (project_name) VALUES (?)';
        return await db.query(sql, [projectName]);
    }

    // 删除项目
    static async delete(projectName) {
        const sql = 'DELETE FROM project_subscriptions WHERE project_name = ?';
        return await db.query(sql, [projectName]);
    }
}

module.exports = Project; 