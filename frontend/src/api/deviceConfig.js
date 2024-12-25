import api from '../utils/api';

export default {
    // 获取所有设备类型
    getAllTypes() {
        return api.get('/deviceTypes').then(response => {
            console.log('设备类型API响应:', response);
            return response;
        }).catch(error => {
            console.error('设备类型API错误:', error);
            throw error;
        });
    },

    // 获取单个设备类型
    getType(id) {
        return api.get(`/deviceTypes/${id}`);
    },

    // 创建设备类型
    createType(data) {
        return api.post('/deviceTypes', data);
    },

    // 更新设备类型
    updateType(id, data) {
        return api.put(`/deviceTypes/${id}`, data);
    },

    // 删除设备类型
    deleteType(id) {
        return api.delete(`/deviceTypes/${id}`);
    }
}; 