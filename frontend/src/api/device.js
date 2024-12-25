import api from '../utils/api'

const deviceAPI = {
  getDevices(filters = {}) {
    console.log('调用 getDevices API, 参数:', filters)
    return api.get('/devices', { params: filters })
      .then(response => {
        console.log('getDevices API 响应:', response)
        return response
      })
      .catch(error => {
        console.error('getDevices API 错误:', error)
        throw error
      })
  },
  
  getDevice(id) {
    return api.get(`/devices/${id}`)
  },
  
  createDevice(device) {
    return api.post('/devices', device)
  },
  
  updateDevice(id, data) {
    return api.put(`/devices/${id}`, data)
  },
  
  deleteDevice(id) {
    return api.delete(`/devices/${id}`)
  }
}

export default deviceAPI
