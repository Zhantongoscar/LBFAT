<template>
  <div class="group-execution-container">
    <!-- 顶部操作栏 -->
    <div class="operation-bar">
      <el-button type="primary" @click="createNewPlan">
        <el-icon><Plus /></el-icon>新建测试计划
      </el-button>
      <el-button type="success" @click="startGroupTest" :disabled="!selectedPlan">
        <el-icon><VideoPlay /></el-icon>开始组测试
      </el-button>
      <el-button type="warning" @click="stopGroupTest" :disabled="!isTestRunning">
        <el-icon><VideoPause /></el-icon>停止测试
      </el-button>
    </div>

    <el-container class="main-content">
      <!-- 左侧测试计划列表 -->
      <PlanList
        :plans="filteredPlans"
        :selected-plan-id="selectedPlanId"
        @select="handlePlanSelect"
        @search="handleSearch"
      />

      <!-- 右侧测试组详情 -->
      <GroupDetail
        v-if="selectedPlan"
        :plan="selectedPlan"
        :is-test-running="isTestRunning"
        @view-detail="viewGroupDetail"
        @run-group="runSingleGroup"
        @remove-group="removeGroup"
      />
    </el-container>

    <!-- 新建测试计划对话框 -->
    <PlanDialog
      v-model="dialogVisible"
      :truth-tables="truthTables"
      @submit="submitPlan"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Plus, VideoPlay, VideoPause } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import PlanList from './components/PlanList.vue'
import GroupDetail from './components/GroupDetail.vue'
import PlanDialog from './components/PlanDialog.vue'
import { useGroupTest } from './composables/useGroupTest'

defineOptions({
  name: 'GroupExecution'
})

// 状态数据
const selectedPlanId = ref('')
const searchKeyword = ref('')
const dialogVisible = ref(false)

// 使用组合式函数
const { isTestRunning, startGroupTest, stopGroupTest, runSingleGroup, removeGroup } = useGroupTest()

// 模拟数据
const truthTables = ref([
  { id: 1, name: '真值表1' },
  { id: 2, name: '真值表2' }
])

const testPlans = ref([
  {
    id: 1,
    name: '测试计划1',
    description: '这是测试计划1的描述',
    status: 'pending',
    groups: [
      {
        id: 1,
        name: '测试组1',
        level: 1,
        description: '安全类测试组',
        status: 'pending',
        execution_mode: 'sequential',
        failure_strategy: 'stop'
      },
      {
        id: 2,
        name: '测试组2',
        level: 0,
        description: '普通测试组',
        status: 'pending',
        execution_mode: 'parallel',
        failure_strategy: 'continue'
      }
    ]
  }
])

// 计算属性
const filteredPlans = computed(() => {
  if (!searchKeyword.value) return testPlans.value
  return testPlans.value.filter(plan => 
    plan.name.toLowerCase().includes(searchKeyword.value.toLowerCase())
  )
})

const selectedPlan = computed(() => 
  testPlans.value.find(plan => plan.id.toString() === selectedPlanId.value)
)

// 方法
const createNewPlan = () => {
  dialogVisible.value = true
}

const submitPlan = async (plan) => {
  // TODO: 实现提交测试计划的逻辑
  console.log('提交测试计划:', plan)
  ElMessage.success('测试计划创建成功')
}

const handlePlanSelect = (index) => {
  selectedPlanId.value = index
}

const handleSearch = (keyword) => {
  searchKeyword.value = keyword
}

const viewGroupDetail = (group) => {
  // TODO: 实现查看测试组详情的逻辑
  console.log('查看测试组详情:', group)
}
</script>

<style scoped>
.group-execution-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 20px;
}

.operation-bar {
  margin-bottom: 20px;
  display: flex;
  gap: 10px;
}

.main-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}
</style> 