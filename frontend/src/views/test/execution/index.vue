<template>
  <div class="test-execution">
    <!-- 测试设备状态区域 -->
    <el-card class="status-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-button 
              type="text" 
              @click="isDeviceStatusCollapsed = !isDeviceStatusCollapsed"
            >
              <el-icon>
                <component :is="isDeviceStatusCollapsed ? 'ArrowRight' : 'ArrowDown'" />
              </el-icon>
              测试设备状态 {{ deviceCount }}/{{ totalDevices }}
            </el-button>
          </div>
        </div>
      </template>

      <el-collapse-transition>
        <div v-show="!isDeviceStatusCollapsed">
          <div class="device-status">
            <div class="status-section">
              <h3>在线设备</h3>
              <div class="device-grid">
                <div v-for="device in onlineDevices" :key="device.id" class="device-item">
                  <el-tag type="success">
                    {{ device.project_name }}-{{ device.module_type }}-{{ device.serial_number }}
                  </el-tag>
                </div>
              </div>
            </div>

            <div class="status-section">
              <h3>离线设备</h3>
              <div class="device-grid">
                <div v-for="device in offlineDevices" :key="device.id" class="device-item">
                  <el-tag type="info">
                    {{ device.project_name }}-{{ device.module_type }}-{{ device.serial_number }}
                  </el-tag>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-collapse-transition>
    </el-card>

    <!-- 测试实例列表区域 -->
    <el-card class="instance-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-button 
              type="text" 
              @click="isInstanceListCollapsed = !isInstanceListCollapsed"
            >
              <el-icon>
                <component :is="isInstanceListCollapsed ? 'ArrowRight' : 'ArrowDown'" />
              </el-icon>
              测试实例列表 {{ instanceCount }}
            </el-button>
          </div>
          <el-button type="primary" @click="handleCreate">新建测试实例</el-button>
        </div>
      </template>

      <el-collapse-transition>
        <div v-show="!isInstanceListCollapsed">
          <!-- 原有的测试实例列表内容 -->
          // ... existing instance list code ...
        </div>
      </el-collapse-transition>
    </el-card>

    <!-- 创建测试实例对话框 -->
    <el-dialog
      v-model="createDialogVisible"
      title="新建测试实例"
      width="500px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <el-form
        ref="createFormRef"
        :model="createForm"
        label-width="100px"
        :rules="{
          truth_table_id: [{ required: true, message: '请选择真值表', trigger: 'change' }],
          product_sn: [{ required: true, message: '请输入产品序列号', trigger: 'blur' }],
          operator: [{ required: true, message: '请输入操作员', trigger: 'blur' }]
        }"
      >
        <el-form-item label="真值表" prop="truth_table_id">
          <el-select v-model="createForm.truth_table_id" placeholder="请选择真值表">
            <el-option
              v-for="table in truthTables"
              :key="table.id"
              :label="table.name"
              :value="table.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="产品序列号" prop="product_sn">
          <el-input v-model="createForm.product_sn" placeholder="请输入产品序列号" />
        </el-form-item>
        <el-form-item label="操作员" prop="operator">
          <el-input v-model="createForm.operator" placeholder="请输入操作员" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="createDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitCreate" :loading="loadingTestItems">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 测试实例详情区域 -->
    // ... existing instance detail code ...
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ArrowDown, ArrowRight } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getTestInstances, createTestInstance, createInstanceItems } from '@/api/testInstance'
import { getTruthTables } from '@/api/truthTable'

// 折叠状态控制
const isDeviceStatusCollapsed = ref(true)  // 默认折叠
const isInstanceListCollapsed = ref(true)   // 默认折叠

// 测试实例相关
const testInstances = ref([])
const selectedInstance = ref(null)
const truthTables = ref([])
const createDialogVisible = ref(false)
const createForm = ref({
  truth_table_id: '',
  product_sn: '',
  operator: 'root'
})
const createFormRef = ref()
const loadingTestItems = ref(false)

