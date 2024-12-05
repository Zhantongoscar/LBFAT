<template>
  <div class="device-config">
    <h1>设备配置</h1>

    <!-- 搜索和添加按钮 -->
    <div class="operation-bar">
      <el-input
        v-model="searchQuery"
        placeholder="搜索设备类型"
        style="width: 200px"
        clearable
        @clear="handleSearch"
        @input="handleSearch"
      />
      <el-button type="primary" @click="showAddDialog">添加设备类型</el-button>
    </div>

    <!-- 设备类型列表 -->
    <el-table :data="filteredDeviceTypes" style="width: 100%; margin-top: 20px">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="type_name" label="设备类型" />
      <el-table-column prop="unit_count" label="单元数量" width="100" />
      <el-table-column prop="description" label="描述" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button
            type="primary"
            link
            @click="handleEdit(scope.row)"
          >
            编辑
          </el-button>
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

    <!-- 添加/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑设备类型' : '添加设备类型'"
      width="500px"
    >
      <el-form :model="deviceForm" label-width="100px">
        <el-form-item label="设备类型">
          <el-input v-model="deviceForm.type_name" />
        </el-form-item>
        <el-form-item label="单元数量">
          <el-input-number v-model="deviceForm.unit_count" :min="1" :max="32" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="deviceForm.description"
            type="textarea"
            rows="3"
          />
        </el-form-item>
        <el-form-item label="单元配置">
          <div v-for="i in deviceForm.unit_count" :key="i" class="unit-config">
            <span>单元 {{ i }}:</span>
            <el-select v-model="deviceForm.units[i-1]">
              <el-option label="DI" value="DI" />
              <el-option label="DO" value="DO" />
              <el-option label="AI" value="AI" />
              <el-option label="AO" value="AO" />
            </el-select>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import deviceConfigApi from '../api/deviceConfig'

export default {
  name: 'DeviceConfig',
  setup() {
    const deviceTypes = ref([])
    const searchQuery = ref('')
    const dialogVisible = ref(false)
    const isEdit = ref(false)
    const deviceForm = ref({
      type_name: '',
      unit_count: 1,
      description: '',
      units: []
    })

    // 过滤后的设备类型列表
    const filteredDeviceTypes = computed(() => {
      if (!searchQuery.value) return deviceTypes.value
      const query = searchQuery.value.toLowerCase()
      return deviceTypes.value.filter(type => 
        type.type_name.toLowerCase().includes(query) ||
        type.description.toLowerCase().includes(query)
      )
    })

    // 加载设备类型列表
    const loadDeviceTypes = async () => {
      try {
        const response = await deviceConfigApi.getAllTypes()
        deviceTypes.value = response.data
      } catch (error) {
        ElMessage.error('加载设备类型失败')
      }
    }

    // 搜索处理
    const handleSearch = () => {
      // 使用计算属性自动过滤
    }

    // 显示添加对话框
    const showAddDialog = () => {
      isEdit.value = false
      deviceForm.value = {
        type_name: '',
        unit_count: 1,
        description: '',
        units: ['DI']
      }
      dialogVisible.value = true
    }

    // 编辑处理
    const handleEdit = (row) => {
      isEdit.value = true
      deviceForm.value = {
        id: row.id,
        type_name: row.type_name,
        unit_count: row.unit_count,
        description: row.description,
        units: [...row.units]
      }
      dialogVisible.value = true
    }

    // 删除处理
    const handleDelete = async (row) => {
      try {
        await ElMessageBox.confirm(
          `确定要删除设备类型"${row.type_name}"吗？`,
          '警告',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )
        
        await deviceConfigApi.deleteType(row.id)
        ElMessage.success('删除成功')
        loadDeviceTypes()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('删除失败')
        }
      }
    }

    // 提交表单
    const handleSubmit = async () => {
      try {
        if (isEdit.value) {
          await deviceConfigApi.updateType(deviceForm.value.id, deviceForm.value)
          ElMessage.success('更新成功')
        } else {
          await deviceConfigApi.createType(deviceForm.value)
          ElMessage.success('添加成功')
        }
        dialogVisible.value = false
        loadDeviceTypes()
      } catch (error) {
        ElMessage.error(isEdit.value ? '更新失败' : '添加失败')
      }
    }

    onMounted(loadDeviceTypes)

    return {
      deviceTypes,
      searchQuery,
      dialogVisible,
      isEdit,
      deviceForm,
      filteredDeviceTypes,
      handleSearch,
      showAddDialog,
      handleEdit,
      handleDelete,
      handleSubmit
    }
  }
}
</script>

<style scoped>
.device-config {
  padding: 20px;
}

.operation-bar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.unit-config {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.unit-config span {
  width: 80px;
  margin-right: 10px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 