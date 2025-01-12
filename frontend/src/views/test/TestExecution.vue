<template>
  <div class="test-execution">
    <!-- 测试设备状态 -->
    <el-collapse v-model="activeCollapse">
      <el-collapse-item name="deviceStatus">
        <template #title>
          <div class="collapse-title">
            <span>测试设备状态</span>
            <span class="device-count">{{ onlineCount }}/{{ devices.length }}</span>
            <div class="device-status-progress">
              <el-progress
                :percentage="(onlineCount / devices.length) * 100"
                :format="() => ''"
                :stroke-width="15"
                status="success"
                class="status-progress"
              />
            </div>
          </div>
        </template>
        <div class="device-status">
          <div class="status-content">
            <!-- 在线设备 -->
            <div class="status-section">
              <h4>在线设备</h4>
              <div class="online-devices">
                <el-tooltip
                  v-for="device in onlineDevices"
                  :key="device.id"
                  :content="`${device.module_type}-${device.serial_number}`"
                  placement="top"
                >
                  <div class="device-icon online">
                    <el-icon><Monitor /></el-icon>
                  </div>
                </el-tooltip>
              </div>
            </div>
            
            <!-- 离线设备 -->
            <div class="status-section">
              <h4>离线设备</h4>
              <div class="offline-devices">
                <div v-for="device in offlineDevices" :key="device.id" class="device-item offline">
                  <el-icon><Monitor /></el-icon>
                  <span class="device-name">{{ device.module_type }}-{{ device.serial_number }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-collapse-item>
    </el-collapse>

    <!-- 测试实例列表面板 -->
    <el-card class="box-card mb-20">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span>测试实例列表</span>
            <el-tag type="info" class="ml-10">
              {{ testInstances.length }}
            </el-tag>
          </div>
          <div class="header-right">
            <el-button type="primary" size="small" @click="handleCreate">
              新建测试实例
            </el-button>
          </div>
        </div>
      </template>

      <el-table
        :data="testInstances"
        style="width: 100%"
        border
        @row-click="handleRowClick"
      >
        <el-table-column
          prop="product_sn"
          label="测试实例名称"
          min-width="180"
        />
        <el-table-column
          prop="status"
          label="状态"
          width="100"
        >
          <template #default="{ row }">
            <el-tag :type="getInstanceStatusType(row.status)">
              {{ getInstanceStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          prop="result"
          label="结果"
          width="100"
        >
          <template #default="{ row }">
            <el-tag :type="getResultType(row.result)" v-if="row.result">
              {{ getResultText(row.result) }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column
          label="进度"
          width="200"
        >
          <template #default="{ row }">
            <el-progress
              :percentage="getTestProgress(row)"
              :status="getProgressStatus(row)"
            />
          </template>
        </el-table-column>
        <el-table-column
          label="时间"
          width="340"
        >
          <template #default="{ row }">
            <div>开始：{{ formatDateTime(row.start_time) || '-' }}</div>
            <div>结束：{{ formatDateTime(row.end_time) || '-' }}</div>
          </template>
        </el-table-column>
        <el-table-column
          label="操作"
          width="100"
          fixed="right"
        >
          <template #default="{ row }">
            <el-button
              v-if="canDelete(row)"
              type="danger"
              link
              @click="handleDelete(row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 测试状态面板 -->
    <el-card class="box-card mb-20" v-if="selectedInstance">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span>测试状态</span>
            <el-tag type="info" class="ml-10">{{ selectedInstance.product_sn }}</el-tag>
            <el-tag 
              :type="getInstanceStatusType(selectedInstance.status)" 
              size="small" 
              class="ml-10"
            >
              {{ getInstanceStatusText(selectedInstance.status) }}
            </el-tag>
          </div>
          <div class="header-right">
            <el-button-group>
              <el-button 
                type="primary" 
                size="small"
                v-if="canStart(selectedInstance)"
                @click="startInstance(selectedInstance)"
              >
                开始测试
              </el-button>
              <el-button 
                type="warning" 
                size="small"
                v-if="canAbort(selectedInstance)"
                @click="abortInstance(selectedInstance)"
              >
                中止测试
              </el-button>
            </el-button-group>
          </div>
        </div>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="产品序列号">{{ selectedInstance.product_sn }}</el-descriptions-item>
        <el-descriptions-item label="操作员">{{ selectedInstance.operator }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getInstanceStatusType(selectedInstance.status)">
            {{ getInstanceStatusText(selectedInstance.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="结果" v-if="selectedInstance.result">
          <el-tag :type="getResultType(selectedInstance.result)">
            {{ getResultText(selectedInstance.result) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="开始时间">
          {{ formatDateTime(selectedInstance.start_time) || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="结束时间">
          {{ formatDateTime(selectedInstance.end_time) || '-' }}
        </el-descriptions-item>
      </el-descriptions>

      <div class="progress-info mt-20">
        <div class="progress-header">
          <span>测试进度</span>
          <span class="progress-percentage">{{ getTestProgress(selectedInstance) }}%</span>
        </div>
        <el-progress 
          :percentage="getTestProgress(selectedInstance)"
          :status="getProgressStatus(selectedInstance)"
          :stroke-width="20"
        />
      </div>
    </el-card>

    <!-- 实例操作项列表面板 -->
    <el-card class="box-card" v-if="selectedInstance">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span>实例操作项列表</span>
            <el-tag type="info" class="ml-10">{{ selectedInstance.product_sn }}</el-tag>
          </div>
        </div>
      </template>

      <div v-loading="loadingTestItems">
        <div v-for="group in filteredTestItems" :key="group.id" class="test-group">
          <div class="group-header">
            <div class="group-title">
              {{ group.description }}
              <el-tag size="small" type="info" class="ml-10">
                {{ group.items.length }} 项
              </el-tag>
            </div>
            <div class="group-level">
              <el-tag size="small" type="success">
                Level {{ group.level }}
              </el-tag>
            </div>
          </div>

          <el-table :data="group.items" border>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="test_item_id" label="测试项ID" width="80" />
            <el-table-column prop="testItem.test_group_id" label="测试组ID" width="80" />
            <el-table-column prop="testItem.device_id" label="设备ID" width="80" />
            <el-table-column prop="testItem.point_index" label="通道" width="80" />
            <el-table-column prop="testItem.name" label="测试项名称" min-width="120" />
            <el-table-column prop="testItem.input_values" label="设定值" width="80" />
            <el-table-column prop="testItem.expected_values" label="预期值" width="80" />
            <el-table-column label="测试值" width="150">
              <template #default="{ row }">
                <div>实际值：{{ row.actual_value || '-' }}</div>
                <div>预期值：{{ row.expected_values || '-' }}</div>
              </template>
            </el-table-column>
            <el-table-column prop="execution_status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getItemStatusType(row.execution_status)">
                  {{ getItemStatusText(row.execution_status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="result_status" label="结果" width="100">
              <template #default="{ row }">
                <el-tag :type="getResultType(row.result_status)">
                  {{ getResultText(row.result_status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button
                  v-if="canExecuteItem(row)"
                  type="primary"
                  link
                  @click="handleExecuteItem(row)"
                >
                  执行
                </el-button>
                <el-button
                  v-if="canSkipItem(row)"
                  type="warning"
                  link
                  @click="handleSkipItem(row)"
                >
                  跳过
                </el-button>
                <el-button
                  type="info"
                  link
                  @click="showItemDetails(row)"
                >
                  详情
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </el-card>

    <!-- 设备详情对话框 -->
    <el-dialog
      v-model="deviceDetailsVisible"
      title="设备详情"
      width="500px"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="设备名称">{{ selectedDevice?.name }}</el-descriptions-item>
        <el-descriptions-item label="设备类型">{{ selectedDevice?.type }}</el-descriptions-item>
        <el-descriptions-item label="序列号">{{ selectedDevice?.serialNumber }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="selectedDevice?.online ? 'success' : 'danger'">
            {{ selectedDevice?.online ? '在线' : '离线' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="信号强度" v-if="selectedDevice?.online">
          {{ selectedDevice?.rssi }} dBm
          <el-tag :type="getSignalLevelType(selectedDevice?.rssi)" class="ml-10">
            {{ getSignalLevelText(selectedDevice?.rssi) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="最后更新时间">
          {{ formatDateTime(selectedDevice?.lastUpdateTime) }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 创建测试实例对话框 -->
    <el-dialog
      v-model="createDialogVisible"
      title="新建测试实例"
      width="500px"
      destroy-on-close
    >
      <el-form
        ref="createFormRef"
        :model="createForm"
        :rules="createRules"
        label-width="100px"
      >
        <el-form-item label="真值表" prop="truth_table_id">
          <el-select
            v-model="createForm.truth_table_id"
            placeholder="请选择真值表"
            style="width: 100%"
          >
            <el-option
              v-for="table in truthTables"
              :key="table.id"
              :label="table.name"
              :value="table.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="产品序列号" prop="product_sn">
          <el-input
            v-model="createForm.product_sn"
            placeholder="请输入产品序列号"
          />
        </el-form-item>
        <el-form-item label="操作员" prop="operator">
          <el-input
            v-model="createForm.operator"
            disabled
            placeholder="当前登录用户"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitCreate">确定</el-button>
      </template>
    </el-dialog>

    <!-- 测试项详情对话框 -->
    <el-dialog
      v-model="itemDetailsVisible"
      title="测试项详情"
      width="600px"
    >
      <el-descriptions :column="2" border v-if="selectedItem">
        <el-descriptions-item label="测试项名称">{{ selectedItem.name }}</el-descriptions-item>
        <el-descriptions-item label="所属测试组">{{ selectedItem.test_group?.description }}</el-descriptions-item>
        <el-descriptions-item label="执行状态">
          <el-tag :type="getItemStatusType(selectedItem.execution_status)">
            {{ getItemStatusText(selectedItem.execution_status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="测试结果">
          <el-tag :type="getResultType(selectedItem.result_status)">
            {{ getResultText(selectedItem.result_status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="输入值">{{ selectedItem.input_values }}</el-descriptions-item>
        <el-descriptions-item label="预期值">{{ selectedItem.expected_values }}</el-descriptions-item>
        <el-descriptions-item label="实际值">{{ selectedItem.actual_value || '-' }}</el-descriptions-item>
        <el-descriptions-item label="超时时间">{{ selectedItem.timeout }}ms</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ formatDateTime(selectedItem.start_time) || '-' }}</el-descriptions-item>
        <el-descriptions-item label="结束时间">{{ formatDateTime(selectedItem.end_time) || '-' }}</el-descriptions-item>
        <el-descriptions-item label="错误信息" :span="2">
          {{ selectedItem.error_message || '-' }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { Monitor } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  getTestInstances, 
  createTestInstance, 
  startTest, 
  completeTest,
  deleteTestInstance,
  TestStatus,
  TestResult,
  ExecutionStatus,
  ResultStatus,
  getOrCreateTestItems,
  createInstanceItems
} from '@/api/testInstance'
import { getTruthTables } from '@/api/truthTable'

export default {
  name: 'TestExecution',
  components: {
    Monitor
  },
  setup() {
    // 设备面板收纳状态
    const activeCollapse = ref([])

    // 设备数据
    const devices = ref([])
    const selectedDevices = ref([])
    const loading = ref(false)

    // 计算属性：在线设备
    const onlineDevices = computed(() => {
      return devices.value.filter(device => device.status === 'online')
    })
    
    // 计算属性：离线设备
    const offlineDevices = computed(() => {
      return devices.value.filter(device => device.status !== 'online')
    })

    // 在线设备数量
    const onlineCount = computed(() => onlineDevices.value.length)

    // 加载设备列表
    const loadDevices = async () => {
      try {
        loading.value = true
        const response = await fetch('/api/devices')
        if (response.ok) {
          const data = await response.json()
          devices.value = data.data || []
        } else {
          devices.value = []
        }
      } catch (error) {
        console.error('加载设备列表失败:', error)
        ElMessage.error('加载设备列表失败')
        devices.value = []
      } finally {
        loading.value = false
      }
    }

    // 测试实例相关
    const testInstances = ref([])
    const selectedInstance = ref(null)
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

    // 真值表数据
    const truthTables = ref([])
    
    // 获取真值表列表
    const fetchTruthTables = async () => {
      try {
        const response = await getTruthTables()
        truthTables.value = response.data.data || []
      } catch (error) {
        console.error('获取真值表列表失败:', error)
        ElMessage.error('获取真值表列表失败')
      }
    }

    // 开始测试实例
    const startInstance = async (instance) => {
      try {
        await startTest(instance.id)
        ElMessage.success('开始测试')
        await fetchTestInstances()
      } catch (error) {
        ElMessage.error('开始测试失败')
      }
    }

    // 中止测试实例
    const abortInstance = async (instance) => {
      try {
        await ElMessageBox.confirm('确定要中止测试吗？')
        await completeTest(instance.id, TestResult.UNKNOWN)
        ElMessage.success('已中止测试')
        await fetchTestInstances()
      } catch (error) {
        if (error !== 'cancel') {
          ElMessage.error('中止测试失败')
        }
      }
    }

    // 状态相关方法
    const getInstanceStatusType = (status) => {
      const types = {
        [TestStatus.PENDING]: 'info',
        [TestStatus.RUNNING]: 'warning',
        [TestStatus.COMPLETED]: 'success',
        [TestStatus.ABORTED]: 'danger'
      }
      return types[status] || 'info'
    }

    const getInstanceStatusText = (status) => {
      const texts = {
        [TestStatus.PENDING]: '待执行',
        [TestStatus.RUNNING]: '执行中',
        [TestStatus.COMPLETED]: '已完成',
        [TestStatus.ABORTED]: '已中止'
      }
      return texts[status] || '未知'
    }

    const getItemStatusType = (status) => {
      const types = {
        [ExecutionStatus.PENDING]: 'info',
        [ExecutionStatus.RUNNING]: 'warning',
        [ExecutionStatus.COMPLETED]: 'success',
        [ExecutionStatus.SKIPPED]: '',
        [ExecutionStatus.TIMEOUT]: 'danger'
      }
      return types[status] || 'info'
    }

    const getItemStatusText = (status) => {
      const texts = {
        [ExecutionStatus.PENDING]: '待执行',
        [ExecutionStatus.RUNNING]: '执行中',
        [ExecutionStatus.COMPLETED]: '已完成',
        [ExecutionStatus.SKIPPED]: '已跳过',
        [ExecutionStatus.TIMEOUT]: '超时'
      }
      return texts[status] || '未知'
    }

    const getResultType = (result) => {
      const types = {
        [ResultStatus.PASS]: 'success',
        [ResultStatus.FAIL]: 'danger',
        [ResultStatus.ERROR]: 'danger',
        [ResultStatus.UNKNOWN]: 'info'
      }
      return types[result] || 'info'
    }

    const getResultText = (result) => {
      const texts = {
        [ResultStatus.PASS]: '通过',
        [ResultStatus.FAIL]: '失败',
        [ResultStatus.ERROR]: '错误',
        [ResultStatus.UNKNOWN]: '未知'
      }
      return texts[result] || '未知'
    }

    // 获取测试进度
    const getTestProgress = (instance) => {
      if (!instance.items || instance.items.length === 0) return 0
      const completed = instance.items.filter(
        item => item.status === ExecutionStatus.COMPLETED
      ).length
      return Math.round((completed / instance.items.length) * 100)
    }

    // 获取进度条状态
    const getProgressStatus = (instance) => {
      if (instance.status === TestStatus.ABORTED) return 'exception'
      if (instance.result === ResultStatus.FAIL) return 'exception'
      if (instance.status === TestStatus.COMPLETED) return 'success'
      return ''
    }

    // 判断是否可以开始测试
    const canStart = (instance) => {
      return instance.status === TestStatus.PENDING
    }

    // 判断是否可以中止测试
    const canAbort = (instance) => {
      return instance.status === TestStatus.RUNNING
    }

    // 创建测试实例相关
    const createDialogVisible = ref(false)
    const createForm = ref({
      truth_table_id: '',
      product_sn: '',
      operator: 'root'
    })

    const createRules = {
      truth_table_id: [
        { required: true, message: '请选择真值表', trigger: 'change' }
      ],
      product_sn: [
        { required: true, message: '请输入产品序列号', trigger: 'blur' }
      ],
      operator: [
        { required: true, message: '请输入操作员', trigger: 'blur' }
      ]
    }

    const createFormRef = ref()

    const handleCreate = () => {
      createDialogVisible.value = true
      createForm.value = {
        truth_table_id: '',
        product_sn: '',
        operator: 'root'
      }
    }

    const submitCreate = async () => {
      if (!createFormRef.value) return
      
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

    // 判断是否可以删除
    const canDelete = (instance) => {
      return instance.status === TestStatus.PENDING
    }

    // 处理删除
    const handleDelete = async (instance) => {
      try {
        await ElMessageBox.confirm('确定要删除该测试实例吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        await deleteTestInstance(instance.id)
        ElMessage.success('删除成功')
        await fetchTestInstances()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除测试实例失败:', error)
          ElMessage.error('删除失败')
        }
      }
    }

    // 处理表格行点击
    const handleRowClick = async (row) => {
      // 如果正在加载，不重复请求
      if (loadingTestItems.value) {
        console.log('正在加载中，跳过重复请求')
        return
      }
      
      try {
        console.log('点击测试实例:', row)
        selectedInstance.value = row
        loadingTestItems.value = true
        
        // 使用与创建时相同的加载方式
        console.log('开始获取测试项...')
        await createInstanceItems(row.id)
        await fetchTestInstances()
        
        // 更新选中的实例
        const updatedInstance = testInstances.value.find(instance => instance.id === row.id)
        if (updatedInstance) {
          selectedInstance.value = updatedInstance
          console.log('更新后的选中实例:', selectedInstance.value)
        } else {
          console.warn('未找到更新后的实例')
        }
      } catch (error) {
        console.error('加载测试项失败:', error)
        ElMessage.error('加载测试项失败: ' + (error.response?.data?.message || error.message))
      } finally {
        loadingTestItems.value = false
      }
    }

    // 测试项详情对话框
    const itemDetailsVisible = ref(false)
    const selectedItem = ref(null)

    // 显示测试项详情
    const showItemDetails = (item) => {
      selectedItem.value = item
      itemDetailsVisible.value = true
    }

    // 实例操作项列表
    const filteredTestItems = computed(() => {
      if (!selectedInstance.value || !selectedInstance.value.items) {
        console.log('没有选中实例或测试项')
        return []
      }
      console.log('当前测试项列表:', selectedInstance.value.items)
      
      // 按测试组分组
      const groupedItems = {}
      const items = selectedInstance.value.items || []
      
      items.forEach(item => {
        console.log('处理测试项:', item)
        const groupId = item.test_group_id
        if (!groupedItems[groupId]) {
          groupedItems[groupId] = {
            id: groupId,
            description: item.group?.description || '未知测试组',
            level: item.group?.level || 1,
            sequence: item.group?.sequence || 0,
            items: []
          }
        }
        groupedItems[groupId].items.push(item)
      })
      
      console.log('分组后的测试项:', groupedItems)
      // 转换为数组并排序
      return Object.values(groupedItems).sort((a, b) => a.sequence - b.sequence)
    })

    // 判断是否可以执行测试项
    const canExecuteItem = (item) => {
      return item.execution_status === ExecutionStatus.PENDING
    }

    // 判断是否可以跳过测试项
    const canSkipItem = (item) => {
      return item.execution_status === ExecutionStatus.PENDING
    }

    // 组件挂载时加载数据
    onMounted(async () => {
      try {
        await loadDevices()
        await fetchTestInstances()
        await fetchTruthTables()
      } catch (error) {
        console.error('初始化数据加载失败:', error)
      }
    })

    return {
      // 设备相关
      devices,
      onlineDevices,
      offlineDevices,
      onlineCount,
      loading,
      loadDevices,
      selectedDevices,
      activeCollapse,

      // 测试实例相关
      testInstances,
      selectedInstance,
      truthTables,
      createDialogVisible,
      createForm,
      createRules,
      createFormRef,
      handleCreate,
      submitCreate,
      startInstance,
      abortInstance,
      canStart,
      canAbort,
      canDelete,
      handleDelete,
      handleRowClick,
      getInstanceStatusType,
      getInstanceStatusText,
      getItemStatusType,
      getItemStatusText,
      getResultType,
      getResultText,
      getTestProgress,
      getProgressStatus,

      // 测试项相关
      loadingTestItems,
      filteredTestItems,
      itemDetailsVisible,
      selectedItem,
      showItemDetails,
      canExecuteItem,
      canSkipItem,

      // 格式化方法
      formatDateTime: (date) => {
        if (!date) return ''
        return new Date(date).toLocaleString()
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.test-execution {
  padding: 20px;

  .box-card {
    margin-bottom: 20px;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .header-left {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .header-right {
      display: flex;
      align-items: center;
      gap: 10px;
    }
  }

  .device-status {
    padding: 10px;
  }

  .status-title {
    display: flex;
    align-items: center;
    margin-bottom: 15px;
  }

  .status-content {
    display: flex;
    gap: 20px;
  }

  .status-section {
    flex: 1;

    h4 {
      margin-bottom: 10px;
      color: var(--el-text-color-regular);
      font-size: 14px;
    }
  }

  // 在线设备样式
  .online-devices {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(24px, 1fr));
    gap: 4px;
    max-width: 100%;
    padding: 4px;
    background-color: var(--el-bg-color-page);
    border-radius: 4px;
    
    .device-icon {
      width: 24px;
      height: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 4px;
      background-color: var(--el-color-success-light-9);
      color: var(--el-color-success);
      cursor: pointer;
      transition: all 0.2s;
      
      &:hover {
        background-color: var(--el-color-success-light-8);
        transform: translateY(-2px);
      }
      
      .el-icon {
        font-size: 14px;
      }
    }
  }

  // 离线设备样式
  .offline-devices {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 4px;
    padding: 4px;
    background-color: var(--el-bg-color-page);
    border-radius: 4px;

    .device-item {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 4px 8px;
      border-radius: 4px;
      background-color: var(--el-color-danger-light-9);
      color: var(--el-color-danger);
      font-size: 12px;

      .el-icon {
        font-size: 14px;
      }

      .device-name {
        color: var(--el-text-color-regular);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }
  }

  .progress-info {
    .progress-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;

      .progress-percentage {
        font-size: 16px;
        font-weight: bold;
        color: #409eff;
      }
    }
  }

  .section-controls {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .mb-20 {
    margin-bottom: 20px;
  }

  .mt-20 {
    margin-top: 20px;
  }

  .ml-10 {
    margin-left: 10px;
  }

  .collapse-title {
    display: flex;
    align-items: center;
    gap: 20px;
    width: 100%;
    
    .device-count {
      font-size: 14px;
      color: var(--el-text-color-secondary);
      white-space: nowrap;
      margin-right: 10px;
    }
    
    .device-status-progress {
      flex: 1;
      margin-right: 20px;
      
      .status-progress {
        margin: 0;
        
        :deep(.el-progress-bar__outer) {
          background-color: var(--el-fill-color-darker);
          height: 20px !important;
          border-radius: 4px;
        }
        
        :deep(.el-progress-bar__inner) {
          background-color: var(--el-color-success);
          border-radius: 4px;
        }
      }
    }
  }
}

.test-group {
  margin-bottom: 20px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
}

.group-header {
  padding: 12px 20px;
  background-color: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.group-title {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
}

.group-level {
  font-size: 12px;
  color: #909399;
}

/* 状态标签样式 */
:deep(.el-tag) {
  text-align: center;
  min-width: 60px;
}

/* 表格内容居中 */
:deep(.el-table td) {
  text-align: center;
}

/* 表格头部居中 */
:deep(.el-table th) {
  text-align: center;
  background-color: #f5f7fa;
}
</style> 