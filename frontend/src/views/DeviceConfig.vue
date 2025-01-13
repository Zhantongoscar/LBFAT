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
      :title="'编辑设备类型！'"
      width="800px"
      class="device-type-dialog"
    >
      <el-form :model="deviceForm" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="设备类型">
              <el-input v-model="deviceForm.type_name" placeholder="如：EDB" />
            </el-form-item>
          </el-col>
          <el-col :span="16">
            <el-form-item label="点位数量！">
              <el-input-number 
                v-model="deviceForm.point_count" 
                :min="1" 
                :max="100"
              />
              <el-button 
                type="primary" 
                link 
                @click="showQuickSetDialog"
                style="margin-left: 10px"
              >
                快速设置
              </el-button>
            </el-form-item>
          </el-col>
        </el-row>
        
        <!-- 点位配置列表 -->
        <el-form-item label="点位配置">
          <div class="points-list">
            <div v-for="(point, index) in deviceForm.points" :key="index" class="point-item">
              <el-row :gutter="20">
                <el-col :span="4">
                  <el-input 
                    v-model="point.point_index" 
                    disabled
                    placeholder="序号"
                  />
                </el-col>
                <el-col :span="6">
                  <el-select 
                    v-model="point.point_type" 
                    placeholder="类型" 
                    style="width: 100%"
                    @change="(val) => handlePointTypeChange(index, val)"
                  >
                    <el-option label="DI" value="DI" />
                    <el-option label="DO" value="DO" />
                    <el-option label="AI" value="AI" />
                    <el-option label="AO" value="AO" />
                  </el-select>
                </el-col>
                <el-col :span="6">
                  <el-select 
                    v-model="point.mode" 
                    placeholder="模式" 
                    style="width: 100%"
                  >
                    <el-option label="读取" value="read" />
                    <el-option label="写入" value="write" />
                  </el-select>
                </el-col>
                <el-col :span="8">
                  <el-input 
                    v-model="point.description" 
                    placeholder="点位描述"
                  />
                </el-col>
              </el-row>
            </div>
          </div>
        </el-form-item>

        <el-form-item label="描述">
          <el-input
            v-model="deviceForm.description"
            type="textarea"
            placeholder="如：EDB设备: 20个点位配置 (7DI + 3DO + 7DI + 3DI)"
            :rows="2"
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

    <!-- 快速设置对话框 -->
    <el-dialog
      v-model="quickSetDialog.visible"
      title="快速设置点位"
      width="500px"
    >
      <el-form :model="quickSetDialog.form" label-width="100px">
        <el-form-item label="设置格式">
          <el-input
            v-model="quickSetDialog.form.format"
            placeholder="例如：7DI + 3DO + 7DI + 3DI"
          />
        </el-form-item>
        <div class="quick-set-tips">
          <p>格式说明：</p>
          <ul>
            <li>使用数字+类型的格式，如 7DI</li>
            <li>支持的类型：DI、DO、AI、AO</li>
            <li>使用 + 号分隔不同组</li>
            <li>例如：7DI + 3DO + 7DI + 3DI</li>
          </ul>
        </div>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="quickSetDialog.visible = false">取消</el-button>
          <el-button type="primary" @click="handleQuickSet">确定</el-button>
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
        mode: 'read',
        description: ''
      }]
    })

    // 快速设置对话框
    const quickSetDialog = ref({
      visible: false,
      form: {
        format: ''
      }
    })

    // 处理点位类型变化，自动设置mode
    const handlePointTypeChange = (index, pointType) => {
      const point = deviceForm.value.points[index];
      // DO/AO -> write, DI/AI -> read
      point.mode = ['DO', 'AO'].includes(pointType) ? 'write' : 'read';
    }

    // 更新点位数组
    const updatePoints = (newCount) => {
      console.log('更新点位数组，新数量:', newCount);
      const currentPoints = deviceForm.value.points || [];
      const currentLength = currentPoints.length;
      
      if (newCount > currentLength) {
        // 添加新点位
        for (let i = currentLength; i < newCount; i++) {
          currentPoints.push({
            point_index: i + 1,
            point_type: 'DI',
            point_name: '',
            mode: 'read',
            description: ''
          });
        }
      } else if (newCount < currentLength) {
        // 移除多余点位
        currentPoints.splice(newCount);
      }
      
      deviceForm.value.points = currentPoints;
      console.log('更新后的点位数组:', deviceForm.value.points);
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
          mode: 'read',
          description: ''
        }]
      };
      dialogVisible.value = true;
    }

    // 编辑处理
    const handleEdit = (row) => {
      console.log('开始编辑操作，行数据:', row);
      isEdit.value = true;
      console.log('isEdit设置为:', isEdit.value);
      
      // 确保row.points存在且是数组
      const points = Array.isArray(row.points) ? row.points : [];
      console.log('处理前的点位数据:', points);
      
      deviceForm.value = {
        id: row.id,
        type_name: row.type_name,
        point_count: parseInt(row.point_count) || 1,
        description: row.description || '',
        points: points.map((p, index) => ({
          point_index: index + 1,
          point_type: p.point_type || 'DI',
          point_name: p.point_name || '',
          mode: p.mode || (p.point_type === 'DO' || p.point_type === 'AO' ? 'write' : 'read'),
          description: p.description || ''
        }))
      };
      
      console.log('设置后的表单数据:', deviceForm.value);
      
      // 确保点位数组长度与点位数量匹配
      updatePoints(deviceForm.value.point_count);
      console.log('更新点位后的表单数据:', deviceForm.value);
      
      // 确保对话框显示
      dialogVisible.value = true;
      console.log('对话框显示状态:', dialogVisible.value);
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
        if (!deviceForm.value.points || !deviceForm.value.points.length) {
          ElMessage.warning('请配置点位信息');
          return;
        }

        // 确保点位索引正确
        const formData = {
          ...deviceForm.value,
          points: deviceForm.value.points.map((p, index) => ({
            point_index: index,
            point_type: p.point_type,
            mode: p.mode,
            description: p.description || `${p.point_type}${index}`
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
        await loadDeviceTypes();
      } catch (error) {
        console.error('提交表单错误:', error);
        ElMessage.error(error.message || (isEdit.value ? '更新失败' : '添加失败'));
      }
    }

    // 显示快速设置对话框
    const showQuickSetDialog = () => {
      quickSetDialog.value.visible = true
    }

    // 处理快速设置
    const handleQuickSet = () => {
      const format = quickSetDialog.value.form.format.trim()
      if (!format) {
        ElMessage.warning('请输入设置格式')
        return
      }

      try {
        // 解析格式字符串
        const parts = format.split('+').map(part => part.trim())
        const points = []
        let currentIndex = 0

        parts.forEach(part => {
          const match = part.match(/^(\d+)(DI|DO|AI|AO)$/)
          if (!match) {
            throw new Error(`格式错误: ${part}`)
          }

          const [, count, type] = match
          const mode = ['DO', 'AO'].includes(type) ? 'write' : 'read'  // 根据类型设置mode

          for (let i = 0; i < parseInt(count); i++) {
            points.push({
              point_index: currentIndex + 1,
              point_type: type,
              point_name: `${type}${currentIndex}`,
              mode: mode,  // 添加mode
              description: `${deviceForm.value.type_name}${type}点${currentIndex}`
            })
            currentIndex++
          }
        })

        deviceForm.value.points = points
        deviceForm.value.point_count = points.length
        deviceForm.value.description = format

        quickSetDialog.value.visible = false
        ElMessage.success('设置成功')
      } catch (error) {
        ElMessage.error(error.message || '格式错误')
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
      handleSubmit,
      quickSetDialog,
      showQuickSetDialog,
      handleQuickSet,
      handlePointTypeChange,
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

/* 点位配置样式 */
.points-list {
  max-height: 400px;
  overflow-y: auto;
  padding: 10px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}

.point-item {
  margin-bottom: 10px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.point-item:last-child {
  margin-bottom: 0;
}

.quick-set-tips {
  margin-top: 10px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.quick-set-tips p {
  margin: 0 0 5px 0;
  font-weight: bold;
}

.quick-set-tips ul {
  margin: 0;
  padding-left: 20px;
}

.quick-set-tips li {
  margin: 3px 0;
  color: #606266;
}

/* 设备类型对话框样式 */
:deep(.device-type-dialog) {
  .el-dialog__body {
    padding: 20px 30px;
  }
  
  .el-select {
    width: 100%;
  }
  
  .points-list {
    margin-top: 10px;
  }
  
  .point-item {
    transition: all 0.3s;
  }
  
  .point-item:hover {
    background-color: #ecf5ff;
  }
}
</style> 