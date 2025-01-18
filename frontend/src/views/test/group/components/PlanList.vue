<template>
  <el-aside width="300px" class="plan-list-aside">
    <div class="plan-list-header">
      <h3>测试计划列表</h3>
      <el-input
        v-model="searchKeyword"
        placeholder="搜索测试计划"
        prefix-icon="Search"
        clearable
        @input="handleSearch"
      />
    </div>
    <el-scrollbar>
      <el-menu
        :default-active="selectedPlanId"
        @select="$emit('select', $event)"
      >
        <el-menu-item
          v-for="plan in plans"
          :key="plan.id"
          :index="plan.id.toString()"
        >
          <el-icon><Document /></el-icon>
          <template #title>
            <span>{{ plan.name }}</span>
            <el-tag 
              size="small" 
              :type="getStatusType(plan.status)"
              class="status-tag"
            >
              {{ getStatusText(plan.status) }}
            </el-tag>
          </template>
        </el-menu-item>
      </el-menu>
    </el-scrollbar>
  </el-aside>
</template>

<script setup>
import { ref } from 'vue'
import { Document, Search } from '@element-plus/icons-vue'
import { usePlanStatus } from '../composables/usePlanStatus'

const props = defineProps({
  plans: {
    type: Array,
    required: true
  },
  selectedPlanId: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['select', 'search'])

const searchKeyword = ref('')
const { getStatusType, getStatusText } = usePlanStatus()

const handleSearch = () => {
  emit('search', searchKeyword.value)
}
</script>

<style scoped>
.plan-list-aside {
  border-right: 1px solid #e6e6e6;
  background: #f5f7fa;
}

.plan-list-header {
  padding: 15px;
}

.plan-list-header h3 {
  margin: 0 0 15px 0;
}

.status-tag {
  margin-left: 10px;
}

:deep(.el-menu-item) {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style> 