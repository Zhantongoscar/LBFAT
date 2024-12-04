<template>
  <div class="device-list">
    <div class="header">
      <h1>设备管理</h1>
      <div class="controls">
        <el-tag :type="wsConnected ? 'success' : 'danger'" class="connection-status">
          {{ wsConnected ? '实时连接' : '连接断开' }}
        </el-tag>
        <el-select v-model="currentProject" placeholder="选择项目" @change="handleProjectChange">
          <el-option
            v-for="project in projects"
            :key="project.project_name"
            :label="project.project_name"
            :value="project.project_name"
          />
        </el-select>
      </div>
    </div>

    <!-- 设备列表 -->
    <el-table :data="devices" style="width: 100%" v-loading="loading">
      <el-table-column prop="project_name" label="项目名称" />
      <el-table-column prop="module_type" label="模块类型" />
      <el-table-column prop="serial_number" label="序列号" />
      <el-table-column prop="status" label="状态">
        <template #default="scope">
          <el-tag :type="scope.row.status === 'online' ? 'success' : 'danger'">
            {{ scope.row.status }}
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
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button
            type="danger"
            link
            @click="handleDelete(scope.row)"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useDeviceStore } from '../store/device'
import { useProjectStore } from '../store/project'
import { useWebSocket } from '../composables/useWebSocket'

export default {
  name: 'DeviceList',
  setup() {
    const route = useRoute()
    const deviceStore = useDeviceStore()
    const projectStore = useProjectStore()
    const currentProject = ref('')
    const loading = ref(false)

    // 从store获取数据
    const devices = computed(() => deviceStore.devices)
    const projects = computed(() => projectStore.projects)

    // WebSocket连接
    const { connect, disconnect, subscribeToProject, isConnected: wsConnected } = useWebSocket()

    // 加载项目列表
    const loadProjects = async () => {
      try {
        await projectStore.fetchProjects()
        
        // 如果URL中有项目参数，设置当前项目
        const projectFromQuery = route.query.project
        if (projectFromQuery) {
          currentProject.value = projectFromQuery
          await loadDevices()
          subscribeToProject(projectFromQuery)
        }
      } catch (error) {
        ElMessage.error('加载项目列表失败')
      }
    }

    // 加载设备列表
    const loadDevices = async () => {
      if (!currentProject.value) return
      loading.value = true
      try {
        await deviceStore.fetchDevices({ projectName: currentProject.value })
      } catch (error) {
        ElMessage.error('加载设备列表失败')
      } finally {
        loading.value = false
      }
    }

    // 处理项目变更
    const handleProjectChange = async (projectName) => {
      if (projectName) {
        await loadDevices()
        subscribeToProject(projectName)
      }
    }

    // 计算RSSI百分比
    const calculateRssiPercentage = (rssi) => {
      if (rssi === 0) return 0
      // RSSI范围通常在-100到0之间，转换为0-100的百分比
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

    // 处理删除设备
    const handleDelete = async (device) => {
      try {
        await ElMessageBox.confirm(
          `确定要删除该设备吗？\n项目：${device.project_name}\n序列号：${device.serial_number}`,
          '警告',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning',
          }
        )
        
        await deviceStore.deleteDevice(device.project_name, device.module_type, device.serial_number)
        ElMessage.success('删除成功')
        await loadDevices() // 重新加载设备列表
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
    }

    onMounted(() => {
      loadProjects()
      connect()
    })

    onUnmounted(() => {
      disconnect()
    })

    return {
      devices,
      projects,
      currentProject,
      loading,
      wsConnected,
      handleProjectChange,
      calculateRssiPercentage,
      getRssiStatus,
      formatDate,
      handleDelete
    }
  }
}
</script>

<style scoped>
.device-list {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.controls {
  display: flex;
  gap: 16px;
  align-items: center;
}

.controls .el-select {
  width: 200px;
}

.connection-status {
  min-width: 80px;
  text-align: center;
}
</style>
