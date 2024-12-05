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
      <el-table-column prop="point_count" label="点位数量" width="100" />
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
        <el-form-item label="点位数量">
          <el-input-number v-model="deviceForm.point_count" :min="1" :max="32" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="deviceForm.description"
            type="textarea"
            rows="3"
          />
        </el-form-item>
        <el-form-item label="点位配置">
          <div v-for="i in deviceForm.point_count" :key="i" class="point-config">
            <span>点位 {{ i }}:</span>
            <el-select v-model="deviceForm.points[i-1].point_type">
              <el-option label="DI" value="DI" />
              <el-option label="DO" value="DO" />
              <el-option label="AI" value="AI" />
              <el-option label="AO" value="AO" />
            </el-select>
            <el-input v-model="deviceForm.points[i-1].point_name" placeholder="点位名称" />
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
import { ref, computed, onMounted, watch } from 'vue'
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
      point_count: 1,
      description: '',
      points: [{
        point_index: 1,
        point_type: 'DI',
        point_name: '',
        description: ''
      }]
    })

    // 监听点位数量变化
    const updatePoints = (newCount) => {
      const currentPoints = deviceForm.value.points;
      const newPoints = [];
      
      // 保持现有点位的配置
      for (let i = 0; i < newCount; i++) {
        if (i < currentPoints.length) {
          newPoints.push(currentPoints[i]);
        } else {
          newPoints.push({
            point_index: i + 1,
            point_type: 'DI',
            point_name: '',
            description: ''
          });
        }
      }
      
      deviceForm.value.points = newPoints;
    }

    // 监听点位数量变化
    watch(() => deviceForm.value.point_count, (newCount) => {
      updatePoints(newCount);
    });

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
        console.log('开始加载设备类型...')
        const response = await deviceConfigApi.getAllTypes()
        console.log('API响应:', response)
        
        // 检查响应数据结构
        if (!response || !response.data) {
          throw new Error('无效的响应数据');
        }

        const { code, message, data } = response.data;
        
        if (code === 200 && Array.isArray(data)) {
          deviceTypes.value = data;
          console.log('加载的设备类型:', deviceTypes.value);
        } else {
          throw new Error(message || '加载设备类型失败');
        }
      } catch (error) {
        console.error('加载设备类型错误:', error);
        console.error('错误详情:', {
          message: error.message,
          response: error.response?.data,
          status: error.response?.status
        });
        ElMessage.error(error.message || '加载设备类型失败');
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
        point_count: 1,
        description: '',
        points: [{
          point_index: 1,
          point_type: 'DI',
          point_name: '',
          description: ''
        }]
      }
      dialogVisible.value = true
    }

    // 编辑处理
    const handleEdit = (row) => {
      isEdit.value = true
      deviceForm.value = {
        id: row.id,
        type_name: row.type_name,
        point_count: row.point_count,
        description: row.description,
        points: Array.isArray(row.points) ? row.points : Array(row.point_count).fill(0).map((_, i) => ({
          point_index: i + 1,
          point_type: 'DI',
          point_name: '',
          description: ''
        }))
      }
      // 确保点位数组长度与点位数量匹配
      updatePoints(deviceForm.value.point_count);
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

.point-config {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.point-config span {
  width: 80px;
  margin-right: 10px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 