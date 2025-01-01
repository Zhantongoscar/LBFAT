<template>
  <div class="test-execution">
    <!-- 测试设备状态（可收纳） -->
    <el-card class="box-card mb-20">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span>测试设备状态</span>
            <el-tag type="info" class="ml-10">
              {{ filteredOnlineDevices.length }}/{{ devices.length }}
            </el-tag>
          </div>
          <el-button
            type="text"
            @click="isDevicesPanelCollapsed = !isDevicesPanelCollapsed"
          >
            <el-icon :size="16">
              <ArrowDown v-if="!isDevicesPanelCollapsed" />
              <ArrowRight v-else />
            </el-icon>
            {{ isDevicesPanelCollapsed ? '展开' : '收起' }}
          </el-button>
        </div>
      </template>

      <el-collapse-transition>
        <div v-show="!isDevicesPanelCollapsed" class="device-status-panel">
          <!-- 在线设备区域 -->
          <div class="devices-section online-section">
            <div class="section-header">
              <el-tag type="success" size="small">在线设备</el-tag>
              <div class="section-controls">
                <el-select v-model="onlineDeviceType" placeholder="设备类型" size="small" clearable>
                  <el-option label="全部" value="" />
                  <el-option v-for="type in deviceTypes" :key="type" :label="type" :value="type" />
                </el-select>
                <el-pagination
                  v-if="filteredOnlineDevices.length > pageSize"
                  :current-page="onlineCurrentPage"
                  :page-size="pageSize"
                  :total="filteredOnlineDevices.length"
                  layout="prev, pager, next"
                  small
                  @current-change="handleOnlinePageChange"
                />
              </div>
            </div>
            <div class="devices-grid">
              <div
                v-for="device in paginatedOnlineDevices"
                :key="device.id"
                class="device-item online"
                @click="showDeviceDetails(device)"
              >
                <el-tooltip
                  :content="'信号强度: ' + device.rssi + ' dBm'"
                  placement="top"
                >
                  <div class="device-icon">
                    <el-icon :size="20">
                      <Monitor v-if="device.type === 'EDB'" />
                      <Cpu v-if="device.type === 'CPU'" />
                      <Connection v-else />
                    </el-icon>
                    <span class="device-name">{{ device.name }}</span>
                    <div class="signal-indicator" :class="getSignalLevel(device.rssi)"></div>
                  </div>
                </el-tooltip>
              </div>
              <div v-if="filteredOnlineDevices.length === 0" class="empty-tip">
                暂无在线设备
              </div>
            </div>
          </div>

          <!-- 离线设备区域 -->
          <div class="devices-section offline-section">
            <div class="section-header">
              <el-tag type="danger" size="small">离线设备</el-tag>
              <div class="section-controls">
                <el-select v-model="offlineDeviceType" placeholder="设备类型" size="small" clearable>
                  <el-option label="全部" value="" />
                  <el-option v-for="type in deviceTypes" :key="type" :label="type" :value="type" />
                </el-select>
                <el-pagination
                  v-if="filteredOfflineDevices.length > pageSize"
                  :current-page="offlineCurrentPage"
                  :page-size="pageSize"
                  :total="filteredOfflineDevices.length"
                  layout="prev, pager, next"
                  small
                  @current-change="handleOfflinePageChange"
                />
              </div>
            </div>
            <div class="devices-grid">
              <div
                v-for="device in paginatedOfflineDevices"
                :key="device.id"
                class="device-item offline"
                @click="showDeviceDetails(device)"
              >
                <el-tooltip content="设备离线" placement="top">
                  <div class="device-icon">
                    <el-icon :size="20">
                      <Monitor v-if="device.type === 'EDB'" />
                      <Cpu v-if="device.type === 'CPU'" />
                      <Connection v-else />
                    </el-icon>
                    <span class="device-name">{{ device.name }}</span>
                  </div>
                </el-tooltip>
              </div>
              <div v-if="filteredOfflineDevices.length === 0" class="empty-tip">
                暂无离线设备
              </div>
            </div>
          </div>
        </div>
      </el-collapse-transition>
    </el-card>

    <!-- 测试实例列表面板 -->
    <el-card class="box-card mb-20">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-button
              type="text"
              @click="isInstancesPanelCollapsed = !isInstancesPanelCollapsed"
            >
              <el-icon>
                <component :is="isInstancesPanelCollapsed ? 'ArrowRight' : 'ArrowDown'" />
              </el-icon>
              <span>测试实例列表</span>
            </el-button>
            <el-tag type="info" class="ml-10">
              {{ testInstances.length }}
            </el-tag>
            <template v-if="isInstancesPanelCollapsed && currentInstance">
              <el-divider direction="vertical" />
              <span class="active-instance">当前测试：{{ currentInstance.product_sn }}</span>
              <el-tag 
                :type="getInstanceStatusType(currentInstance.status)" 
                size="small" 
                class="ml-10"
              >
                {{ getInstanceStatusText(currentInstance.status) }}
              </el-tag>
            </template>
          </div>
          <div class="header-right">
            <el-button type="primary" size="small" @click="handleCreate">
              新建测试实例
            </el-button>
          </div>
        </div>
      </template>

      <el-collapse-transition>
        <div v-show="!isInstancesPanelCollapsed">
          <el-table
            :data="testInstances"
            style="width: 100%"
            border
            @row-click="handleRowClick"
          >
            <el-table-column
              prop="product_sn"
              label="产品序列号"
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
              width="200"
              fixed="right"
            >
              <template #default="{ row }">
                <el-button
                  v-if="canEdit(row)"
                  type="primary"
                  link
                  @click="handleEdit(row)"
                >
                  编辑
                </el-button>
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

          <!-- 测试实例详情工作区 -->
          <div v-if="selectedInstance" class="instance-details-workspace mt-20">
            <h3>测试实例详情</h3>
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
                {{ formatDateTime(selectedInstance.startTime) || '-' }}
              </el-descriptions-item>
              <el-descriptions-item label="结束时间">
                {{ formatDateTime(selectedInstance.endTime) || '-' }}
              </el-descriptions-item>
            </el-descriptions>

            <div class="mt-20">
              <h4>测试项列表</h4>
              <el-table :data="selectedInstance.items" border>
                <el-table-column prop="name" label="测试项" min-width="180" />
                <el-table-column prop="status" label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag :type="getItemStatusType(row.status)">
                      {{ getItemStatusText(row.status) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="result" label="结果" width="100">
                  <template #default="{ row }">
                    <el-tag :type="getResultType(row.result)" v-if="row.result">
                      {{ getResultText(row.result) }}
                    </el-tag>
                    <span v-else>-</span>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </div>
        </div>
      </el-collapse-transition>
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

    <!-- 实例详情对话框 -->
    <el-dialog
      v-model="instanceDetailsVisible"
      title="测试实例详情"
      width="800px"
    >
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
          {{ formatDateTime(selectedInstance.startTime) || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="结束时间">
          {{ formatDateTime(selectedInstance.endTime) || '-' }}
        </el-descriptions-item>
      </el-descriptions>

      <div class="mt-20">
        <h4>测试项列表</h4>
        <el-table :data="selectedInstance.items" border>
          <el-table-column prop="name" label="测试项" min-width="180" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getItemStatusType(row.status)">
                {{ getItemStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="result" label="结果" width="100">
            <template #default="{ row }">
              <el-tag :type="getResultType(row.result)" v-if="row.result">
                {{ getResultText(row.result) }}
              </el-tag>
              <span v-else>-</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
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

    <!-- 编辑相关 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑测试实例"
      width="500px"
      destroy-on-close
    >
      <el-form
        ref="editFormRef"
        :model="editForm"
        :rules="editRules"
        label-width="100px"
      >
        <el-form-item label="真值表" prop="truth_table_id">
          <el-select
            v-model="editForm.truth_table_id"
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
            v-model="editForm.product_sn"
            placeholder="请输入产品序列号"
          />
        </el-form-item>
        <el-form-item label="操作员" prop="operator">
          <el-input
            v-model="editForm.operator"
            placeholder="请输入操作员"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitEdit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { Monitor, Cpu, Connection, ArrowDown, ArrowRight } from '@element-plus/icons-vue'
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
  ResultStatus
} from '@/api/testInstance'
import { getTruthTables } from '@/api/truthTable'

export default {
  name: 'TestExecution',
  components: {
    Monitor,
    Cpu,
    Connection,
    ArrowDown,
    ArrowRight
  },
  setup() {
    // 设备面板收纳状态
    const isDevicesPanelCollapsed = ref(true)

    // 模拟设备数据
    const devices = ref([
      { 
        id: 1, 
        name: 'EDB-1', 
        type: 'EDB', 
        serialNumber: 'EDB001', 
        online: true, 
        rssi: -65, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 2, 
        name: 'EDB-2', 
        type: 'EDB', 
        serialNumber: 'EDB002', 
        online: true, 
        rssi: -75, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 3, 
        name: 'CPU-1', 
        type: 'CPU', 
        serialNumber: 'CPU001', 
        online: false, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 4, 
        name: 'EDB-3', 
        type: 'EDB', 
        serialNumber: 'EDB003', 
        online: true, 
        rssi: -85, 
        lastUpdateTime: new Date() 
      },
      { 
        id: 5, 
        name: 'EDB-4', 
        type: 'EDB', 
        serialNumber: 'EDB004', 
        online: false, 
        lastUpdateTime: new Date() 
      }
    ])

    // 计算属性：在线设备
    const onlineDevices = computed(() => devices.value.filter(d => d.online))
    
    // 计算属性：离线设备
    const offlineDevices = computed(() => devices.value.filter(d => !d.online))

    // 设备统计
    const onlineCount = computed(() => onlineDevices.value.length)
    const totalCount = computed(() => devices.value.length)

    // 设备详情对话框
    const deviceDetailsVisible = ref(false)
    const selectedDevice = ref(null)

    // 方法：切换设备面板显示状态
    const toggleDevicesPanel = () => {
      isDevicesPanelCollapsed.value = !isDevicesPanelCollapsed.value
    }

    // 方法：显示设备详情
    const showDeviceDetails = (device) => {
      selectedDevice.value = device
      deviceDetailsVisible.value = true
    }

    // 方法：获取信号强度等级
    const getSignalLevel = (rssi) => {
      if (rssi >= -65) return 'signal-excellent'
      if (rssi >= -75) return 'signal-good'
      if (rssi >= -85) return 'signal-fair'
      return 'signal-poor'
    }

    // 方法：获取信号强度文本
    const getSignalLevelText = (rssi) => {
      if (rssi >= -65) return '优秀'
      if (rssi >= -75) return '良好'
      if (rssi >= -85) return '一般'
      return '较差'
    }

    // 方法：获取信号强度标签类型
    const getSignalLevelType = (rssi) => {
      if (rssi >= -65) return 'success'
      if (rssi >= -75) return ''
      if (rssi >= -85) return 'warning'
      return 'danger'
    }

    // 方法：格式化日期时间
    const formatDateTime = (date) => {
      if (!date) return ''
      return new Date(date).toLocaleString()
    }

    // 分页和筛选相关
    const pageSize = ref(50) // 每页显示50个设备
    const onlineCurrentPage = ref(1)
    const offlineCurrentPage = ref(1)
    const onlineDeviceType = ref('')
    const offlineDeviceType = ref('')

    // 设备类型列表
    const deviceTypes = computed(() => {
      const types = new Set(devices.value.map(d => d.type))
      return Array.from(types)
    })

    // 过滤后的设备列表
    const filteredOnlineDevices = computed(() => {
      let filtered = onlineDevices.value
      if (onlineDeviceType.value) {
        filtered = filtered.filter(d => d.type === onlineDeviceType.value)
      }
      return filtered
    })

    const filteredOfflineDevices = computed(() => {
      let filtered = offlineDevices.value
      if (offlineDeviceType.value) {
        filtered = filtered.filter(d => d.type === offlineDeviceType.value)
      }
      return filtered
    })

    // 分页后的设备列表
    const paginatedOnlineDevices = computed(() => {
      const start = (onlineCurrentPage.value - 1) * pageSize.value
      const end = start + pageSize.value
      return filteredOnlineDevices.value.slice(start, end)
    })

    const paginatedOfflineDevices = computed(() => {
      const start = (offlineCurrentPage.value - 1) * pageSize.value
      const end = start + pageSize.value
      return filteredOfflineDevices.value.slice(start, end)
    })

    // 分页处理方法
    const handleOnlinePageChange = (page) => {
      onlineCurrentPage.value = page
    }

    const handleOfflinePageChange = (page) => {
      offlineCurrentPage.value = page
    }

    // 测试实例相关
    const testInstances = ref([])
    const instanceDetailsVisible = ref(false)
    const selectedInstance = ref(null)

    // 获取测试实例列表
    const fetchTestInstances = async () => {
      try {
        const response = await getTestInstances()
        testInstances.value = response.data
      } catch (error) {
        ElMessage.error('获取测试实例列表失败')
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

    // 显示实例详情
    const showInstanceDetails = (instance) => {
      selectedInstance.value = instance
      instanceDetailsVisible.value = true
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

    // 页面加载时获取测试实例列表
    onMounted(() => {
      fetchTestInstances()
      fetchTruthTables()
    })

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
            await createTestInstance({
              truth_table_id: createForm.value.truth_table_id,
              product_sn: createForm.value.product_sn,
              operator: createForm.value.operator
            })
            ElMessage.success('创建测试实例成功')
            createDialogVisible.value = false
            await fetchTestInstances()
          } catch (error) {
            console.error('创建测试实例失败:', error)
            ElMessage.error('创建测试实例失败')
          }
        }
      })
    }

    const isInstancesPanelCollapsed = ref(false)
    
    // 当前测试实例（优先显示正在执行的实例，如果没有则显示第一个）
    const currentInstance = computed(() => {
      return testInstances.value.find(instance => instance.status === TestStatus.RUNNING) || 
             testInstances.value[0]
    })

    // 编辑相关
    const editDialogVisible = ref(false)
    const editForm = ref({
      id: '',
      truth_table_id: '',
      product_sn: '',
      operator: 'root'
    })
    const editFormRef = ref()

    // 判断是否可以编辑
    const canEdit = (instance) => {
      return instance.status === TestStatus.PENDING
    }

    // 处理编辑
    const handleEdit = (instance) => {
      editDialogVisible.value = true
      editForm.value = {
        id: instance.id,
        truth_table_id: instance.truth_table_id,
        product_sn: instance.product_sn,
        operator: instance.operator
      }
    }

    // 提交编辑
    const submitEdit = async () => {
      if (!editFormRef.value) return
      
      await editFormRef.value.validate(async (valid) => {
        if (valid) {
          try {
            await updateTestInstance(editForm.value.id, {
              truth_table_id: editForm.value.truth_table_id,
              product_sn: editForm.value.product_sn,
              operator: editForm.value.operator
            })
            ElMessage.success('更新测试实例成功')
            editDialogVisible.value = false
            await fetchTestInstances()
          } catch (error) {
            console.error('更新测试实例失败:', error)
            ElMessage.error('更新测试实例失败')
          }
        }
      })
    }

    const editRules = {
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
    const handleRowClick = (row) => {
      selectedInstance.value = row
    }

    return {
      isDevicesPanelCollapsed,
      devices,
      onlineDevices,
      offlineDevices,
      onlineCount,
      totalCount,
      deviceDetailsVisible,
      selectedDevice,
      toggleDevicesPanel,
      showDeviceDetails,
      getSignalLevel,
      getSignalLevelText,
      getSignalLevelType,
      formatDateTime,
      pageSize,
      onlineCurrentPage,
      offlineCurrentPage,
      onlineDeviceType,
      offlineDeviceType,
      deviceTypes,
      filteredOnlineDevices,
      filteredOfflineDevices,
      paginatedOnlineDevices,
      paginatedOfflineDevices,
      handleOnlinePageChange,
      handleOfflinePageChange,
      // 测试实例相关
      testInstances,
      instanceDetailsVisible,
      selectedInstance,
      startInstance,
      abortInstance,
      showInstanceDetails,
      getInstanceStatusType,
      getInstanceStatusText,
      getItemStatusType,
      getItemStatusText,
      getResultType,
      getResultText,
      getTestProgress,
      getProgressStatus,
      canStart,
      canAbort,
      canEdit,
      handleEdit,
      editDialogVisible,
      editForm,
      editFormRef,
      editRules,
      submitEdit,
      truthTables,
      createDialogVisible,
      createForm,
      createRules,
      createFormRef,
      handleCreate,
      submitCreate,
      isInstancesPanelCollapsed,
      currentInstance,
      canDelete,
      handleDelete,
      handleRowClick
    }
  }
}
</script>

<style scoped>
.test-execution {
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

.header-left {
  display: flex;
  align-items: center;
}

.ml-10 {
  margin-left: 10px;
}

.mb-20 {
  margin-bottom: 20px;
}

/* 设备状态面板样式 */
.device-status-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-top: 10px;
}

.devices-section {
  background-color: #fff;
  border-radius: 4px;
  padding: 15px;
}

.online-section {
  border: 1px solid #e1f3d8;
  background-color: #f0f9eb;
}

.offline-section {
  border: 1px solid #fde2e2;
  background-color: #fef0f0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.section-controls {
  display: flex;
  gap: 10px;
  align-items: center;
}

.devices-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 10px;
  padding: 10px;
}

.device-item {
  padding: 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
  text-align: center;
}

.device-icon {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.device-name {
  font-size: 11px;
  color: #606266;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.signal-indicator {
  position: absolute;
  top: -2px;
  right: -2px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.empty-tip {
  text-align: center;
  color: #909399;
  padding: 20px;
  width: 100%;
}

/* 信号强度指示器颜色 */
.signal-excellent {
  background-color: #67c23a;
}

.signal-good {
  background-color: #409eff;
}

.signal-fair {
  background-color: #e6a23c;
}

.signal-poor {
  background-color: #f56c6c;
}

.mt-20 {
  margin-top: 20px;
}

.header-right {
  margin-left: auto;
}

.active-instance {
  margin-left: 10px;
  color: #606266;
  font-size: 14px;
}

.instance-details-workspace {
  background-color: #f5f7fa;
  border-radius: 4px;
  padding: 20px;
  margin-top: 20px;
}

.instance-details-workspace h3 {
  margin: 0 0 20px 0;
  color: #303133;
}

.instance-details-workspace h4 {
  margin: 20px 0 15px 0;
  color: #303133;
}
</style> 