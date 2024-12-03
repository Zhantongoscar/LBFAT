import axios from 'axios'

const baseURL = 'http://localhost:3000/api'

export const deviceAPI = {
  getDevices() {
    return axios.get(`${baseURL}/devices`)
  },
  
  createDevice(data) {
    return axios.post(`${baseURL}/devices`, data)
  },
  
  updateDevice(id, data) {
    return axios.put(`${baseURL}/devices/${id}`, data)
  },
  
  deleteDevice(id) {
    return axios.delete(`${baseURL}/devices/${id}`)
  }
}
