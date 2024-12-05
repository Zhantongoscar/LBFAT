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

        const data = response.data;
        if (data.code !== 200) {
            ElMessage.error(data.message || '操作失败');
            return Promise.reject(new Error(data.message || '操作失败'));
        }
        return data;
    },
    error => {
        console.error('响应错误:', {
            url: error.config?.url,
            status: error.response?.status,
            data: error.response?.data,
            message: error.message
        });
        const message = error.response?.data?.message || '网络错误';
        ElMessage.error(message);
        return Promise.reject(error);
    }
);

export default api; 