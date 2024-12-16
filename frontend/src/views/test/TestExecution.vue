<template>
  <div class="test-execution">
    <!-- 产品信息 -->
    <el-card class="box-card mb-20">
      <template #header>
        <div class="card-header">
          <span>产品信息</span>
        </div>
      </template>
      <el-form :model="productInfo" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="产品型号">
              <el-input v-model="productInfo.model" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="序列号">
              <el-input v-model="productInfo.serialNumber" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="固件版本">
              <el-input v-model="productInfo.firmwareVersion" disabled />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

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

    <!-- 测试控制区域 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>测试控制</span>
          <div class="header-actions">
            <el-select
              v-model="selectedTemplate"
              placeholder="请选择真值表"
              :disabled="testStatus !== 'ready'"
              style="width: 200px; margin-right: 10px"
              @change="loadTemplate"
            >
              <el-option
                v-for="template in templateList"
                :key="template.id"
                :label="template.name"
                :value="template"
              >
                <span>{{ template.name }}</span>
                <span class="template-info">
                  (图纸：{{ template.drawingNo }}, 版本：V{{ template.version }})
                </span>
              </el-option>
            </el-select>
            <el-button-group>
              <el-button
                type="primary"
                @click="startTest"
                :disabled="testStatus !== 'ready' || !selectedTemplate"
              >
                开始测试
              </el-button>
              <el-button
                v-if="testStatus === 'running'"
                type="warning"
                @click="pauseTest"
              >
                暂停
              </el-button>
              <el-button
                v-if="testStatus === 'paused'"
                type="success"
                @click="resumeTest"
              >
                继续
              </el-button>
              <el-button
                v-if="testStatus !== 'ready'"
                type="danger"
                @click="stopTest"
              >
                停止
              </el-button>
            </el-button-group>
          </div>
        </div>
      </template>

      <!-- 测试进度和结果显示 -->
      <div v-if="selectedTemplate" class="test-content">
        <!-- 测试组列表 -->
        <el-collapse v-model="expandedGroups">
          <el-collapse-item
            v-for="group in testGroups"
            :key="group.testId"
            :name="group.testId"
          >
            <template #title>
              <div class="group-header">
                <span class="test-id">测试ID {{ group.testId }}: {{ group.description }}</span>
                <el-tag 
                  :type="group.level === 1 ? 'danger' : 'info'"
                  size="small"
                >
                  {{ group.level === 1 ? '安全类' : '普通类' }}
                </el-tag>
                <span class="item-count">({{ group.items.length }}个测试项)</span>
              </div>
            </template>

            <!-- 测试项表格 -->
            <el-table :data="group.items" border style="width: 100%">
              <el-table-column label="设备" prop="deviceId" width="120" />
              <el-table-column label="单元" prop="unitId" width="120" />
              <el-table-column label="类型" prop="unitType" width="100" />
              <el-table-column label="设定/期望值" width="150">
                <template #default="{ row }">
                  {{ row.setValue !== null ? row.setValue : row.expectedValue }}
                </template>
              </el-table-column>
              <el-table-column label="实际值" width="150">
                <template #default="{ row }">
                  <span v-if="row.actualValue !== undefined">{{ row.actualValue }}</span>
                  <span v-else>-</span>
                </template>
              </el-table-column>
              <el-table-column label="状态" width="100">
                <template #default="{ row }">
                  <el-tag
                    v-if="row.status"
                    :type="row.status === 'pass' ? 'success' : row.status === 'fail' ? 'danger' : 'info'"
                  >
                    {{ row.status === 'pass' ? '通过' : row.status === 'fail' ? '失败' : '等待' }}
                  </el-tag>
                  <span v-else>-</span>
                </template>
              </el-table-column>
              <el-table-column label="描述" prop="description" />
            </el-table>
          </el-collapse-item>
        </el-collapse>

        <!-- 当前测试项详情 -->
        <div v-if="currentTestItem" class="current-test-info">
          <h3>当前测试项</h3>
          <div class="test-item-details">
            <p><strong>设备：</strong>{{ currentTestItem.deviceId }}</p>
            <p><strong>单元：</strong>{{ currentTestItem.unitId }}</p>
            <p><strong>描述：</strong>{{ currentTestItem.description }}</p>
            <p v-if="currentTestItem.errorMessage">
              <strong>错误信息：</strong>{{ currentTestItem.errorMessage }}
            </p>
            <p v-if="currentTestItem.faultDetails">
              <strong>故障详情：</strong>
              <pre>{{ currentTestItem.faultDetails }}</pre>
            </p>
          </div>
        </div>
      </div>
      <el-empty v-else description="请选择真值表" />
    </el-card>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { Monitor, Cpu, Connection, ArrowDown, ArrowRight } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getTruthTables, getTruthTable } from '@/api/truthTable'
