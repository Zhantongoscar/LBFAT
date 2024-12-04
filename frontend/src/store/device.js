import { defineStore } from 'pinia'
import deviceApi from '../api/device'

export const useDeviceStore = defineStore('device', {
  state: () => ({
    devices: [],
    loading: false,
    error: null,
    currentProject: null
  }),

  getters: {
    onlineDevices: (state) => {
      return state.devices.filter(d => d.status === 'online')
    },
    offlineDevices: (state) => {
      return state.devices.filter(d => d.status === 'offline')
    },
    devicesByProject: (state) => (projectName) => {
      return state.devices.filter(d => d.project_name === projectName)
    }
  },

  actions: {
    async fetchDevices(filters = {}) {
      this.loading = true
      try {
        const response = await deviceApi.getDevices(filters)
        this.devices = response.data.data
        this.error = null
        if (filters.projectName) {
          this.currentProject = filters.projectName
        }
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },

    async getDevice(projectName, moduleType, serialNumber) {
      try {
        const response = await deviceApi.getDevice(projectName, moduleType, serialNumber)
        return response.data.data
      } catch (error) {
        this.error = error.message
        return null
      }
    },

    async createDevice(device) {
      try {
        await deviceApi.createDevice(device)
        await this.fetchDevices({ projectName: device.projectName })
        return true
      } catch (error) {
        this.error = error.message
        return false
      }
    },

    async deleteDevice(projectName, moduleType, serialNumber) {
      try {
        await deviceApi.deleteDevice(projectName, moduleType, serialNumber)
        this.devices = this.devices.filter(d => 
          !(d.project_name === projectName && 
            d.module_type === moduleType && 
            d.serial_number === serialNumber)
        )
        return true
      } catch (error) {
        this.error = error.message
        return false
      }
    },

    // WebSocket更新设备状态
    updateDeviceStatus(device) {
      const index = this.devices.findIndex(d => 
        d.project_name === device.projectName &&
        d.module_type === device.moduleType &&
        d.serial_number === device.serialNumber
      )

      if (index !== -1) {
        this.devices[index] = {
          ...this.devices[index],
          status: device.status,
          rssi: device.rssi,
          updated_at: new Date().toISOString()
        }
      } else if (this.currentProject === device.projectName) {
        this.devices.push({
          project_name: device.projectName,
          module_type: device.moduleType,
          serial_number: device.serialNumber,
          status: device.status,
          rssi: device.rssi,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
      }
    }
  }
}) 