<template>
  <div class="device-config">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>设备配置</span>
          <div class="header-actions">
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
        </div>
      </template>

      <!-- 设备类型列表 -->
      <el-table :data="filteredDeviceTypes" style="width: 100%">
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
    </el-card>

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
          <el-input-number v-model="deviceForm.point_count" :min="1" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="deviceForm.description"
            type="textarea"
            :rows="3"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
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
      const currentPoints = deviceForm.value.points || [];
      const newPoints = [];
      
      // 保持现有点位的配置
      for (let i = 0; i < newCount; i++) {
        if (i < currentPoints.length) {
          newPoints.push({
            ...currentPoints[i],
            point_index: i + 1  // 确保 point_index 正确
          });
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
      console.log('更新后的点位配置:', deviceForm.value.points);
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
        console.log('开始加载设备类型...');
        const response = await deviceConfigApi.getAllTypes();
        console.log('API响应:', response);
        
        if (response && response.data && response.data.code === 200) {
          deviceTypes.value = response.data.data;
          console.log('设备类型数据已加载:', deviceTypes.value);
        } else {
          throw new Error(response?.data?.message || '加载设备类型失败');
        }
      } catch (error) {
        console.error('加载设备类型错误:', error);
        ElMessage.error(error.message || '加载设备类型失败');
      }
    }

    // 搜索处理
    const handleSearch = () => {
      // 使用计算属性自动过滤
    }

    // 显示添加对话框
    const showAddDialog = () => {
      isEdit.value = false;
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
      };
      dialogVisible.value = true;
    }

    // 编辑处理
    const handleEdit = (row) => {
      console.log('编辑行数据:', row);
      isEdit.value = true;
      deviceForm.value = {
        id: row.id,
        type_name: row.type_name,
        point_count: parseInt(row.point_count),
        description: row.description,
        points: Array.isArray(row.points) ? row.points.map((p, index) => ({
          ...p,
          point_index: index + 1  // 确保 point_index 正确
        })) : []
      };
      
      // 确保点位数组长度与点位数量匹配
      updatePoints(deviceForm.value.point_count);
      console.log('编辑表单数据:', deviceForm.value);
      dialogVisible.value = true;
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
        // 验证表单数据
        if (!deviceForm.value.type_name.trim()) {
          ElMessage.warning('请输入设备类型名称');
          return;
        }

        // 验证点位配置
        if (!deviceForm.value.points.every(p => p.point_name.trim())) {
          ElMessage.warning('请填写所有点位的名称');
          return;
        }

        // 确保点位索引正确
        const formData = {
          ...deviceForm.value,
          points: deviceForm.value.points.map((p, index) => ({
            ...p,
            point_index: index + 1
          }))
        };

        console.log('提交表单数据:', formData);
        
        if (isEdit.value) {
          await deviceConfigApi.updateType(formData.id, formData);
          ElMessage.success('更新成功');
        } else {
          await deviceConfigApi.createType(formData);
          ElMessage.success('添加成功');
        }
        
        dialogVisible.value = false;
        await loadDeviceTypes(); // 重新加载数据
      } catch (error) {
        console.error('提交表单错误:', error);
        ElMessage.error(error.message || (isEdit.value ? '更新失败' : '添加失败'));
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

.box-card {
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 