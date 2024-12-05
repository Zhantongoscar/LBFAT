import axios from 'axios';
import { ElMessage } from 'element-plus';

// 创建axios实例
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    timeout: 10000,
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
            params: config.params
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
            data: response.data
        });

        // 直接返回响应数据，让调用方处理
        return response;
    },
    error => {
        console.error('响应错误:', {
            url: error.config?.url,
            status: error.response?.status,
            data: error.response?.data,
            message: error.message
        });

        // 构造错误信息
        const errorMessage = error.response?.data?.message || error.message || '网络错误';
        ElMessage.error(errorMessage);
        
        return Promise.reject(error);
    }
);

export default api; 