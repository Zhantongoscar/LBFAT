<template>
  <div class="device-list">
    <div class="header">
      <h1>设备管理</h1>
    </div>

    <!-- 设备列表 -->
    <el-table :data="devices" style="width: 100%" v-loading="loading">
      <el-table-column prop="project_name" label="项目名称" />
      <el-table-column prop="module_type" label="模块类型" />
      <el-table-column prop="serial_number" label="序列号" />
      <el-table-column prop="status" label="状态">
        <template #default="scope">
          <el-tag :type="scope.row.status === 'online' ? 'success' : 'danger'">
            {{ scope.row.status === 'online' ? '在线' : '离线' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="rssi" label="信号强度">
        <template #default="scope">
          <el-progress
            :percentage="calculateRssiPercentage(scope.row.rssi)"
            :status="getRssiStatus(scope.row.rssi)"
          />
        </template>
      </el-table-column>
      <el-table-column prop="updated_at" label="最后通信时间">
        <template #default="scope">
          {{ formatDate(scope.row.updated_at) }}
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useDeviceStore } from '../store/device'

export default {
  name: 'DeviceList',
  setup() {
    const deviceStore = useDeviceStore()
    const loading = ref(false)

    // 加载设备列表
    const loadDevices = async () => {
      loading.value = true
      try {
        await deviceStore.fetchDevices()
      } catch (error) {
        ElMessage.error('加载设备列表失败')
      } finally {
        loading.value = false
      }
    }

    // 计算RSSI百分比
    const calculateRssiPercentage = (rssi) => {
      if (rssi === 0) return 0
      return Math.min(100, Math.max(0, (rssi + 100)))
    }

    // 获取RSSI状态
    const getRssiStatus = (rssi) => {
      if (rssi === 0) return 'exception'
      if (rssi > -60) return 'success'
      if (rssi > -80) return 'warning'
      return 'exception'
    }

    // 格式化日期
    const formatDate = (date) => {
      return new Date(date).toLocaleString()
    }

    onMounted(() => {
      loadDevices()
    })

    return {
      devices: deviceStore.devices,
      loading,
      calculateRssiPercentage,
      getRssiStatus,
      formatDate
    }
  }
}
</script>

<style scoped>
.device-list {
  padding: 20px;
}

.header {
  margin-bottom: 20px;
}
</style>
