<template>
  <div class="device-list">
    <div class="header">
      <h1>设备管理</h1>
      <el-button type="primary" @click="loadDevices" :loading="loading">
        刷新
      </el-button>
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
      <el-table-column prop="updated_at" label="最后更新时间">
        <template #default="scope">
          {{ new Date(scope.row.updated_at).toLocaleString() }}
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

export default {
  name: 'DeviceList',
  setup() {
    const devices = ref([])
    const loading = ref(false)

    // 加载设备列表
    const loadDevices = async () => {
      loading.value = true
      try {
        console.log('开始加载设备列表')
        const response = await api.get('/api/devices')
        console.log('获取到的数据:', response.data)
        if (response.data.code === 200) {
          devices.value = response.data.data
        } else {
          throw new Error(response.data.message)
        }
      } catch (error) {
        console.error('加载失败:', error)
        ElMessage.error('加载设备列表失败')
      } finally {
        loading.value = false
      }
    }

    // 初始加载
    onMounted(() => {
      loadDevices()
    })

    return {
      devices,
      loading,
      loadDevices
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
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