// 获取测试实例列表
const fetchTestInstances = async () => {
  try {
    const response = await getTestInstances()
    console.log('获取测试实例列表响应:', response)
    if (response?.data) {
      testInstances.value = response.data
      console.log('更新后的测试实例列表:', testInstances.value)
    } else {
      console.warn('获取测试实例列表响应为空')
      testInstances.value = []
    }
  } catch (error) {
    console.error('获取测试实例列表失败:', error)
    ElMessage.error('获取测试实例列表失败: ' + (error.response?.data?.message || error.message))
    testInstances.value = []
  }
}

// 获取真值表列表
const fetchTruthTables = async () => {
  try {
    console.log('开始获取真值表列表...')
    const response = await getTruthTables()
    console.log('获取真值表响应:', response)
    
    if (response?.data?.data) {
      truthTables.value = response.data.data
    } else {
      console.warn('真值表数据为空')
      truthTables.value = []
    }
  } catch (error) {
    console.error('获取真值表列表失败:', error)
    ElMessage.error('获取真值表列表失败: ' + (error.response?.data?.message || error.message))
    truthTables.value = []
  }
}

// 创建测试实例
const handleCreate = async () => {
  try {
    createDialogVisible.value = true
    
    // 获取真值表列表
    console.log('当前真值表列表:', truthTables.value)
    if (truthTables.value.length === 0) {
      console.log('真值表列表为空，开始获取...')
      await fetchTruthTables()
    }
    
    // 设置默认值
    createForm.value = {
      truth_table_id: truthTables.value.length > 0 ? truthTables.value[0].id : '',
      product_sn: '',
      operator: 'root'
    }
    console.log('设置创建表单默认值:', createForm.value)
    
  } catch (error) {
    console.error('打开创建对话框失败:', error)
    ElMessage.error('初始化失败: ' + (error.response?.data?.message || error.message))
    createDialogVisible.value = false
  }
}

// 提交创建表单
const submitCreate = async () => {
  if (!createFormRef.value) return
  
  // 如果没有选择真值表，使用第一个可用的真值表
  if (!createForm.value.truth_table_id && truthTables.value.length > 0) {
    createForm.value.truth_table_id = truthTables.value[0].id
  }
  
  await createFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        loadingTestItems.value = true
        
        // 1. 创建测试实例
        console.log('开始创建测试实例:', createForm.value)
        const createResponse = await createTestInstance(createForm.value)
        console.log('测试实例创建响应:', createResponse)
        
        ElMessage.success('创建成功')
        createDialogVisible.value = false
        
        // 2. 刷新获取实例列表
        console.log('刷新测试实例列表...')
        await fetchTestInstances()
        
        // 3. 获取新创建的实例
        const newInstance = testInstances.value[0]
        console.log('获取到新创建的实例:', newInstance)
        
        // 4. 创建测试项并等待完成
        console.log('开始为实例创建测试项...')
        await createInstanceItems(newInstance.id)
        console.log('测试项创建完成')

        // 5. 再次获取实例列表
        console.log('再次刷新测试实例列表...')
        await fetchTestInstances()
        
        // 6. 设置选中实例
        const updatedInstance = testInstances.value.find(instance => instance.id === newInstance.id)
        if (updatedInstance) {
          selectedInstance.value = updatedInstance
        }
        
        // 重置表单
        createForm.value = {
          truth_table_id: '',
          product_sn: '',
          operator: 'root'
        }
      } catch (error) {
        console.error('操作失败:', error)
        ElMessage.error('操作失败: ' + (error.response?.data?.message || error.message))
      } finally {
        loadingTestItems.value = false
      }
    }
  })
}

// 初始化
onMounted(async () => {
  await fetchTestInstances()
  await fetchTruthTables()
})

// 导出变量和方法
defineExpose({
  testInstances,
  selectedInstance,
  truthTables,
  createDialogVisible,
  createForm,
  createFormRef,
  loadingTestItems,
  handleCreate,
  submitCreate
})
</script>

<style scoped>
.test-execution {
  padding: 20px;
}

.status-card,
.instance-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}

.device-status {
  margin-top: 10px;
}

.status-section {
  margin-bottom: 20px;
}

.device-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 10px;
  margin-top: 10px;
}

.device-item {
  display: flex;
  align-items: center;
}
</style> 