import {
  createTestInstance,
  startTest,
  updateTestItemStatus,
  completeTest,
  getTestInstance,
  TestStatus,
  TestResult,
  ExecutionStatus,
  ResultStatus
} from '@/api/testInstance'

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
    // 产品信息
    const productInfo = ref({
      model: 'EDB-TEST-001',
      serialNumber: 'SN20240001',
      firmwareVersion: 'v1.0.0'
    })

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

    // 真值表相关
    const selectedTemplate = ref(null)
    const templateList = ref([])

    // 获取真值表列表
    const fetchTemplateList = async () => {
      try {
        const res = await getTruthTables()
        if (res.data && res.data.data) {
          templateList.value = res.data.data.map(table => ({
            id: table.id,
            name: table.name,
            drawingNo: table.drawing_number,
            version: table.version
          }))

          // 如果有上次选择的真值表，自动选中
          const savedTemplate = localStorage.getItem('selectedTruthTable')
          if (savedTemplate) {
            const template = JSON.parse(savedTemplate)
            const found = templateList.value.find(t => t.id === template.id)
            if (found) {
              selectedTemplate.value = found
              await loadTemplate(found)
            }
          }
        } else {
          console.warn('获取真值表列表数据格式不正确:', res)
          templateList.value = []
        }
      } catch (error) {
        console.error('获取真值表列表失败:', error)
        ElMessage.error('获取真值表列表失败')
      }
    }

    // 加载真值表
    const loadTemplate = async (template) => {
      if (!template) return
      selectedTemplate.value = template
      
      try {
        const res = await getTruthTable(template.id)
        if (res.data && res.data.data) {
          const tableData = res.data.data
          
          // 转换测试组数据格式
          testGroups.value = tableData.groups.map(group => ({
            testId: group.test_id,
            level: group.level,
            description: group.description,
            items: group.items.map(item => ({
              deviceId: item.device_id || 'device1', // 临时使用默认值
              unitId: item.unit_id || 'DI1', // 临时使��默认值
              unitType: item.unit_type || 'DI', // 临时使用默认值
              expectedValue: item.expected_result,
              setValue: item.action,
              enabled: true,
              description: item.description || '',
              errorMessage: '操作未达到预期结果',
              faultDetails: '请检查设备连接和控制回路'
            }))
          }))
        } else {
          console.warn('获取真值表详情数据格式不正确:', res)
          testGroups.value = []
        }
      } catch (error) {
        console.error('加载真值表失败:', error)
        ElMessage.error('加载真值表失败')
        testGroups.value = []
      }
    }

    // 测试组和测试项
    const testGroups = ref([])
    const currentTestGroup = ref(null)
    const currentTestItem = ref(null)
    const testStatus = ref(TestStatus.PENDING)
    const testResults = ref([])

    // 测试实例相关
    const currentInstance = ref(null)

    // 创建测试实例
    const createInstance = async () => {
      if (!selectedTemplate.value) {
        ElMessage.warning('请先选择真值表')
        return
      }

      try {
        const instanceData = {
          truth_table_id: selectedTemplate.value.id,
          product_sn: productInfo.value.serialNumber,
          product_model: productInfo.value.model,
          firmware_version: productInfo.value.firmwareVersion,
          operator: 'admin' // TODO: 从用户状态获取
        }

        const res = await createTestInstance(instanceData)
        currentInstance.value = res.data.data.instanceId
        testStatus.value = TestStatus.PENDING

        // 获取实例详情
        await loadInstanceDetails()

        ElMessage.success('测试实例创建成功')
      } catch (error) {
        console.error('创建测试实例失败:', error)
        ElMessage.error('创建测试实例失败')
      }
    }

    // 加载实例详情
    const loadInstanceDetails = async () => {
      if (!currentInstance.value) return

      try {
        const res = await getTestInstance(currentInstance.value)
        const instanceData = res.data.data

        // 更新测试组和测试项数据
        testGroups.value = instanceData.items.reduce((groups, item) => {
          const group = groups.find(g => g.id === item.group_id)
          if (group) {
            group.items.push(item)
          } else {
            groups.push({
              id: item.group_id,
              description: item.group_description,
              items: [item]
            })
          }
          return groups
        }, [])

        testStatus.value = instanceData.status
      } catch (error) {
        console.error('加载测试实例详情失败:', error)
        ElMessage.error('加载测试实例详情失败')
      }
    }

    // 开始测试
    const startTest = async () => {
      if (!currentInstance.value) {
        await createInstance()
      }

      try {
        await startTest(currentInstance.value)
        testStatus.value = TestStatus.RUNNING
        currentTestGroup.value = testGroups.value[0]
        currentTestItem.value = currentTestGroup.value?.items[0]
        
        // 开始执行第一个测试项
        await executeTestItem(currentTestItem.value)
      } catch (error) {
        console.error('开始测试失败:', error)
        ElMessage.error('开始测试失败')
      }
    }

    // 执行测试项
    const executeTestItem = async (item) => {
      if (!item) return

      try {
        // 更新测试项状态为执行中
        await updateTestItemStatus(currentInstance.value, item.id, {
          execution_status: ExecutionStatus.RUNNING,
          result_status: ResultStatus.UNKNOWN
        })

        // TODO: 实现具体的测试逻辑
        // 1. 根据点位类型执行不同的操作
        // 2. 处理测试结果
        // 3. 更新测试项状态

        // 模拟测试执行
        setTimeout(async () => {
          const result = Math.random() > 0.5 ? ResultStatus.PASS : ResultStatus.FAIL
          
          await updateTestItemStatus(currentInstance.value, item.id, {
            execution_status: ExecutionStatus.COMPLETED,
            result_status: result,
            actual_value: result === ResultStatus.PASS ? item.expected_value : 'unexpected value'
          })

          // 执行下一个测试项
          const nextItem = getNextTestItem(item)
          if (nextItem) {
            currentTestItem.value = nextItem
            await executeTestItem(nextItem)
          } else {
            // 所有测试项执行完成
            await completeTest(currentInstance.value, TestResult.PASS)
            testStatus.value = TestStatus.COMPLETED
          }
        }, 2000)
      } catch (error) {
        console.error('执行测试项失败:', error)
        ElMessage.error('执行测试项失败')
      }
    }

    // 获取下一个测试项
    const getNextTestItem = (currentItem) => {
      const currentGroup = testGroups.value.find(g => g.id === currentItem.group_id)
      const currentIndex = currentGroup.items.findIndex(i => i.id === currentItem.id)
      
      // 当前组内还有测试项
      if (currentIndex < currentGroup.items.length - 1) {
        return currentGroup.items[currentIndex + 1]
      }
      
      // 查找下一个组的第一个测试项
      const currentGroupIndex = testGroups.value.findIndex(g => g.id === currentGroup.id)
      if (currentGroupIndex < testGroups.value.length - 1) {
        const nextGroup = testGroups.value[currentGroupIndex + 1]
        return nextGroup.items[0]
      }
      
      return null
    }

    // 暂停测试
    const pauseTest = async () => {
      // TODO: 实现暂停逻辑
      testStatus.value = TestStatus.PAUSED
    }

    // 继续测试
    const resumeTest = async () => {
      // TODO: 实现继续逻辑
      testStatus.value = TestStatus.RUNNING
    }

    // 停止测试
    const stopTest = async () => {
      try {
        await ElMessageBox.confirm(
          '确定要停止当前测试吗？已执行的测试结果将被保存。',
          '警告',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )

        await completeTest(currentInstance.value, TestResult.FAIL)
        testStatus.value = TestStatus.ABORTED
        currentTestGroup.value = null
        currentTestItem.value = null
      } catch (error) {
        if (error !== 'cancel') {
          console.error('停止测试失败:', error)
          ElMessage.error('停止测试失败')
        }
      }
    }

    onMounted(() => {
      fetchTemplateList()
    })

    return {
      productInfo,
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
      selectedTemplate,
      templateList,
      testGroups,
      currentTestGroup,
      currentTestItem,
      testStatus,
      testResults,
      loadTemplate,
      startTest,
      pauseTest,
      resumeTest,
      stopTest,
      currentInstance,
      TestStatus,
      TestResult,
      ExecutionStatus,
      ResultStatus
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

.header-actions {
  display: flex;
  gap: 10px;
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

.test-content {
  margin-top: 20px;
}

.group-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.test-id {
  font-weight: bold;
  font-size: 14px;
  color: #303133;
}

.item-count {
  color: #909399;
  font-size: 12px;
}

.template-info {
  margin-left: 10px;
  color: #909399;
  font-size: 12px;
}

.current-test-info {
  margin-top: 20px;
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.test-item-details {
  margin-top: 10px;
}

.test-item-details p {
  margin: 5px 0;
}

.test-item-details pre {
  margin: 5px 0;
  padding: 10px;
  background-color: #fff;
  border-radius: 4px;
  font-family: monospace;
  white-space: pre-wrap;
}
</style> 