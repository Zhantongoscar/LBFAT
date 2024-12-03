<template>
  <div class="device-list">
    <h2>设备管理</h2>
    <el-card>
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">添加设备</el-button>
      </div>
      <el-table :data="devices" style="width: 100%">
        <el-table-column prop="device_code" label="设备编码" />
        <el-table-column prop="device_name" label="设备名称" />
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">
              {{ scope.row.status === 1 ? '在线' : '离线' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="last_online_time" label="最后在线时间" />
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="500px">
      <el-form :model="deviceForm" label-width="100px">
        <el-form-item label="设备编码">
          <el-input v-model="deviceForm.device_code" />
        </el-form-item>
        <el-form-item label="设备名称">
          <el-input v-model="deviceForm.device_name" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

export default {
  name: 'DeviceList',
  setup() {
    const devices = ref([])
    const dialogVisible = ref(false)
    const dialogTitle = ref('')
    const deviceForm = ref({
      device_code: '',
      device_name: ''
    })
    const isEdit = ref(false)

    const fetchDevices = async () => {
      try {
        const response = await fetch('http://localhost:3000/api/devices')
        const data = await response.json()
        devices.value = data
      } catch (error) {
        console.error('Error fetching devices:', error)
        ElMessage.error('获取设备列表失败')
      }
    }

    const handleAdd = () => {
      isEdit.value = false
      dialogTitle.value = '添加设备'
      deviceForm.value = {
        device_code: '',
        device_name: ''
      }
      dialogVisible.value = true
    }

    const handleEdit = (row) => {
      isEdit.value = true
      dialogTitle.value = '编辑设备'
      deviceForm.value = { ...row }
      dialogVisible.value = true
    }

    const handleDelete = async (row) => {
      try {
        await fetch(`http://localhost:3000/api/devices/${row.id}`, {
          method: 'DELETE'
        })
        ElMessage.success('删除成功')
        fetchDevices()
      } catch (error) {
        console.error('Error deleting device:', error)
        ElMessage.error('删除设备失败')
      }
    }

    const handleSave = async () => {
      try {
        const url = isEdit.value 
          ? `http://localhost:3000/api/devices/${deviceForm.value.id}`
          : 'http://localhost:3000/api/devices'
        const method = isEdit.value ? 'PUT' : 'POST'
        
        await fetch(url, {
          method,
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(deviceForm.value)
        })
        
        ElMessage.success(isEdit.value ? '更新成功' : '添加成功')
        dialogVisible.value = false
        fetchDevices()
      } catch (error) {
        console.error('Error saving device:', error)
        ElMessage.error(isEdit.value ? '更新设备失败' : '添加设备失败')
      }
    }

    onMounted(() => {
      fetchDevices()
    })

    return {
      devices,
      dialogVisible,
      dialogTitle,
      deviceForm,
      handleAdd,
      handleEdit,
      handleDelete,
      handleSave
    }
  }
}
</script>

<style scoped>
.device-list {
  padding: 20px;
}
.toolbar {
  margin-bottom: 20px;
}
</style>
