import api from '../utils/api';

export default {
    // 获取所有项目
    getAllProjects() {
        return api.get('/projects');
    },

    // 创建新项目
    createProject(projectName) {
        return api.post('/projects', { projectName });
    },

    // 更新项目订阅状态
    updateSubscription(projectName, isSubscribed) {
        return api.put(`/projects/${projectName}/subscription`, { isSubscribed });
    },

    // 删除项目
    deleteProject(projectName) {
        return api.delete(`/projects/${projectName}`);
    }
}; 