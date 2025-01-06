<template>
  <div class="subscription-list">
    <div class="header">
      <h1>订阅管理</h1>
    </div>

    <!-- 订阅的Topic列表 -->
    <div class="topic-list-section">
      <div class="section-header">
        <h3>订阅的Topic列表</h3>
      </div>
      <el-table :data="subscribedTopics" style="width: 100%" size="small">
        <el-table-column prop="topic" label="Topic" />
        <el-table-column prop="subscribeTime" label="订阅时间" width="180" />
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button type="danger" link @click="handleUnsubscribe(scope.row)">
              取消订阅
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 添加订阅 -->
      <div class="add-subscription" style="margin-top: 20px;">
        <el-form :inline="true" :model="subscriptionForm">
          <el-form-item label="Topic">
            <el-input v-model="subscriptionForm.topic" placeholder="请输入要订阅的Topic" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSubscribe">订阅</el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useWebSocket } from '../composables/useWebSocket'

const { ws, isConnected } = useWebSocket()
const subscribedTopics = ref([])
const subscriptionForm = ref({
  topic: ''
})

// 加载订阅的Topic列表
const loadSubscribedTopics = () => {
  subscribedTopics.value = [
    {
      topic: 'lb_test/+/+/status',
      subscribeTime: new Date().toLocaleString()
    },
    {
      topic: 'lb_test/+/+/+/response',
      subscribeTime: new Date().toLocaleString()
    }
  ]
}

// 订阅新Topic
const handleSubscribe = () => {
  if (!subscriptionForm.value.topic) {
    ElMessage.warning('请输入要订阅的Topic')
    return
  }

  if (ws.value && ws.value.readyState === WebSocket.OPEN) {
    ws.value.send(JSON.stringify({
      type: 'mqtt_subscribe',
      topic: subscriptionForm.value.topic
    }))

    // 添加到列表
    subscribedTopics.value.unshift({
      topic: subscriptionForm.value.topic,
      subscribeTime: new Date().toLocaleString()
    })

    subscriptionForm.value.topic = ''
    ElMessage.success('订阅成功')
  } else {
    ElMessage.error('WebSocket连接已断开')
  }
}

// 取消订阅
const handleUnsubscribe = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要取消订阅 Topic "${row.topic}" 吗？`,
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    if (ws.value && ws.value.readyState === WebSocket.OPEN) {
      ws.value.send(JSON.stringify({
        type: 'mqtt_unsubscribe',
        topic: row.topic
      }))

      // 从列表中移除
      subscribedTopics.value = subscribedTopics.value.filter(t => t.topic !== row.topic)
      ElMessage.success('取消订阅成功')
    } else {
      ElMessage.error('WebSocket连接已断开')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('取消订阅失败:', error)
      ElMessage.error('取消订阅失败')
    }
  }
}

onMounted(() => {
  loadSubscribedTopics()
})
</script>

<style scoped>
.subscription-list {
  padding: 20px;
}

.header {
  margin-bottom: 20px;
}

.header h1 {
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.section-header {
  margin-bottom: 16px;
}

.section-header h3 {
  margin: 0;
  font-size: 16px;
  color: #606266;
}

:deep(.el-table) {
  --el-table-border-color: #ebeef5;
  --el-table-header-background-color: #f5f7fa;
}

.add-subscription {
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 4px;
}
</style> 