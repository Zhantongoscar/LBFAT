import axios from 'axios';

const baseURL = import.meta.env.VITE_API_URL;

export default {
    // 获取所有项目
    getAllProjects() {
        return axios.get(`${baseURL}/api/projects`);
    },

    // 创建新项目
    createProject(projectName) {
        return axios.post(`${baseURL}/api/projects`, { projectName });
    },

    // 更新项目订阅状态
    updateSubscription(projectName, isSubscribed) {
        return axios.put(`${baseURL}/api/projects/${projectName}/subscription`, { isSubscribed });
    }
}; 