import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useDeviceStore = defineStore('device', () => {
  // 设备列表
  const devices = ref([])
  
  // 设备类型定义
  const deviceTypes = {
    EDB: {
      name: 'EDB',
      pointTypes: ['DI', 'DO', 'AI', 'AO'],
      defaultConfig: {
        DI: { count: 7, prefix: 'EDB数字输入点' },
        DO: { count: 3, prefix: 'EDB数字输出点' },
        AI: { count: 7, prefix: 'EDB模拟输入点' },
        AO: { count: 3, prefix: 'EDB模拟输出点' }
      }
    },
    CPU: {
      name: 'CPU',
      pointTypes: ['DI', 'DO'],
      defaultConfig: {
        DI: { count: 4, prefix: 'CPU数字输入点' },
        DO: { count: 4, prefix: 'CPU数字输出点' }
      }
    }
  }

  // 获取设备配置
  const getDeviceConfig = (deviceType) => {
    return deviceTypes[deviceType] || null
  }

  // 获取设备的点位列表
  const getDevicePoints = (deviceType, pointType) => {
    const config = deviceTypes[deviceType]
    if (!config || !config.defaultConfig[pointType]) {
      return []
    }

    const { count, prefix } = config.defaultConfig[pointType]
    return Array.from({ length: count }, (_, i) => ({
      index: i + 1,
      type: pointType,
      name: `${prefix}${i + 1}`,
      description: `${prefix}${i + 1}-前段`
    }))
  }

  // 添加设备
  const addDevice = (device) => {
    const config = deviceTypes[device.type]
    if (!config) return false

    const newDevice = {
      ...device,
      points: {},
      online: false,
      lastUpdateTime: new Date()
    }

    // 初始化点位配置
    config.pointTypes.forEach(type => {
      newDevice.points[type] = getDevicePoints(device.type, type)
    })

    devices.value.push(newDevice)
    return true
  }

  // 更新设备状态
  const updateDeviceStatus = (deviceId, status) => {
    const device = devices.value.find(d => d.id === deviceId)
    if (device) {
      device.online = status.online
      device.lastUpdateTime = new Date()
      if (status.points) {
        Object.keys(status.points).forEach(type => {
          if (device.points[type]) {
            status.points[type].forEach(point => {
              const targetPoint = device.points[type].find(p => p.index === point.index)
              if (targetPoint) {
                Object.assign(targetPoint, point)
              }
            })
          }
        })
      }
    }
  }

  // 获取可��的点位选项
  const getPointOptions = (deviceType, pointType) => {
    const config = deviceTypes[deviceType]
    if (!config || !config.defaultConfig[pointType]) {
      return []
    }

    const { count, prefix } = config.defaultConfig[pointType]
    return Array.from({ length: count }, (_, i) => ({
      value: i + 1,
      label: `${prefix}${i + 1}`,
      description: `${prefix}${i + 1}-前段`
    }))
  }

  // 计算属性：在线设备列表
  const onlineDevices = computed(() => 
    devices.value.filter(d => d.online)
  )

  // 计算属性：离线设备列表
  const offlineDevices = computed(() => 
    devices.value.filter(d => !d.online)
  )

  return {
    devices,
    deviceTypes,
    getDeviceConfig,
    getDevicePoints,
    addDevice,
    updateDeviceStatus,
    getPointOptions,
    onlineDevices,
    offlineDevices
  }
}) 