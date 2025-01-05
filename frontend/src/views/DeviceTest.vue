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
    const loading = ref(false)
    const selectedDevice = ref(null)

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
        const message = {
          type: 'command',
          command: 'read',
          device: {
            id: deviceId,
            channel: form.value.channel
          }
        };

        if (ws.value && ws.value.readyState === WebSocket.OPEN) {
          ws.value.send(JSON.stringify(message));
          addMessage('send', `${deviceId}/command`, message, form.value.channel);
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
        const message = {
          type: 'command',
          command: 'write',
          device: {
            id: deviceId,
            channel: form.value.channel
          },
          value: parseFloat(form.value.value)
        };

        if (ws.value && ws.value.readyState === WebSocket.OPEN) {
          ws.value.send(JSON.stringify(message));
          addMessage('send', `${deviceId}/command`, message, form.value.channel);
        } else {
          ElMessage.error('WebSocket连接已断开');
        }
      } catch (error) {
        console.error('发送写入命令失败:', error);
        ElMessage.error('发送写入命令失败');
      }
    };

    // 处理WebSocket消息
    const handleWebSocketMessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        console.log('收到WebSocket消息:', data);

        // 处理设备状态更新
        if (data.type === 'device_status') {
          const deviceIndex = devices.value.findIndex(d => 
            d.project_name === data.device.project_name &&
            d.module_type === data.device.module_type &&
            d.serial_number === data.device.serial_number
          );

          if (deviceIndex !== -1) {
            devices.value[deviceIndex].status = data.status;
            devices.value[deviceIndex].rssi = data.rssi;
          }
        }
        // 处理命令响应
        else if (data.type === 'response') {
          addMessage('receive', data.device.id, data.payload, data.device.channel);
        }
      } catch (error) {
        console.error('处理WebSocket消息失败:', error);
      }
    };

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
  margin: 20px 0;
  padding: 20px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
}

.channel-control {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.channel-label {
  margin-right: 10px;
  font-weight: 500;
}

.command-buttons {
  display: flex;
  align-items: center;
  gap: 10px;
}

.message-log {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 20px;
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.message-header h3 {
  margin: 0;
}

.no-data {
  text-align: center;
  color: #909399;
  padding: 30px 0;
}

.message-list {
  max-height: 400px;
  overflow-y: auto;
}

.message-item {
  padding: 10px;
  border-bottom: 1px solid #ebeef5;
  cursor: pointer;
}

.message-item:hover {
  background-color: #f5f7fa;
}

.message-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.time {
  color: #909399;
  font-size: 13px;
}

.type {
  color: #409eff;
  font-weight: 500;
}

.channel {
  color: #606266;
}

.content {
  color: #303133;
  flex: 1;
}
</style> 