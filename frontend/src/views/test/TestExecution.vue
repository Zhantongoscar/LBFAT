<template>
  <div class="test-execution">
    <!-- 产品信息 -->
    <el-card class="box-card mb-20">
      <template #header>
        <div class="card-header">
          <span>产品信息</span>
        </div>
      </template>
      <el-form :model="productInfo" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="产品型号">
              <el-input v-model="productInfo.model" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="序列号">
              <el-input v-model="productInfo.serialNumber" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="固件版本">
              <el-input v-model="productInfo.firmwareVersion" disabled />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- 测试设备状态（可收纳） -->
    <el-card class="box-card mb-20">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-button 
              :icon="isDevicesPanelCollapsed ? 'ArrowRight' : 'ArrowDown'"
              @click="toggleDevicesPanel"
              text
            />
            <span>测试设备状态</span>
            <el-tag type="info" class="ml-10">
              {{ onlineCount }}/{{ totalCount }}
            </el-tag>
          </div>
          <div class="header-right">
            <el-switch
              v-model="showOfflineDevices"
              active-text="显示离线设备"
            />
          </div>
        </div>
      </template>
      
      <!-- 设备状态面板（可收纳） -->
      <div v-show="!isDevicesPanelCollapsed">
        <!-- 在线设备区域 -->
        <div class="devices-section" v-if="onlineDevices.length > 0">
          <h4 class="section-title">在线设备</h4>
          <div class="devices-grid">
            <div
              v-for="device in onlineDevices"
              :key="device.id"
              class="device-item online"
              @click="showDeviceDetails(device)"
            >
              <el-tooltip
                :content="'信号强度: ' + device.rssi + ' dBm'"
                placement="top"
              >
                <div class="device-icon">
                  <el-icon :size="24">
                    <Monitor v-if="device.type === 'EDB'" />
                    <Cpu v-else-if="device.type === 'CPU'" />
                    <Connection v-else />
                  </el-icon>
                  <span class="device-name">{{ device.name }}</span>
                  <div class="signal-indicator" :class="getSignalLevel(device.rssi)"></div>
                </div>
              </el-tooltip>
            </div>
          </div>
        </div>

        <!-- 离线设备区域 -->
        <div class="devices-section" v-if="showOfflineDevices && offlineDevices.length > 0">
          <h4 class="section-title">离线设备</h4>
          <div class="devices-grid">
            <div
              v-for="device in offlineDevices"
              :key="device.id"
              class="device-item offline"
              @click="showDeviceDetails(device)"
            >
              <el-tooltip content="设备离线" placement="top">
                <div class="device-icon">
                  <el-icon :size="24">
                    <Monitor v-if="device.type === 'EDB'" />
                    <Cpu v-else-if="device.type === 'CPU'" />
                    <Connection v-else />
                  </el-icon>
                  <span class="device-name">{{ device.name }}</span>
                </div>
              </el-tooltip>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 设备详情对话框 -->
    <el-dialog
      v-model="deviceDetailsVisible"
      title="设备详情"
      width="500px"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="设备名称">{{ selectedDevice?.name }}</el-descriptions-item>
        <el-descriptions-item label="设备类型">{{ selectedDevice?.type }}</el-descriptions-item>
        <el-descriptions-item label="序列号">{{ selectedDevice?.serialNumber }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="selectedDevice?.online ? 'success' : 'danger'">
            {{ selectedDevice?.online ? '在线' : '离线' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="信号强度" v-if="selectedDevice?.online">
          {{ selectedDevice?.rssi }} dBm
          <el-tag :type="getSignalLevelType(selectedDevice?.rssi)" class="ml-10">
            {{ getSignalLevelText(selectedDevice?.rssi) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="最后更新时间">
          {{ formatDateTime(selectedDevice?.lastUpdateTime) }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 测试控制区域 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>测试控制</span>
        </div>
      </template>
      <div class="test-control">
        <!-- 测试控制内容 -->
      </div>
    </el-card>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { Monitor, Cpu, Connection, ArrowRight, ArrowDown } from '@element-plus/icons-vue'

export default {
  name: 'TestExecution',
  components: {
    Monitor,
    Cpu,
    Connection,
    ArrowRight,
    ArrowDown
  },
  setup() {
    // 产品信息
    const productInfo = ref({
      model: 'EDB-TEST-001',
      serialNumber: 'SN20240001',
      firmwareVersion: 'v1.0.0'
    })

    // 设备面板收纳状态
    const isDevicesPanelCollapsed = ref(true)
    const showOfflineDevices = ref(true)

    // 模拟设备数据
    const devices = ref([
      { id: 1, name: 'EDB-1', type: 'EDB', serialNumber: 'EDB001', online: true, rssi: -65, lastUpdateTime: new Date() },
      { id: 2, name: 'EDB-2', type: 'EDB', serialNumber: 'EDB002', online: true, rssi: -75, lastUpdateTime: new Date() },
      { id: 3, name: 'CPU-1', type: 'CPU', serialNumber: 'CPU001', online: false, lastUpdateTime: new Date() },
      { id: 4, name: 'EDB-3', type: 'EDB', serialNumber: 'EDB003', online: true, rssi: -85, lastUpdateTime: new Date() }
    ])

    // 计算属性：在线设备
    const onlineDevices = computed(() => devices.value.filter(d => d.online))
    
    // 计算属性：离线设备
    const offlineDevices = computed(() => devices.value.filter(d => !d.online))

    // 设备统计
    const onlineCount = computed(() => onlineDevices.value.length)
    const totalCount = computed(() => devices.value.length)

    // 设备详情对话框
    const deviceDetailsVisible = ref(false)
    const selectedDevice = ref(null)

    // 方法：切换设备面板显示状态
    const toggleDevicesPanel = () => {
      isDevicesPanelCollapsed.value = !isDevicesPanelCollapsed.value
    }

    // 方法：显示设备详情
    const showDeviceDetails = (device) => {
      selectedDevice.value = device
      deviceDetailsVisible.value = true
    }

    // 方法：获取信号强度等级
    const getSignalLevel = (rssi) => {
      if (rssi >= -65) return 'signal-excellent'
      if (rssi >= -75) return 'signal-good'
      if (rssi >= -85) return 'signal-fair'
      return 'signal-poor'
    }

    // 方法：获取信号强度文本
    const getSignalLevelText = (rssi) => {
      if (rssi >= -65) return '优秀'
      if (rssi >= -75) return '良好'
      if (rssi >= -85) return '一般'
      return '较差'
    }

    // 方法：获取信号强度标签类型
    const getSignalLevelType = (rssi) => {
      if (rssi >= -65) return 'success'
      if (rssi >= -75) return ''
      if (rssi >= -85) return 'warning'
      return 'danger'
    }

    // 方法：格式化日期时间
    const formatDateTime = (date) => {
      if (!date) return ''
      return new Date(date).toLocaleString()
    }

    return {
      productInfo,
      isDevicesPanelCollapsed,
      showOfflineDevices,
      devices,
      onlineDevices,
      offlineDevices,
      onlineCount,
      totalCount,
      deviceDetailsVisible,
      selectedDevice,
      toggleDevicesPanel,
      showDeviceDetails,
      getSignalLevel,
      getSignalLevelText,
      getSignalLevelType,
      formatDateTime
    }
  }
}
</script>

<style scoped>
.test-execution {
  padding: 20px;
}

.mb-20 {
  margin-bottom: 20px;
}

.ml-10 {
  margin-left: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #3f4d68;
  margin: -20px -20px 20px -20px;
  padding: 15px 20px;
  color: #bfcbd9;
  border-radius: 4px 4px 0 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-left .el-button {
  color: #bfcbd9;
}

.header-left .el-button:hover {
  color: #fff;
}

.header-right {
  color: #bfcbd9;
}

.devices-section {
  margin-bottom: 20px;
}

.section-title {
  margin: 0 0 10px 0;
  color: #606266;
  font-size: 14px;
}

.devices-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 15px;
  padding: 10px;
}

.device-item {
  padding: 10px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s;
  text-align: center;
}

.device-item.online {
  background-color: #f0f9eb;
  border: 1px solid #e1f3d8;
}

.device-item.offline {
  background-color: #f4f4f5;
  border: 1px solid #e9e9eb;
  opacity: 0.7;
}

.device-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.device-icon {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.device-name {
  font-size: 12px;
  color: #606266;
}

.signal-indicator {
  position: absolute;
  top: -2px;
  right: -2px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.signal-excellent {
  background-color: #67c23a;
}

.signal-good {
  background-color: #409eff;
}

.signal-fair {
  background-color: #e6a23c;
}

.signal-poor {
  background-color: #f56c6c;
}
</style> 