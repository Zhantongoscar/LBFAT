import api from '../utils/api'

// 获取图纸列表
export function getDrawings() {
  return api.get('/drawings')
}

// 创建图纸
export function createDrawing(data) {
  return api.post('/drawings', data)
}

// 更新图纸
export function updateDrawing(id, data) {
  return api.put(`/drawings/${id}`, data)
}

// 删除图纸
export function deleteDrawing(id) {
  return api.delete(`/drawings/${id}`)
} 