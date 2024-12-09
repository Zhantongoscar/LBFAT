<template>
  <div class="test-execution">
    <!-- 产品信息 -->
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span class="title">产品信息</span>
        </div>
      </template>
      <el-form :model="productInfo" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="产品序列号">
              <el-input v-model="productInfo.serialNumber" placeholder="请输入产品序列号"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="图纸编号">
              <el-input v-model="productInfo.drawingCode" placeholder="请输入图纸编号"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="测试模板">
              <el-select v-model="productInfo.templateId" placeholder="请选择测试模板" class="template-select">
                <el-option label="模板1" value="1" />
                <el-option label="模板2" value="2" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- 测试设备状态 -->
    <el-card class="box-card mt-4">
      <template #header>
        <div class="card-header">
          <span class="title">测试设备状态</span>
          <el-button type="primary" @click="refreshDevices">刷新</el-button>
        </div>
      </template>
      <div class="device-list">
        <el-row :gutter="20">
          <el-col :span="6" v-for="device in devices" :key="device.id">
            <el-card shadow="hover" :class="['device-card', device.online ? 'online' : 'offline']">
              <template #header>
                <div class="device-header">
                  {{ device.name }}
                  <el-tag :type="device.online ? 'success' : 'info'" size="small">
                    {{ device.online ? '在线' : '离线' }}
                  </el-tag>
                </div>
              </template>
              <div class="device-info">
                <div>RSSI: {{ device.rssi }} dBm</div>
                <div>最后通信: {{ device.lastSeen }}</div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 测试控制 -->
    <el-card class="box-card mt-4">
      <template #header>
        <div class="card-header">
          <span class="title">测试控制</span>
        </div>
      </template>
      <div class="control-panel">
        <div class="control-buttons">
          <el-button type="primary" :disabled="!canStart" @click="startTest">
            开始测试
          </el-button>
          <el-button :disabled="!isRunning" @click="pauseTest">暂停</el-button>
          <el-button :disabled="!isPaused" @click="resumeTest">继续</el-button>
          <el-button type="danger" :disabled="!isRunning" @click="stopTest">
            停止
          </el-button>
        </div>
        <div class="progress-info mt-4">
          <el-progress 
            :percentage="testProgress" 
            :status="testStatus === 'error' ? 'exception' : testStatus"
          />
          <div class="current-step mt-2">
            <span class="step-info">当前测试组: {{ currentGroup.name }}</span>
            <span class="step-info">TestID: {{ currentGroup.testId }}</span>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 测试结果 -->
    <el-card class="box-card mt-4">
      <template #header>
        <div class="card-header">
          <span class="title">测试结果</span>
          <div class="result-actions">
            <el-button type="success" :disabled="!hasResults" @click="exportResults">
              导出结果
            </el-button>
            <el-button :disabled="!hasResults" @click="clearResults">
              清除
            </el-button>
          </div>
        </div>
      </template>
      <el-table :data="testResults" border style="width: 100%">
        <el-table-column prop="step" label="Step" width="80" />
        <el-table-column prop="device" label="设备" width="120" />
        <el-table-column prop="unit" label="Unit" width="100" />
        <el-table-column prop="operation" label="操作" width="100" />
        <el-table-column prop="actualValue" label="实际值" width="120" />
        <el-table-column prop="expectedValue" label="期望值" width="120" />
        <el-table-column label="结果" width="100">
          <template #default="{ row }">
            <el-tag :type="row.result.success ? 'success' : 'danger'">
              {{ row.result.success ? '通过' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="timestamp" label="时间" width="180" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { defineComponent, ref, computed } from 'vue'

export default defineComponent({
  name: 'TestExecution',
  setup() {
    // 产品信息
    const productInfo = ref({
      serialNumber: '',
      drawingCode: '',
      templateId: ''
    })

    // 设备状态
    const devices = ref([
      { 
        id: 1, 
        name: 'EDB4-1', 
        online: true, 
        rssi: -75,
        lastSeen: '2023-12-09 15:30:00'
      },
      { 
        id: 2, 
        name: 'EDB4-2', 
        online: true,
        rssi: -65,
        lastSeen: '2023-12-09 15:30:00'
      },
      { 
        id: 3, 
        name: 'EDB4-3', 
        online: false,
        rssi: 0,
        lastSeen: '2023-12-09 15:00:00'
      }
    ])

    // 测试状态
    const testStatus = ref('') // '', 'success', 'exception', 'warning'
    const testProgress = ref(0)
    const isRunning = ref(false)
    const isPaused = ref(false)

    // 当前测试组信息
    const currentGroup = ref({
      name: '组1：初始状态检查',
      testId: 'test_01'
    })

    // 测试结果
    const testResults = ref([
      {
        step: 1,
        device: 'EDB4-1',
        unit: 'AI1',
        operation: 'read',
        actualValue: 0.5,
        expectedValue: 0,
        result: { success: true },
        timestamp: '2023-12-09 15:30:01'
      },
      {
        step: 1,
        device: 'EDB4-2',
        unit: 'AI1',
        operation: 'read',
        actualValue: 1.5,
        expectedValue: 0,
        result: { success: false },
        timestamp: '2023-12-09 15:30:01'
      }
    ])

    // 计算属性
    const canStart = computed(() => {
      return productInfo.value.serialNumber && 
             productInfo.value.drawingCode && 
             productInfo.value.templateId &&
             devices.value.some(d => d.online)
    })

    const hasResults = computed(() => testResults.value.length > 0)

    // 方法
    const refreshDevices = () => {
      console.log('刷新设备状态')
    }

    const startTest = () => {
      isRunning.value = true
      testStatus.value = ''
      testProgress.value = 0
      // 启动测试逻辑
    }

    const pauseTest = () => {
      isPaused.value = true
      isRunning.value = false
      testStatus.value = 'warning'
    }

    const resumeTest = () => {
      isPaused.value = false
      isRunning.value = true
      testStatus.value = ''
    }

    const stopTest = () => {
      isRunning.value = false
      isPaused.value = false
      testStatus.value = ''
      testProgress.value = 0
    }

    const exportResults = () => {
      console.log('导出测试结果')
    }

    const clearResults = () => {
      testResults.value = []
    }

    return {
      productInfo,
      devices,
      testStatus,
      testProgress,
      isRunning,
      isPaused,
      currentGroup,
      testResults,
      canStart,
      hasResults,
      refreshDevices,
      startTest,
      pauseTest,
      resumeTest,
      stopTest,
      exportResults,
      clearResults
    }
  }
})
</script>

<style scoped>
.test-execution {
  padding: 20px;
}

.mt-4 {
  margin-top: 20px;
}

.mt-2 {
  margin-top: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  font-size: 16px;
  font-weight: bold;
}

.template-select {
  width: 100%;
}

.device-list {
  margin-top: 10px;
}

.device-card {
  margin-bottom: 20px;
}

.device-card.online {
  border: 1px solid #67C23A;
}

.device-card.offline {
  border: 1px solid #909399;
}

.device-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.device-info {
  font-size: 14px;
  color: #666;
}

.control-panel {
  padding: 20px;
}

.control-buttons {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.progress-info {
  max-width: 600px;
  margin: 0 auto;
}

.step-info {
  margin-right: 20px;
  font-weight: bold;
}

.result-actions {
  display: flex;
  gap: 10px;
}
</style> 