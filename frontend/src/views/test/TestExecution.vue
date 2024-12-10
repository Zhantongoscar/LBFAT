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
            <span>测试设备状态</span>
            <el-tag type="info" class="ml-10">
              {{ filteredOnlineDevices.length }}/{{ devices.length }}
            </el-tag>
          </div>
          <el-button
            type="text"
            @click="isDevicesPanelCollapsed = !isDevicesPanelCollapsed"
          >
            <el-icon :size="16">
              <ArrowDown v-if="!isDevicesPanelCollapsed" />
              <ArrowRight v-else />
            </el-icon>
            {{ isDevicesPanelCollapsed ? '展开' : '收起' }}
          </el-button>
        </div>
      </template>

      <el-collapse-transition>
        <div v-show="!isDevicesPanelCollapsed" class="device-status-panel">
          <!-- 在线设备区域 -->
          <div class="devices-section online-section">
            <div class="section-header">
              <el-tag type="success" size="small">在线设备</el-tag>
              <div class="section-controls">
                <el-select v-model="onlineDeviceType" placeholder="设备类型" size="small" clearable>
                  <el-option label="全部" value="" />
                  <el-option v-for="type in deviceTypes" :key="type" :label="type" :value="type" />
                </el-select>
                <el-pagination
                  v-if="filteredOnlineDevices.length > pageSize"
                  :current-page="onlineCurrentPage"
                  :page-size="pageSize"
                  :total="filteredOnlineDevices.length"
                  layout="prev, pager, next"
                  small
                  @current-change="handleOnlinePageChange"
                />
              </div>
            </div>
            <div class="devices-grid">
              <div
                v-for="device in paginatedOnlineDevices"
                :key="device.id"
                class="device-item online"
                @click="showDeviceDetails(device)"
              >
                <el-tooltip
                  :content="'信号强度: ' + device.rssi + ' dBm'"
                  placement="top"
                >
                  <div class="device-icon">
                    <el-icon :size="20">
                      <Monitor v-if="device.type === 'EDB'" />
                      <Cpu v-if="device.type === 'CPU'" />
                      <Connection v-else />
                    </el-icon>
                    <span class="device-name">{{ device.name }}</span>
                    <div class="signal-indicator" :class="getSignalLevel(device.rssi)"></div>
                  </div>
                </el-tooltip>
              </div>
              <div v-if="filteredOnlineDevices.length === 0" class="empty-tip">
                暂无在线设备
              </div>
            </div>
          </div>

          <!-- 离线设备区域 -->
          <div class="devices-section offline-section">
            <div class="section-header">
              <el-tag type="danger" size="small">离线设备</el-tag>
              <div class="section-controls">
                <el-select v-model="offlineDeviceType" placeholder="设备类型" size="small" clearable>
                  <el-option label="全部" value="" />
                  <el-option v-for="type in deviceTypes" :key="type" :label="type" :value="type" />
                </el-select>
                <el-pagination
                  v-if="filteredOfflineDevices.length > pageSize"
                  :current-page="offlineCurrentPage"
                  :page-size="pageSize"
                  :total="filteredOfflineDevices.length"
                  layout="prev, pager, next"
                  small
                  @current-change="handleOfflinePageChange"
                />
              </div>
            </div>
            <div class="devices-grid">
              <div
                v-for="device in paginatedOfflineDevices"
                :key="device.id"
                class="device-item offline"
                @click="showDeviceDetails(device)"
              >
                <el-tooltip content="设备离线" placement="top">
                  <div class="device-icon">
                    <el-icon :size="20">
                      <Monitor v-if="device.type === 'EDB'" />
                      <Cpu v-if="device.type === 'CPU'" />
                      <Connection v-else />
                    </el-icon>
                    <span class="device-name">{{ device.name }}</span>
                  </div>
                </el-tooltip>
              </div>
              <div v-if="filteredOfflineDevices.length === 0" class="empty-tip">
                暂无离线设备
              </div>
            </div>
          </div>
        </div>
      </el-collapse-transition>
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
          <div class="header-actions">
            <el-button type="primary" @click="startTest" :disabled="!hasInputTypeItems">开始测试</el-button>
          </div>
        </div>
      </template>
      <!-- 测试控制内容 -->
    </el-card>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { Monitor, Cpu, Connection, ArrowDown, ArrowRight } from '@element-plus/icons-vue'

