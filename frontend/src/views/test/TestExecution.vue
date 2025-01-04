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

    <!-- 测试实例详情面板 -->
    <el-card class="box-card mb-20" v-if="selectedInstance">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span>测试实例详情</span>
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
          <div class="header-right">
            <el-button-group>
              <el-button
                type="success"
                size="small"
                @click="handleCreateInstanceItems"
              >
                创建项
              </el-button>
              <el-button
                type="info"
                size="small"
                @click="refreshTestItems"
              >
                刷新
              </el-button>
            </el-button-group>
          </div>
        </div>
      </template>

      <el-table
        :data="filteredTestItems"
        row-key="id"
        border
        v-loading="loadingTestItems"
        :tree-props="{
          children: 'items',
          hasChildren: 'hasChildren'
        }"
      >
        <el-table-column prop="name" label="名称" min-width="200">
          <template #default="{ row }">
            <span>{{ row.name || row.description || '-' }}</span>
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
        
        <el-table-column label="测试值" width="150">
          <template #default="{ row }">
            <div>实际值：{{ row.actual_value || '-' }}</div>
            <div>预期值：{{ row.expected_values || '-' }}</div>
          </template>
        </el-table-column>
        
        <el-table-column label="时间" width="340">
          <template #default="{ row }">
            <div>开始：{{ formatDateTime(row.start_time) || '-' }}</div>
            <div>结束：{{ formatDateTime(row.end_time) || '-' }}</div>
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
  ResultStatus,
  getOrCreateTestItems,
  createInstanceItems
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

    // 测试项详情对话框
    const itemDetailsVisible = ref(false)
    const selectedItem = ref(null)

    // 处理表格行点击
    const showItemDetails = (item) => {
      selectedItem.value = item
      itemDetailsVisible.value = true
    }

    // 实例操作项列表
    const filteredTestItems = computed(() => {
      if (!selectedInstance.value || !selectedInstance.value.items) return []
      console.log('当前测试项列表:', selectedInstance.value.items)
      const items = selectedInstance.value.items || []
      if (itemStatusFilter.value) {
        return items.filter(item => item.execution_status === itemStatusFilter.value)
      }
      return items
    })

    // 状态筛选选项
    const itemStatusOptions = [
      { value: ExecutionStatus.PENDING, label: '待执行' },
      { value: ExecutionStatus.RUNNING, label: '执行中' },
      { value: ExecutionStatus.COMPLETED, label: '已完成' },
      { value: ExecutionStatus.SKIPPED, label: '已跳过' },
      { value: ExecutionStatus.TIMEOUT, label: '超时' }
    ]

    // 状态筛选
    const itemStatusFilter = ref('')

    // 判断是否可以执行测试项
    const canExecuteItem = (item) => {
      return item.execution_status === ExecutionStatus.PENDING
    }

    // 处理执行测试项
    const handleExecuteItem = (item) => {
      // 处理逻辑
    }

    // 判断是否可以跳过测试项
    const canSkipItem = (item) => {
      return item.execution_status === ExecutionStatus.PENDING
    }

    // 处理跳过测试项
    const handleSkipItem = (item) => {
      // 处理逻辑
    }

    // 加载测试项相关
    const loadingTestItems = ref(false)

    // 创建测试项
    const handleCreateInstanceItems = async () => {
      if (!selectedInstance.value) {
        ElMessage.warning('请先选择一个测试实例')
        return
      }
      
      loadingTestItems.value = true
      try {
        const response = await createInstanceItems(selectedInstance.value.id)
        // 根据返回的状态码判断是创建成功还是已存在
        if (response.data.code === 201) {
          ElMessage.success('测试项创建成功')
        } else if (response.data.code === 200) {
          ElMessage.info('测试项已存在')
        }
        // 获取最新的测试项列表
        const itemsResponse = await getOrCreateTestItems(selectedInstance.value.id)
        console.log('获取到的测试项数据:', itemsResponse.data)
        if (itemsResponse.data && itemsResponse.data.data) {
          selectedInstance.value.items = itemsResponse.data.data.items
        }
      } catch (error) {
        console.error('创建测试项失败:', error)
        ElMessage.error('创建测试项失败')
      } finally {
        loadingTestItems.value = false
      }
    }

    // 刷新实例操作项列表
    const refreshTestItems = async () => {
      if (!selectedInstance.value) {
        ElMessage.warning('请先选择一个测试实例')
        return
      }
      
      loadingTestItems.value = true
      try {
        const response = await getOrCreateTestItems(selectedInstance.value.id)
        console.log('刷新获取到的测试项数据:', response.data)
        if (response.data && response.data.data) {
          selectedInstance.value.items = response.data.data.items || []
        }
      } catch (error) {
        console.error('刷新测试项失败:', error)
        ElMessage.error('刷新失败')
      } finally {
        loadingTestItems.value = false
      }
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
      handleRowClick,
      itemDetailsVisible,
      selectedItem,
      showItemDetails,
      filteredTestItems,
      itemStatusOptions,
      itemStatusFilter,
      canExecuteItem,
      handleExecuteItem,
      canSkipItem,
      handleSkipItem,
      loadingTestItems,
      handleCreateInstanceItems,
      refreshTestItems
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

  .device-status-panel {
    .devices-section {
      margin-bottom: 20px;

      &:last-child {
        margin-bottom: 0;
      }

      .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;

        .section-controls {
          display: flex;
          align-items: center;
          gap: 10px;
        }
      }

      .devices-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 10px;

        .device-item {
          padding: 10px;
          border: 1px solid #dcdfe6;
          border-radius: 4px;
          cursor: pointer;
          transition: all 0.3s;

          &:hover {
            background-color: #f5f7fa;
          }

          &.online {
            border-color: #67c23a;
          }

          &.offline {
            border-color: #f56c6c;
          }

          .device-icon {
            display: flex;
            align-items: center;
            gap: 8px;

            .device-name {
              flex: 1;
              overflow: hidden;
              text-overflow: ellipsis;
              white-space: nowrap;
            }

            .signal-indicator {
              width: 8px;
              height: 8px;
              border-radius: 50%;

              &.signal-excellent {
                background-color: #67c23a;
              }

              &.signal-good {
                background-color: #409eff;
              }

              &.signal-fair {
                background-color: #e6a23c;
              }

              &.signal-poor {
                background-color: #f56c6c;
              }
            }
          }
        }

        .empty-tip {
          grid-column: 1 / -1;
          text-align: center;
          color: #909399;
          padding: 20px;
        }
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
}
</style> 