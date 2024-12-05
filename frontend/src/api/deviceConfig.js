import api from '../utils/api';

export default {
    // 获取所有设备类型
    getAllTypes() {
        return api.get('/api/deviceTypes');
    },

    // 获取单个设备类型
    getType(id) {
        return api.get(`/api/deviceTypes/${id}`);
    },

    // 创建设备类型
    createType(data) {
        return api.post('/api/deviceTypes', data);
    },

    // 更新设备类型
    updateType(id, data) {
        return api.put(`/api/deviceTypes/${id}`, data);
    },

    // 删除设备类型
    deleteType(id) {
        return api.delete(`/api/deviceTypes/${id}`);
    }
}; 