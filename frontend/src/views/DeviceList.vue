<template>
  <div class="device-list">
    <el-table :data="devices" style="width: 100%">
      <el-table-column prop="device_code" label="设备编码" />
      <el-table-column prop="device_name" label="设备名称" />
      <el-table-column prop="device_type" label="设备类型" />
      <el-table-column label="状态">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
            {{ scope.row.status === 1 ? '在线' : '离线' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="last_online_time" label="最后在线时间" />
      <el-table-column label="操作">
        <template #default="scope">
          <el-button @click="viewDetails(scope.row)" type="text">查看详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加刷新按钮 -->
    <div class="actions">
      <el-button type="primary" @click="fetchDevices">刷新设备列表</el-button>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'DeviceList',
  data() {
    return {
      devices: []
    }
  },
  created() {
    this.fetchDevices()
  },
  methods: {
    async fetchDevices() {
      try {
        console.log('Fetching devices...')
        const response = await axios.get('http://localhost:3000/api/devices')
        console.log('Response:', response.data)
        this.devices = response.data
      } catch (error) {
        console.error('Error fetching devices:', error)
        this.$message.error('获取设备列表失败')
      }
    },
    viewDetails(device) {
      this.$router.push(`/devices/${device.device_code}`)
    }
  }
}
</script>

<style scoped>
.device-list {
  padding: 20px;
}
.actions {
  margin-top: 20px;
  text-align: right;
}
</style> 