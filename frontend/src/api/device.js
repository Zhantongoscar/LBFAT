import axios from 'axios'

const baseURL = import.meta.env.VITE_API_URL

const deviceAPI = {
  getDevices(filters = {}) {
    console.log('调用 getDevices API, 参数:', filters)
    return axios.get(`${baseURL}/api/devices`, { params: filters })
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
    return axios.get(`${baseURL}/api/devices/${id}`)
  },
  
  createDevice(device) {
    return axios.post(`${baseURL}/api/devices`, device)
  },
  
  updateDevice(id, data) {
    return axios.put(`${baseURL}/api/devices/${id}`, data)
  },
  
  deleteDevice(id) {
    return axios.delete(`${baseURL}/api/devices/${id}`)
  }
}

export default deviceAPI
