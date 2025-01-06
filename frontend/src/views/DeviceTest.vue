<template>
  <div class="device-test">
    <div class="header-actions">
      <el-select 
        v-model="selectedDevice" 
        placeholder="请选择设备"
        :loading="loading"
        @change="handleDeviceChange"
        style="width: 300px"
      >
        <el-option
          v-for="device in devices"
          :key="`${device.project_name}-${device.module_type}-${device.serial_number}`"
          :label="`${device.project_name}-${device.module_type}-${device.serial_number}`"
          :value="device"
          :disabled="device.status !== 'online'"
        >
          <span>{{ device.project_name }}-{{ device.module_type }}-{{ device.serial_number }}</span>
          <el-tag size="small" :type="device.status === 'online' ? 'success' : 'danger'" style="margin-left: 8px">
            {{ device.status === 'online' ? '在线' : '离线' }}
          </el-tag>
        </el-option>
      </el-select>
      <el-button @click="refreshDeviceList" :loading="loading">刷新设备列表</el-button>
    </div>

    <div class="command-form" v-if="selectedDevice">
      <div class="channel-control">
        <span class="channel-label">通道号</span>
        <el-input-number v-model="form.channel" :min="1" :max="20" />
      </div>
      
      <div class="command-buttons">
        <el-button type="primary" @click="handleRead" :disabled="!selectedDevice">读取</el-button>
        <el-input v-model="form.value" placeholder="写入值" style="width: 100px" />
        <el-button type="success" @click="handleWrite" :disabled="!selectedDevice">写入</el-button>
      </div>
    </div>

    <div class="message-log">
      <div class="message-header">
        <h3>消息记录</h3>
        <el-button @click="clearMessages">清空记录</el-button>
      </div>
      
      <div v-if="messages.length === 0" class="no-data">
        暂无消息记录
      </div>
      
      <div v-else class="message-list">
        <div v-for="(message, index) in messages" :key="index" class="message-item">
          <div class="message-content" @click="showMessageDetail(message)">
            <span class="time">{{ new Date(message.time).toLocaleTimeString() }}</span>
            <span class="type">{{ message.type === 'send' ? '发送' : '接收' }}</span>
            <span class="channel">通道: {{ message.channel }}</span>
            <span class="content">{{ message.content }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Online Logs -->
    <el-card class="section-card">
      <template #header>
        <div class="section-header">
          <span>Online Logs</span>
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

    <!-- Command Logs -->
    <el-card class="section-card">
      <template #header>
        <div class="section-header">
          <span>Command Logs</span>
          <el-button type="primary" size="small" @click="clearDeviceCommands">
            清除显示
          </el-button>
        </div>
      </template>
      <el-table :data="deviceCommands" style="width: 100%" height="200">
        <el-table-column label="报文信息">
          <template #default="scope">
            <div style="white-space: pre-line;">
              {{ scope.row.timestamp }}
              Topic: {{ scope.row.rawTopic }}
              QoS: 0
              {{ scope.row.content }}
            </div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="messageDetailVisible" title="消息详情" width="600px">
      <pre v-if="selectedMessage">{{ JSON.stringify(selectedMessage, null, 2) }}</pre>
    </el-dialog>
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
    const { ws, isConnected, addMessageListener, removeMessageListener } = useWebSocket()
    const devices = ref([])
    const messages = ref([])
    const deviceStatusMessages = ref([])
    const deviceCommands = ref([])
    const form = ref({
      deviceId: '',
      channel: 1,
      value: ''
    })
    const messageDetailVisible = ref(false)
    const selectedMessage = ref(null)
    const loading = ref(false)
    const selectedDevice = ref(null)
    const listenerAdded = ref(false)

    // 过滤出在线设备
    const onlineDevices = computed(() => {
      return devices.value.filter(device => device.status === 'online')
    })

    // 加载设备列表
    const loadDevices = async () => {
      try {
        loading.value = true;
        const response = await axios.get('/api/devices');
        if (response?.data?.code === 200) {
          devices.value = response.data.data;
          // 如果当前没有选中设备，且有在线设备，则选择第一个在线设备
          if (!selectedDevice.value && devices.value.length > 0) {
            const onlineDevice = devices.value.find(d => d.status === 'online');
            if (onlineDevice) {
              selectedDevice.value = onlineDevice;
            }
          }
        }
      } catch (error) {
        console.error('加载设备列表失败:', error);
        ElMessage.error('加载设备列表失败');
      } finally {
        loading.value = false;
      }
    };

    // 刷新设备列表
    const refreshDeviceList = () => {
      loadDevices();
    };

    // 处理设备选择变化
    const handleDeviceChange = (device) => {
      selectedDevice.value = device;
      clearMessages();
    };

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

    // 处理读取命令
    const handleRead = async () => {
      if (!selectedDevice.value) {
        ElMessage.warning('请先选择设备');
        return;
      }

      try {
        const deviceId = `${selectedDevice.value.project_name}/${selectedDevice.value.module_type}/${selectedDevice.value.serial_number}`;
        const topic = `${deviceId}/${form.value.channel}/command`;
        const message = {
          command: 'read'
        };

        if (ws.value && ws.value.readyState === WebSocket.OPEN) {
          ws.value.send(JSON.stringify({
            type: 'mqtt_publish',
            topic: topic,
            payload: message
          }));
          addMessage('send', topic, message, form.value.channel);
        } else {
          ElMessage.error('WebSocket连接已断开');
        }
      } catch (error) {
        console.error('发送读取命令失败:', error);
        ElMessage.error('发送读取命令失败');
      }
    };

    // 处理写入命令
    const handleWrite = async () => {
      if (!selectedDevice.value) {
        ElMessage.warning('请先选择设备');
        return;
      }

      if (!form.value.value) {
        ElMessage.warning('请输入写入值');
        return;
      }

      try {
        const deviceId = `${selectedDevice.value.project_name}/${selectedDevice.value.module_type}/${selectedDevice.value.serial_number}`;
        const topic = `${deviceId}/${form.value.channel}/command`;
        const message = {
          command: 'write',
          value: parseFloat(form.value.value)
        };

        if (ws.value && ws.value.readyState === WebSocket.OPEN) {
          ws.value.send(JSON.stringify({
            type: 'mqtt_publish',
            topic: topic,
            payload: message
          }));
          addMessage('send', topic, message, form.value.channel);
        } else {
          ElMessage.error('WebSocket连接已断开');
        }
      } catch (error) {
        console.error('发送写入命令失败:', error);
        ElMessage.error('发送写入命令失败');
      }
    };

    // 处理WebSocket消息
    const handleMessage = (message) => {
      try {
        const data = JSON.parse(message.data)
        console.log('收到WebSocket消息:', data)
        
        switch (data.type) {
          case 'device_status':
            deviceStatusMessages.value.unshift({
              timestamp: new Date().toLocaleString(),
              deviceId: `${data.device.projectName}/${data.device.moduleType}/${data.device.serialNumber}`,
              status: data.device.status,
              message: `RSSI: ${data.device.rssi}`,
              rawTopic: data.topic,
              rawMessage: data.rawMessage
            })
            if (deviceStatusMessages.value.length > 100) {
              deviceStatusMessages.value = deviceStatusMessages.value.slice(0, 100)
            }
            saveMessages()
            break
            
          case 'mqtt_message':
            if (data.messageType === 'response') {
              deviceCommands.value.unshift({
                timestamp: new Date().toLocaleString(),
                deviceId: `${data.device.projectName}/${data.device.moduleType}/${data.device.serialNumber}`,
                channel: data.device.channel,
                type: 'response',
                content: JSON.stringify(data.payload),
                rawTopic: data.topic
              })
              if (deviceCommands.value.length > 100) {
                deviceCommands.value = deviceCommands.value.slice(0, 100)
              }
              saveMessages()
            }
            break
        }
      } catch (error) {
        console.error('解析消息失败:', error)
      }
    }

    // 清除设备状态消息
    const clearDeviceStatusMessages = () => {
      deviceStatusMessages.value = []
      localStorage.removeItem('deviceStatusMessages')
    }

    // 清除设备命令消息
    const clearDeviceCommands = () => {
      deviceCommands.value = []
      localStorage.removeItem('deviceCommands')
    }

    // 从localStorage加载消息
    const loadMessages = () => {
      try {
        const savedStatusMessages = localStorage.getItem('deviceStatusMessages')
        if (savedStatusMessages) {
          deviceStatusMessages.value = JSON.parse(savedStatusMessages)
        }

        const savedCommands = localStorage.getItem('deviceCommands')
        if (savedCommands) {
          deviceCommands.value = JSON.parse(savedCommands)
        }
      } catch (error) {
        console.error('加载保存的消息失败:', error)
      }
    }

    // 保存消息到localStorage
    const saveMessages = () => {
      try {
        localStorage.setItem('deviceStatusMessages', JSON.stringify(deviceStatusMessages.value))
        localStorage.setItem('deviceCommands', JSON.stringify(deviceCommands.value))
      } catch (error) {
        console.error('保存消息失败:', error)
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
      loadMessages()
      if (ws.value) {
        addMessageListener(handleMessage)
        listenerAdded.value = true
      }
    })

    // 组件卸载时移除WebSocket监听
    onUnmounted(() => {
      if (listenerAdded.value) {
        removeMessageListener(handleMessage)
      }
    })

    return {
      devices,
      messages,
      deviceStatusMessages,
      deviceCommands,
      form,
      messageDetailVisible,
      selectedMessage,
      loading,
      selectedDevice,
      onlineDevices,
      handleDeviceChange,
      refreshDeviceList,
      clearMessages,
      handleRead,
      handleWrite,
      showMessageDetail: (message) => {
        selectedMessage.value = message
        messageDetailVisible.value = true
      },
      clearDeviceStatusMessages,
      clearDeviceCommands
    }
  }
}
</script>

<style scoped>
.device-test {
  padding: 20px;
}

.header-actions {
  margin-bottom: 20px;
  display: flex;
  gap: 10px;
}

.command-form {
  margin-bottom: 20px;
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.channel-control {
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.channel-label {
  min-width: 60px;
}

.command-buttons {
  display: flex;
  gap: 10px;
  align-items: center;
}

.message-log {
  margin-bottom: 20px;
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.message-header h3 {
  margin: 0;
}

.message-list {
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  max-height: 300px;
  overflow-y: auto;
}

.message-item {
  padding: 10px;
  border-bottom: 1px solid #e4e7ed;
  cursor: pointer;
}

.message-item:last-child {
  border-bottom: none;
}

.message-item:hover {
  background-color: #f5f7fa;
}

.message-content {
  display: flex;
  gap: 15px;
  align-items: center;
}

.time {
  color: #909399;
  font-size: 0.9em;
}

.type {
  color: #409EFF;
}

.channel {
  color: #67C23A;
}

.content {
  color: #606266;
}

.no-data {
  text-align: center;
  padding: 20px;
  color: #909399;
}

.section-card {
  margin-bottom: 20px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style> 