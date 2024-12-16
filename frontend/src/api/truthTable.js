import api from '@/utils/api'

// 获取可用的图纸和版本列表
export function getAvailableDrawings() {
    return api.get('/api/truth-tables/available-drawings')
}

// 获取真值表列表
export function getTruthTables() {
    console.log('调用 getTruthTables API');
    return api.get('/api/truth-tables').then(response => {
        console.log('getTruthTables API 响应:', {
            status: response.status,
            statusText: response.statusText,
            data: response.data
        });
        return response;
    }).catch(error => {
        console.error('getTruthTables API 错误:', {
            message: error.message,
            code: error.code,
            response: error.response?.data,
            status: error.response?.status
        });
        throw error;
    });
}

// 获取真值表详情
export async function getTruthTable(id) {
  try {
    console.log('调用 getTruthTable API, ID:', id);
    console.log('请求URL:', `/api/truth-tables/${id}`);
    
    const response = await api.get(`/api/truth-tables/${id}`);
    console.log('getTruthTable API 响应:', {
      status: response.status,
      statusText: response.statusText,
      data: response.data,
      headers: response.headers
    });
    return response;
  } catch (error) {
    console.error('getTruthTable API 错误:', {
      message: error.message,
      code: error.code,
      response: error.response?.data,
      status: error.response?.status,
      config: {
        url: error.config?.url,
        method: error.config?.method,
        baseURL: error.config?.baseURL,
        headers: error.config?.headers
      }
    });
    throw error;
  }
}

// 创建真值表
export function createTruthTable(data) {
    return api.post('/api/truth-tables', data)
}

// 更新真值表
export function updateTruthTable(id, data) {
    return api.put(`/api/truth-tables/${id}`, data)
}

// 删除真值表
export function deleteTruthTable(id) {
    return api.delete(`/api/truth-tables/${id}`)
}

// 创建测试组
export function createTestGroup(data) {
  return api.post('/api/test-groups', data)
}

// 更新测试组
export function updateTestGroup(id, data) {
  return api.put(`/api/test-groups/${id}`, data)
}

// 删除测试组
export function deleteTestGroup(id) {
  return api.delete(`/api/test-groups/${id}`)
} 