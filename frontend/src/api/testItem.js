import api from '../utils/api';

export default {
  // 获取指定测试组的所有测试项
  getByGroupId(groupId) {
    console.log('调用API获取测试项，组ID:', groupId);
    return api.get(`/test-items/group/${groupId}`)
      .then(response => {
        console.log('API原始响应:', response);
        if (response.data && response.data.code === 200) {
          const items = response.data.data;
          console.log('处理前的测试项数据:', items);
          // 确保数值字段为数字类型，处理null值
          const processedItems = items.map(item => ({
            ...item,
            // 如果是null，使用空字符串，这样在界面上就不会显示NaN
            device_id: item.device_id === null ? '' : Number(item.device_id),
            point_index: item.point_index === null ? '' : Number(item.point_index),
            input_values: item.input_values === null ? 0 : Number(item.input_values),
            expected_values: item.expected_values === null ? 0 : Number(item.expected_values),
            timeout: item.timeout === null ? 5000 : Number(item.timeout)
          }));
          console.log('处理后的测试项数据:', processedItems);
          return processedItems;
        }
        throw new Error('获取测试项失败');
      })
      .catch(error => {
        console.error('API调用失败:', error);
        throw error;
      });
  },

  // 获取单个测试项的详细数据
  getById(id) {
    return api.get(`/test-items/${id}`)
      .then(response => {
        console.log('API响应数据:', response);
        if (response.data && response.data.code === 200) {
          return response.data.data;
        }
        throw new Error('获取测试项失败');
      })
      .catch(error => {
        console.error('API调用失败:', error);
        throw error;
      });
  },

  // 创建新测试项
  create(data) {
    return api.post('/test-items', data)
      .then(response => {
        console.log('API响应数据:', response);
        if (response.data && (response.data.code === 200 || response.data.code === 201)) {
          return response.data;
        }
        throw new Error(response.data?.message || '创建测试项失败');
      })
      .catch(error => {
        console.error('API调用失败:', error);
        if (error.response?.data?.message) {
          throw new Error(error.response.data.message);
        }
        throw error;
      });
  },

  // 更新测试项
  update(id, data) {
    return api.put(`/test-items/${id}`, data)
      .then(response => {
        console.log('API响应数据:', response);
        if (response.data && response.data.code === 200) {
          return response.data.data;
        }
        throw new Error('更新测试项失败');
      })
      .catch(error => {
        console.error('API调用失败:', error);
        throw error;
      });
  },

  // 删除测试项
  delete(id) {
    return api.delete(`/test-items/${id}`)
      .then(response => {
        console.log('API响应数据:', response);
        if (response.data && response.data.code === 200) {
          return response.data.data;
        }
        throw new Error('删除测试项失败');
      })
      .catch(error => {
        console.error('API调用失败:', error);
        throw error;
      });
  },

  // 批量更新测试项顺序
  updateSequences(items) {
    return api.put('/test-items/sequence/batch', { items });
  }
}; 