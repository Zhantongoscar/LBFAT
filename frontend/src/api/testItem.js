import api from '../utils/api';

export default {
  // 获取指定测试组的所有测试项
  getByGroupId(groupId) {
    console.log('调用API获取测试项，组ID:', groupId);
    return api.get(`/test-items/group/${groupId}`)
      .then(response => {
        console.log('API响应数据:', response.data);
        return response.data;
      })
      .catch(error => {
        console.error('API调用失败:', error);
        throw error;
      });
  },

  // 创建新测试项
  create(data) {
    return api.post('/test-items', data);
  },

  // 更新测试项
  update(id, data) {
    return api.put(`/test-items/${id}`, data);
  },

  // 删除测试项
  delete(id) {
    return api.delete(`/test-items/${id}`);
  },

  // 批量更新测试项顺序
  updateSequences(items) {
    return api.put('/test-items/sequence/batch', { items });
  }
}; 