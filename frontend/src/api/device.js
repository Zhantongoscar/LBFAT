import axios from 'axios'

const baseURL = import.meta.env.VITE_API_URL

const deviceAPI = {
  getDevices(filters = {}) {
    return axios.get(`${baseURL}/api/devices`, { params: filters })
  },
  
  getDevice(projectName, moduleType, serialNumber) {
    return axios.get(`${baseURL}/api/devices/${projectName}/${moduleType}/${serialNumber}`)
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
