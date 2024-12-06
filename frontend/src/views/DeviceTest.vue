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
      <el-card v-for="(msg, index) in messages" :key="index" class="message-card" :class="msg.type">
        <div class="message-header">
          <span class="message-type">{{ msg.type === 'send' ? '发送' : '接收' }}</span>
          <span class="message-time">{{ msg.time }}</span>
        </div>
        <div class="message-topic">Topic: {{ msg.topic }}</div>
        <div class="message-payload">Payload: {{ JSON.stringify(msg.payload, null, 2) }}</div>
      </el-card>
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
          // 如果当前选中的设备离线了,清除选择
          if (form.value.deviceId) {
            const [projectName, moduleType, serialNumber] = form.value.deviceId.split('-')
            const currentDevice = devices.value.find(d => 
              d.project_name === projectName && 
              d.module_type === moduleType && 
              d.serial_number === serialNumber
            )
            if (!currentDevice || currentDevice.status !== 'online') {
              form.value.deviceId = ''
              ElMessage.warning('当前选中的设备已离线')
            }
          }
        }
      } catch (error) {
        console.error('加载设备���表失败:', error)
        ElMessage.error('加载设备列表失败')
      }
    }

    // 处理设备选择变化
    const handleDeviceChange = (value) => {
      console.log('选择的设备:', value)
    }

    // 清空消息记录
    const clearMessages = () => {
      messages.value = []
      ElMessage.success('消息记录已清空')
    }

    // 添加消息记录
    const addMessage = (type, topic, payload) => {
      messages.value.unshift({
        type,
        topic,
        payload,
        time: new Date().toLocaleString()
      })
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
        if (data.type === 'mqtt_message') {
          addMessage('receive', data.topic, data.payload)
        }
      } catch (error) {
        console.error('处理WebSocket消息失败:', error)
      }
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
      handleDeviceChange,
      handleRead,
      handleWrite,
      clearMessages,
      loadDevices
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
}

.message-log {
  margin-top: 20px;
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

.message-card {
  margin-bottom: 10px;
}

.message-card.send {
  background-color: #f0f9eb;
}

.message-card.receive {
  background-color: #f4f4f5;
}

.message-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.message-type {
  font-weight: bold;
}

.message-time {
  color: #909399;
}

.message-topic {
  color: #409EFF;
  margin-bottom: 5px;
}

.message-payload {
  font-family: monospace;
  white-space: pre-wrap;
}
</style> 