export default {
  name: 'TestExecution',
  components: {
    Monitor,
    Cpu,
    Connection,
    ArrowDown,
    ArrowRight
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

    // 模拟设备数据
    const devices = ref([
      { 
        id: 1, 
        name: 'EDB-1', 
        type: 'EDB', 
        serialNumber: 'EDB001', 
        online: true, 
        rssi: -65, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 2, 
        name: 'EDB-2', 
        type: 'EDB', 
        serialNumber: 'EDB002', 
        online: true, 
        rssi: -75, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 3, 
        name: 'CPU-1', 
        type: 'CPU', 
        serialNumber: 'CPU001', 
        online: false, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 4, 
        name: 'EDB-3', 
        type: 'EDB', 
        serialNumber: 'EDB003', 
        online: true, 
        rssi: -85, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 5, 
        name: 'EDB-4', 
        type: 'EDB', 
        serialNumber: 'EDB004', 
        online: false, 
        lastUpdateTime: new Date() 
      }
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

    // 分页和筛选相关
    const pageSize = ref(50) // 每页显示50个设备
    const onlineCurrentPage = ref(1)
    const offlineCurrentPage = ref(1)
    const onlineDeviceType = ref('')
    const offlineDeviceType = ref('')

    // 设备类型列表
    const deviceTypes = computed(() => {
      const types = new Set(devices.value.map(d => d.type))
      return Array.from(types)
    })

    // 过滤后的设备列表
    const filteredOnlineDevices = computed(() => {
      let filtered = onlineDevices.value
      if (onlineDeviceType.value) {
        filtered = filtered.filter(d => d.type === onlineDeviceType.value)
      }
      return filtered
    })

    const filteredOfflineDevices = computed(() => {
      let filtered = offlineDevices.value
      if (offlineDeviceType.value) {
        filtered = filtered.filter(d => d.type === offlineDeviceType.value)
      }
      return filtered
    })

    // 分页后的设备列表
    const paginatedOnlineDevices = computed(() => {
      const start = (onlineCurrentPage.value - 1) * pageSize.value
      const end = start + pageSize.value
      return filteredOnlineDevices.value.slice(start, end)
    })

    const paginatedOfflineDevices = computed(() => {
      const start = (offlineCurrentPage.value - 1) * pageSize.value
      const end = start + pageSize.value
      return filteredOfflineDevices.value.slice(start, end)
    })

    // 分页处理方法
    const handleOnlinePageChange = (page) => {
      onlineCurrentPage.value = page
    }

    const handleOfflinePageChange = (page) => {
      offlineCurrentPage.value = page
    }

    return {
      productInfo,
      isDevicesPanelCollapsed,
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
      formatDateTime,
      pageSize,
      onlineCurrentPage,
      offlineCurrentPage,
      onlineDeviceType,
      offlineDeviceType,
      deviceTypes,
      filteredOnlineDevices,
      filteredOfflineDevices,
      paginatedOnlineDevices,
      paginatedOfflineDevices,
      handleOnlinePageChange,
      handleOfflinePageChange
    }
  }
}
</script>

<style scoped>
.test-execution {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.ml-10 {
  margin-left: 10px;
}

.mb-20 {
  margin-bottom: 20px;
}

/* 设备状态面板样式 */
.device-status-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-top: 10px;
}

.devices-section {
  background-color: #fff;
  border-radius: 4px;
  padding: 15px;
}

.online-section {
  border: 1px solid #e1f3d8;
  background-color: #f0f9eb;
}

.offline-section {
  border: 1px solid #fde2e2;
  background-color: #fef0f0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.section-controls {
  display: flex;
  gap: 10px;
  align-items: center;
}

.devices-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 10px;
  padding: 10px;
}

.device-item {
  padding: 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
  text-align: center;
}

.device-icon {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.device-name {
  font-size: 11px;
  color: #606266;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.signal-indicator {
  position: absolute;
  top: -2px;
  right: -2px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.empty-tip {
  text-align: center;
  color: #909399;
  padding: 20px;
  width: 100%;
}

/* 信号强度指示器颜色 */
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