<template>
  <div class="device-list">
    <!-- 订阅的Topic列表 -->
    <div class="topic-list-section">
      <el-card class="box-card">
        <template #header>
          <div class="card-header">
            <span>订阅的Topic列表</span>
          </div>
        </template>
        <el-table :data="subscribedTopics" style="width: 100%" size="small" :border="true">
          <el-table-column prop="topic" label="Topic" />
          <el-table-column prop="subscribeTime" label="订阅时间" width="180" align="center" />
        </el-table>
      </el-card>
    </div>

    <div class="header">
      <h1>设备管理</h1>
      <div class="header-actions">
        <el-button type="primary" @click="showAddDialog">添加设备</el-button>
        <el-button @click="loadDevices" :loading="loading">刷新</el-button>
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
            {{ scope.row.status === 'online' ? '在线' : '离线' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="updated_at" label="最后更新时间">
        <template #default="scope">
          {{ new Date(scope.row.updated_at).toLocaleString() }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="danger" link @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加/编辑设备对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑设备' : '添加设备'"
      width="600px"
    >
      <el-form :model="deviceForm" label-width="100px" ref="deviceFormRef" :rules="rules">
        <el-form-item label="项目名称" prop="project_name">
          <el-select v-model="deviceForm.project_name" placeholder="请选择项目" style="width: 100%">
            <el-option
              v-for="project in projects"
              :key="project.project_name"
              :label="project.project_name"
              :value="project.project_name"
            />
            <template #prefix>
              <el-button link type="primary" @click="handleAddProject">
                <el-icon><Plus /></el-icon> 新建项目
              </el-button>
            </template>
          </el-select>
        </el-form-item>
        
        <el-form-item label="模块类型" prop="module_type">
          <el-select v-model="deviceForm.module_type" placeholder="请选择模块类型" style="width: 100%">
            <el-option
              v-for="type in deviceTypes"
              :key="type.type_name"
              :label="type.type_name"
              :value="type.type_name"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="序列号" prop="serial_number">
          <el-input v-model="deviceForm.serial_number" placeholder="请输入序列号" />
        </el-form-item>
        
        <el-form-item label="描述">
          <el-input
            v-model="deviceForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入设备描述"
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 添加项目对话框 -->
    <el-dialog
      v-model="projectDialog.visible"
      title="新建项目"
      width="500px"
    >
      <el-form :model="projectDialog.form" label-width="100px" ref="projectFormRef" :rules="projectRules">
        <el-form-item label="项目名称" prop="project_name">
          <el-input v-model="projectDialog.form.project_name" placeholder="请输入项目名称" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="projectDialog.form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入项目描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="projectDialog.visible = false">取消</el-button>
          <el-button type="primary" @click="handleProjectSubmit" :loading="projectDialog.submitting">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../utils/api'
import deviceConfigApi from '../api/deviceConfig'
import projectApi from '../api/project'
import { Plus } from '@element-plus/icons-vue'

const devices = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const submitting = ref(false)
const deviceTypes = ref([])
const deviceFormRef = ref(null)
const projects = ref([])
const subscribedTopics = ref([])

const deviceForm = ref({
  project_name: '',
  module_type: '',
  serial_number: '',
  description: ''
})

const rules = {
  project_name: [
    { required: true, message: '请输入项目名称', trigger: 'blur' }
  ],
  module_type: [
    { required: true, message: '请选择模块类型', trigger: 'change' }
  ],
  serial_number: [
    { required: true, message: '请输入序列号', trigger: 'blur' }
  ]
}

const projectDialog = ref({
  visible: false,
  submitting: false,
  form: {
    project_name: '',
    description: ''
  }
})

const projectFormRef = ref(null)

const projectRules = {
  project_name: [
    { required: true, message: '请输入项目名称', trigger: 'blur' }
  ]
}

// 加载设备类型列表
const loadDeviceTypes = async () => {
  try {
    const response = await deviceConfigApi.getAllTypes()
    if (response?.data?.code === 200) {
      deviceTypes.value = response.data.data
    }
  } catch (error) {
    console.error('加载设备类型失败:', error)
  }
}

// 加载设备列表
const loadDevices = async () => {
  try {
    loading.value = true
    const response = await api.get('/devices')
    if (response?.data?.code === 200) {
      devices.value = response.data.data
    }
  } catch (error) {
    console.error('加载设备列表失败:', error)
    ElMessage.error('加载设备列表失败')
  } finally {
    loading.value = false
  }
}

// 显示添加对话框
const showAddDialog = () => {
  isEdit.value = false
  deviceForm.value = {
    project_name: '',
    module_type: '',
    serial_number: '',
    description: ''
  }
  dialogVisible.value = true
}

// 编辑设备
const handleEdit = (row) => {
  isEdit.value = true
  deviceForm.value = { ...row }
  dialogVisible.value = true
}

// 删除设备
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除设备 "${row.project_name} - ${row.module_type} - ${row.serial_number}" 吗？`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await api.delete(`/devices/${row.id}`)
    ElMessage.success('删除成功')
    loadDevices()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除设备失败:', error)
      ElMessage.error('删除设备失败')
    }
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!deviceFormRef.value) return
  
  try {
    await deviceFormRef.value.validate()
    submitting.value = true
    
    if (isEdit.value) {
      await api.put(`/devices/${deviceForm.value.id}`, deviceForm.value)
      ElMessage.success('更新成功')
    } else {
      await api.post('/devices', deviceForm.value)
      ElMessage.success('添加成功')
    }
    
    dialogVisible.value = false
    loadDevices()
  } catch (error) {
    if (error?.message) {
      console.error('提交表单失败:', error)
      ElMessage.error(error.message)
    }
  } finally {
    submitting.value = false
  }
}

// 加载项目列表
const loadProjects = async () => {
  try {
    const response = await projectApi.getAllProjects()
    if (response?.data?.code === 200) {
      projects.value = response.data.data
    }
  } catch (error) {
    console.error('加载项目列表失败:', error)
  }
}

// 显示新建项目对话框
const handleAddProject = () => {
  projectDialog.value.form = {
    project_name: '',
    description: ''
  }
  projectDialog.value.visible = true
}

// 提交新建项目
const handleProjectSubmit = async () => {
  if (!projectFormRef.value) return
  
  try {
    await projectFormRef.value.validate()
    projectDialog.value.submitting = true
    
    await projectApi.createProject(projectDialog.value.form)
    ElMessage.success('项目创建成功')
    
    projectDialog.value.visible = false
    await loadProjects()
  } catch (error) {
    console.error('创建项目失败:', error)
    ElMessage.error(error.message || '创建项目失败')
  } finally {
    projectDialog.value.submitting = false
  }
}

// 加载订阅的Topic列表
const loadSubscribedTopics = () => {
  subscribedTopics.value = [
    {
      topic: 'lb_test/+/+/status',
      subscribeTime: new Date().toLocaleString()
    },
    {
      topic: 'lb_test/+/+/+/response',
      subscribeTime: new Date().toLocaleString()
    }
  ]
}

onMounted(() => {
  loadDevices()
  loadDeviceTypes()
  loadProjects()
  loadSubscribedTopics()
})
</script>

<style scoped>
.device-list {
  padding: 20px;
}

.topic-list-section {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header span {
  font-size: 14px;
  font-weight: 500;
  color: #606266;
}

:deep(.el-card__header) {
  padding: 12px 16px;
  border-bottom: 1px solid #ebeef5;
  background-color: #f5f7fa;
}

:deep(.el-card__body) {
  padding: 12px;
}

:deep(.el-table) {
  --el-table-border-color: #ebeef5;
  --el-table-header-background-color: #f5f7fa;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h1 {
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
