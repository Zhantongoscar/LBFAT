import axios from 'axios';
import { ElMessage } from 'element-plus';

// 创建axios实例
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000',
    timeout: 30000,
    headers: {
        'Content-Type': 'application/json'
    }
});

// 请求拦截器
api.interceptors.request.use(
    config => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    error => {
        return Promise.reject(error);
    }
);

// 响应拦截器
api.interceptors.response.use(
    response => response,
    error => {
        let errorMessage = '请求失败';
        if (error.code === 'ECONNABORTED') {
            errorMessage = '请求超时，请检查网络连接';
        } else if (error.response) {
            errorMessage = error.response.data?.message || `服务器错误 (${error.response.status})`;
        } else if (!error.response) {
            errorMessage = '无法连接到服务器，请检查网络';
        }
        
        ElMessage.error(errorMessage);
        return Promise.reject(error);
    }
);

export default api; 