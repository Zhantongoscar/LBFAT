<template>
  <el-main class="plan-detail-main">
    <div class="plan-header">
      <h2>{{ plan.name }}</h2>
      <p class="description">{{ plan.description }}</p>
      <el-divider />
    </div>

    <!-- 测试组列表 -->
    <el-table
      :data="plan.groups"
      style="width: 100%"
      :row-class-name="getRowClassName"
    >
      <el-table-column type="expand">
        <template #default="props">
          <div class="group-detail">
            <p><strong>描述：</strong>{{ props.row.description }}</p>
            <p><strong>执行模式：</strong>{{ props.row.execution_mode === 'sequential' ? '顺序执行' : '并行执行' }}</p>
            <p><strong>失败策略：</strong>{{ props.row.failure_strategy === 'continue' ? '继续执行' : '停止执行' }}</p>
          </div>
        </template>
      </el-table-column>
      
      <el-table-column label="序号" type="index" width="60" />
      <el-table-column prop="name" label="测试组名称" />
      <el-table-column prop="level" label="级别" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.level === 1 ? 'danger' : 'info'">
            {{ scope.row.level === 1 ? '安全类' : '普通类' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="120">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.status)">
            {{ getStatusText(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="result" label="结果" width="100">
        <template #default="scope">
          <el-tag 
            :type="getResultType(scope.row.result)"
            v-if="scope.row.status === 'completed'"
          >
            {{ getResultText(scope.row.result) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150">
        <template #default="scope">
          <el-button-group>
            <el-button
              size="small"
              type="primary"
              :icon="View"
              @click="$emit('view-detail', scope.row)"
              title="查看详情"
            />
            <el-button
              size="small"
              type="success"
              :icon="VideoPlay"
              @click="$emit('run-group', scope.row)"
              :disabled="isTestRunning"
              title="执行此组"
            />
            <el-button
              size="small"
              type="danger"
              :icon="Delete"
              @click="$emit('remove-group', scope.row)"
              :disabled="isTestRunning"
              title="移除此组"
            />
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>
  </el-main>
</template>

<script setup>
import { View, VideoPlay, Delete } from '@element-plus/icons-vue'
import { usePlanStatus } from '../composables/usePlanStatus'

defineProps({
  plan: {
    type: Object,
    required: true
  },
  isTestRunning: {
    type: Boolean,
    default: false
  }
})

defineEmits(['view-detail', 'run-group', 'remove-group'])

const { getStatusType, getStatusText, getResultType, getResultText } = usePlanStatus()

const getRowClassName = ({ row }) => {
  if (row.status === 'running') return 'running-row'
  return ''
}
</script>

<style scoped>
.plan-detail-main {
  padding: 20px;
}

.plan-header {
  margin-bottom: 20px;
}

.plan-header h2 {
  margin: 0 0 10px 0;
}

.description {
  color: #666;
  margin: 0;
}

.group-detail {
  padding: 20px;
  background: #f5f7fa;
}

.group-detail p {
  margin: 5px 0;
}

.running-row {
  background-color: #fdf6ec !important;
}

:deep(.el-table .cell) {
  white-space: nowrap;
}
</style> 