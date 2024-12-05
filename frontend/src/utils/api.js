import axios from 'axios';
import { ElMessage } from 'element-plus';

// 创建axios实例
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    timeout: 30000,
    headers: {
        'Content-Type': 'application/json'
    }
});

// 请求拦截器
api.interceptors.request.use(
    config => {
        console.log('发送请求:', {
            url: config.url,
            method: config.method,
            data: config.data,
            params: config.params,
            baseURL: config.baseURL
        });
        return config;
    },
    error => {
        console.error('请求错误:', error);
        return Promise.reject(error);
    }
);

// 响应拦截器
api.interceptors.response.use(
    response => {
        console.log('收到响应:', {
            url: response.config.url,
            status: response.status,
            data: response.data,
            baseURL: response.config.baseURL
        });

        return response;
    },
    error => {
        console.error('响应错误:', {
            url: error.config?.url,
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
            baseURL: error.config?.baseURL,
            code: error.code,
            stack: error.stack
        });

        // 构造详细的错误信息
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