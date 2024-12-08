<template>
  <div class="device-test">
    <h2>设备测试</h2>

    <!-- 设备选择和刷新按钮 -->
    <div class="header-actions">
      <el-select v-model="form.deviceId" placeholder="请选择设备" @change="handleDeviceChange">
        <el-option
          v-for="device in onlineDevices"
          :key="`${device.project_name}-${device.module_type}-${device.serial_number}`"
          :label="`${device.project_name}/${device.module_type}/${device.serial_number}`"
          :value="`${device.project_name}-${device.module_type}-${device.serial_number}`"
        />
      </el-select>
      <el-button type="primary" @click="loadDevices">刷新设备列表</el-button>
    </div>

    <!-- 命令操作区域 -->
    <el-form :model="form" label-width="120px" class="command-form">
      <el-form-item label="通道号">
        <el-input-number v-model="form.channel" :min="1" :max="8" />
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="handleRead" :disabled="!form.deviceId">读取</el-button>
        <el-input-number 
          v-model="form.writeValue" 
          :precision="2" 
          style="margin: 0 10px"
          :disabled="!form.deviceId"
        />
        <el-button type="success" @click="handleWrite" :disabled="!form.deviceId">写入</el-button>
      </el-form-item>
    </el-form>

    <!-- 消息记录 -->
    <div class="message-log">
      <div class="message-header">
        <h3>消息记录</h3>
        <el-button type="warning" @click="clearMessages" :disabled="messages.length === 0">
          清空消息
        </el-button>
      </div>
      
      <el-table :data="messages" style="width: 100%" :max-height="400">
        <el-table-column prop="time" label="时间" width="180" />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.type === 'send' ? 'primary' : 'success'">
              {{ scope.row.type === 'send' ? '发送命令' : '设备响应' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="channel" label="通道" width="80" />
        <el-table-column label="内容" min-width="300">
          <template #default="scope">
            <div v-if="scope.row.type === 'send'">
              <div class="message-content">
                <span class="command-label">命令类型:</span>
                <span class="command-value">{{ scope.row.payload.command }}</span>
                <span v-if="scope.row.payload.value !== undefined">
                  <span class="command-label">写入值:</span>
                  <span class="command-value">{{ scope.row.payload.value }}</span>
                </span>
              </div>
            </div>
            <div v-else>
              <div class="message-content">
                <el-tag 
                  :type="scope.row.payload.status === 'success' ? 'success' : 'danger'"
                  size="small"
                  style="margin-right: 8px"
                >
                  {{ scope.row.payload.status }}
                </el-tag>
                <template v-if="scope.row.payload.value !== undefined">
                  <span class="response-label">返回值:</span>
                  <span class="response-value">{{ scope.row.payload.value }}</span>
                </template>
                <template v-if="scope.row.payload.error">
                  <span class="response-label">错误信息:</span>
                  <span class="response-value error">{{ scope.row.payload.error }}</span>
                </template>
              </div>
              <div class="raw-message">
                <span class="raw-label">原始报文:</span>
                <pre class="raw-content">{{ JSON.stringify(scope.row.payload, null, 2) }}</pre>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="scope">
            <el-button 
              type="primary" 
              link 
              @click="showMessageDetail(scope.row)"
            >
              查看报文
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 消息详情对话框 -->
      <el-dialog
        v-model="messageDetailVisible"
        title="报文详情"
        width="60%"
      >
        <div v-if="selectedMessage" class="message-detail">
          <div class="detail-item">
            <div class="detail-label">时间:</div>
            <div class="detail-value">{{ selectedMessage.time }}</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">类型:</div>
            <div class="detail-value">{{ selectedMessage.type === 'send' ? '发送' : '接收' }}</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Topic:</div>
            <div class="detail-value">{{ selectedMessage.topic }}</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">原始报文:</div>
            <div class="detail-value">
              <pre>{{ JSON.stringify(selectedMessage.payload, null, 2) }}</pre>
            </div>
          </div>
        </div>
      </el-dialog>

      <el-empty v-if="messages.length === 0" description="暂无消息记录" />
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed, onUnmounted } from 'vue'
import axios from 'axios'
import { useWebSocket } from '../composables/useWebSocket'
import { ElMessage } from 'element-plus'

export default {
  name: 'DeviceTest',
  setup() {
    const { ws, isConnected } = useWebSocket()
    const devices = ref([])
    const messages = ref([])
    const form = ref({
      deviceId: '',
      channel: 1,
      writeValue: 0
    })
    const messageDetailVisible = ref(false)
    const selectedMessage = ref(null)

    // 过滤出在线设备
    const onlineDevices = computed(() => {
      return devices.value.filter(device => device.status === 'online')
    })

    // 加载设备列表
    const loadDevices = async () => {
      try {
        const response = await axios.get(`${import.meta.env.VITE_API_URL}/api/devices`)
        if (response.data.code === 200) {
          devices.value = response.data.data
          
          // 如果当前没有选中设备，自动选择第一个在线设备
          if (!form.value.deviceId) {
            const firstOnlineDevice = devices.value.find(device => device.status === 'online')
            if (firstOnlineDevice) {
              form.value.deviceId = `${firstOnlineDevice.project_name}-${firstOnlineDevice.module_type}-${firstOnlineDevice.serial_number}`
              console.log('自动选择设备:', form.value.deviceId)
            }
          } else {
            // 检查当前选中的设备是否离线
            const [projectName, moduleType, serialNumber] = form.value.deviceId.split('-')
            const currentDevice = devices.value.find(d => 
              d.project_name === projectName && 
              d.module_type === moduleType && 
              d.serial_number === serialNumber
            )
            if (!currentDevice || currentDevice.status !== 'online') {
              form.value.deviceId = ''
              ElMessage.warning('当前选中的设备已离线')
              // 尝试选择其他在线设备
              const anotherOnlineDevice = devices.value.find(device => device.status === 'online')
              if (anotherOnlineDevice) {
                form.value.deviceId = `${anotherOnlineDevice.project_name}-${anotherOnlineDevice.module_type}-${anotherOnlineDevice.serial_number}`
                ElMessage.success('已自动切换到其他在线设备')
              }
            }
          }
        }
      } catch (error) {
        console.error('加载设备列表失败:', error)
        ElMessage.error('加载设备列表失败')
      }
    }

    // 处理设备选择变化
    const handleDeviceChange = (value) => {
      console.log('选择的设备:', value)
      // 清空消息记录
      messages.value = []
    }

    // 清空消息记录
    const clearMessages = () => {
      messages.value = []
      ElMessage.success('消息记录已清空')
    }

    // 添加消息记录
    const addMessage = (type, topic, payload, channel) => {
      // 提取响应消息的关键信息
      let displayPayload = payload
      if (type === 'receive') {
        displayPayload = {
          ...payload,
          channel: channel,
          responseTime: new Date().toLocaleString(),
          // 根据不同命令类型处理响应
          value: payload.value !== undefined ? payload.value : 
                payload.error ? `错误: ${payload.error}` : 
                payload.status === 'success' ? '执行成功' : '执行失败'
        }
      }

      messages.value.unshift({
        type,
        topic,
        payload: displayPayload,
        channel: channel || (type === 'send' ? form.value.channel : undefined),
        time: new Date().toLocaleString()
      })

      // 如果消息数量超过100条，删除旧消息
      if (messages.value.length > 100) {
        messages.value = messages.value.slice(0, 100)
      }
    }

    // 发送读取命令
    const handleRead = () => {
      if (!form.value.deviceId) return
      
      const [projectName, moduleType, serialNumber] = form.value.deviceId.split('-')
      const topic = `${projectName}/${moduleType}/${serialNumber}/${form.value.channel}/command`
      const payload = { command: 'read' }
      
      console.log('准备发送读取命令:', {
        deviceId: form.value.deviceId,
        topic,
        payload,
        wsConnected: isConnected.value,
        wsState: ws.value ? ws.value.readyState : 'no ws'
      })
      
      // 发送MQTT消息
      if (ws.value && isConnected.value) {
        const message = JSON.stringify({
          type: 'mqtt_publish',
          topic,
          payload
        })
        console.log('发送WebSocket消息:', message)
        ws.value.send(message)
        
        // 记录发送的消息
        addMessage('send', topic, payload)
      } else {
        console.error('WebSocket未连接:', {
          ws: !!ws.value,
          isConnected: isConnected.value
        })
        ElMessage.error('WebSocket未连接')
      }
    }

    // 发送写入命令
    const handleWrite = () => {
      if (!form.value.deviceId) return
      
      const [projectName, moduleType, serialNumber] = form.value.deviceId.split('-')
      const topic = `${projectName}/${moduleType}/${serialNumber}/${form.value.channel}/command`
      const payload = {
        command: 'write',
        value: form.value.writeValue
      }
      
      console.log('准备发送写入命令:', {
        deviceId: form.value.deviceId,
        topic,
        payload,
        wsConnected: isConnected.value,
        wsState: ws.value ? ws.value.readyState : 'no ws'
      })
      
      // 发送MQTT消息
      if (ws.value && isConnected.value) {
        const message = JSON.stringify({
          type: 'mqtt_publish',
          topic,
          payload
        })
        console.log('发送WebSocket消息:', message)
        ws.value.send(message)
        
        // 记录发送的消息
        addMessage('send', topic, payload)
      } else {
        console.error('WebSocket未连接:', {
          ws: !!ws.value,
          isConnected: isConnected.value
        })
        ElMessage.error('WebSocket未连接')
      }
    }

    // 监听WebSocket消息
    const handleWebSocketMessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        console.log('收到WebSocket消息:', data)

        if (data.type === 'mqtt_message') {
          // 检查是否是当前设备的消息
          const [projectName, moduleType, serialNumber] = form.value.deviceId.split('-')
          const isCurrentDevice = 
            data.device.projectName === projectName &&
            data.device.moduleType === moduleType &&
            data.device.serialNumber === serialNumber

          if (!isCurrentDevice) {
            console.log('不是当前设备的消息，忽略')
            return
          }

          // 处理响应消息
          if (data.messageType === 'response') {
            console.log('收到设备响应:', {
              channel: data.device.channel,
              payload: data.payload
            })

            addMessage('receive', data.topic, data.payload, data.device.channel)
          }
        }
      } catch (error) {
        console.error('处理WebSocket消息失败:', error)
      }
    }

    // 显示消息详情
    const showMessageDetail = (message) => {
      selectedMessage.value = message
      messageDetailVisible.value = true
    }

    // 组件挂载时添加WebSocket监听
    onMounted(() => {
      loadDevices()
      if (ws.value) {
        ws.value.addEventListener('message', handleWebSocketMessage)
      }
    })

    // 组件卸载时移除WebSocket监听
    onUnmounted(() => {
      if (ws.value) {
        ws.value.removeEventListener('message', handleWebSocketMessage)
      }
    })

    return {
      devices,
      onlineDevices,
      messages,
      form,
      messageDetailVisible,
      selectedMessage,
      handleDeviceChange,
      handleRead,
      handleWrite,
      clearMessages,
      loadDevices,
      showMessageDetail
    }
  }
}
</script>

<style scoped>
.device-test {
  padding: 20px;
}

.header-actions {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.command-form {
  margin-top: 20px;
  margin-bottom: 20px;
}

.message-log {
  margin-top: 20px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 20px;
}

.message-log .message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.message-log .message-header h3 {
  margin: 0;
}

.message-content {
  margin-bottom: 8px;
}

.command-label, .response-label, .raw-label {
  color: #606266;
  margin-right: 8px;
  font-weight: 500;
}

.command-value, .response-value {
  color: #303133;
  margin-right: 16px;
}

.response-value.error {
  color: #f56c6c;
}

.raw-message {
  margin-top: 8px;
  font-size: 13px;
}

.raw-content {
  background-color: #f8f9fa;
  padding: 8px;
  border-radius: 4px;
  margin: 4px 0 0;
  font-family: monospace;
  white-space: pre-wrap;
  font-size: 12px;
}
</style> 