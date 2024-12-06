<template>
  <div class="message-list">
    <el-card class="message-card">
      <template #header>
        <div class="card-header">
          <span>消息管理</span>
        </div>
      </template>

      <!-- 订阅的Topic列表 -->
      <el-card class="section-card">
        <template #header>
          <div class="section-header">
            <span>订阅的Topic列表</span>
          </div>
        </template>
        <el-table :data="topicList" style="width: 100%" height="200">
          <el-table-column prop="topic" label="Topic" />
          <el-table-column prop="subscribeTime" label="订阅时间" width="180" />
        </el-table>
      </el-card>

      <!-- 设备上下线消息 -->
      <el-card class="section-card">
        <template #header>
          <div class="section-header">
            <span>设备上下线消息</span>
            <el-button type="primary" size="small" @click="clearDeviceStatusMessages">
              清除显示
            </el-button>
          </div>
        </template>
        <el-table :data="deviceStatusMessages" style="width: 100%" height="200">
          <el-table-column prop="timestamp" label="时间" width="180" />
          <el-table-column prop="deviceId" label="设备ID" width="120" />
          <el-table-column prop="status" label="状态">
            <template #default="scope">
              <el-tag :type="scope.row.status === 'online' ? 'success' : 'danger'">
                {{ scope.row.status === 'online' ? '上线' : '下线' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="message" label="消息内容" />
        </el-table>
      </el-card>

      <!-- 设备命令消息 -->
      <el-card class="section-card">
        <template #header>
          <div class="section-header">
            <span>设备命令消息</span>
            <el-button type="primary" size="small" @click="clearDeviceCommands">
              清除显示
            </el-button>
          </div>
        </template>
        <el-table :data="deviceCommands" style="width: 100%" height="200">
          <el-table-column prop="timestamp" label="时间" width="180" />
          <el-table-column prop="deviceId" label="设备ID" width="120" />
          <el-table-column prop="channel" label="通道" width="80" />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="scope">
              <el-tag :type="scope.row.type === 'command' ? 'primary' : 'success'">
                {{ scope.row.type === 'command' ? '命令' : '回复' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="content" label="内容" />
        </el-table>
      </el-card>
    </el-card>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useWebSocket } from '../composables/useWebSocket'
import { ElMessage } from 'element-plus'

export default {
  name: 'MessageList',
  setup() {
    const MAX_MESSAGES = 100
    const topicList = ref([])
    const deviceStatusMessages = ref([])
    const deviceCommands = ref([])
    const listenerAdded = ref(false)
    const wsInstance = useWebSocket()

    // 处理WebSocket消息
    const handleMessage = (message) => {
      try {
        const data = JSON.parse(message.data)
        
        switch (data.type) {
          case 'topic_list':
            topicList.value = data.topics.map(topic => ({
              topic,
              subscribeTime: new Date().toLocaleString()
            }))
            break
            
          case 'device_status':
            deviceStatusMessages.value.unshift({
              timestamp: new Date().toLocaleString(),
              deviceId: `${data.device.project_name}/${data.device.module_type}/${data.device.serial_number}`,
              status: data.device.status,
              message: `RSSI: ${data.device.rssi}`
            })
            if (deviceStatusMessages.value.length > MAX_MESSAGES) {
              deviceStatusMessages.value = deviceStatusMessages.value.slice(0, MAX_MESSAGES)
            }
            break
            
          case 'device_command':
            deviceCommands.value.unshift({
              timestamp: new Date().toLocaleString(),
              deviceId: data.deviceId,
              channel: data.channel,
              type: data.commandType,
              content: data.content
            })
            if (deviceCommands.value.length > MAX_MESSAGES) {
              deviceCommands.value = deviceCommands.value.slice(0, MAX_MESSAGES)
            }
            break

          default:
            console.warn('未知的消息类型:', data.type)
        }
      } catch (error) {
        console.error('解析消息失败:', error)
        ElMessage.error('消息格式错误')
      }
    }

    // 清除设备状态消息
    const clearDeviceStatusMessages = () => {
      deviceStatusMessages.value = []
    }

    // 清除设备命令消息
    const clearDeviceCommands = () => {
      deviceCommands.value = []
    }

    // 设置消息监听器
    const setupMessageListener = (ws) => {
      if (ws && !listenerAdded.value) {
        ws.addEventListener('message', handleMessage)
        listenerAdded.value = true
      }
    }

    // 移除消息监听器
    const removeMessageListener = (ws) => {
      if (ws && listenerAdded.value) {
        ws.removeEventListener('message', handleMessage)
        listenerAdded.value = false
      }
    }

    // 监听WebSocket连接状态
    watch(() => wsInstance.ws.value, (newWs, oldWs) => {
      if (oldWs) {
        removeMessageListener(oldWs)
      }
      if (newWs) {
        setupMessageListener(newWs)
      }
    })

    // 监听连接状态
    watch(() => wsInstance.isConnected.value, (isConnected) => {
      if (!isConnected) {
        ElMessage.warning('WebSocket连接已断开，正在重连...')
      }
    })

    onMounted(() => {
      if (wsInstance.ws.value) {
        setupMessageListener(wsInstance.ws.value)
      }
    })

    onUnmounted(() => {
      if (wsInstance.ws.value) {
        removeMessageListener(wsInstance.ws.value)
      }
      wsInstance.cleanup()
    })

    return {
      topicList,
      deviceStatusMessages,
      deviceCommands,
      clearDeviceStatusMessages,
      clearDeviceCommands
    }
  }
}
</script>

<style scoped>
.message-list {
  padding: 20px;
}

.message-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.section-card {
  margin-bottom: 20px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.el-table {
  margin-top: 10px;
}
</style> 