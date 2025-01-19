<template>
  <div class="group-execution-container">
    <!-- 顶部操作栏 -->
    <div class="operation-bar">
      <el-button type="primary" @click="createNewPlan" :loading="isLoading">
        <el-icon><Plus /></el-icon>新建测试计划
      </el-button>
      <el-button type="success" @click="startGroupTest" :disabled="!selectedPlan || isLoading">
        <el-icon><VideoPlay /></el-icon>开始组测试
      </el-button>
      <el-button type="warning" @click="stopGroupTest" :disabled="!isTestRunning || isLoading">
        <el-icon><VideoPause /></el-icon>停止测试
      </el-button>
    </div>

    <el-container class="main-content">
      <!-- 左侧测试计划列表 -->
      <PlanList
        :plans="filteredPlans"
        :selected-plan-id="selectedPlanId"
        :loading="isLoading"
        @select="handlePlanSelect"
        @search="handleSearch"
        @delete="handlePlanDelete"
      />

      <!-- 右侧测试组详情 -->
      <GroupDetail
        v-if="selectedPlan"
        :plan="selectedPlan"
        :is-test-running="isTestRunning"
        :loading="isLoading"
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
import { ref, computed, onMounted } from 'vue'
import { Plus, VideoPlay, VideoPause } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import PlanList from './components/PlanList.vue'
import GroupDetail from './components/GroupDetail.vue'
import PlanDialog from './components/PlanDialog.vue'
import { useGroupTest } from './composables/useGroupTest'
import request from '@/utils/request'

defineOptions({
  name: 'GroupExecution'
})

// 状态数据
const selectedPlanId = ref('')
const searchKeyword = ref('')
const dialogVisible = ref(false)
const truthTables = ref([])
const testPlans = ref([])
const isLoading = ref(false)  // 添加加载状态

// 使用组合式函数
const { isTestRunning, startGroupTest, stopGroupTest, runSingleGroup, removeGroup } = useGroupTest()

// 获取真值表数据
const fetchTruthTables = async () => {
  try {
    const response = await request({
      url: '/truth-tables',
      method: 'get'
    })
    truthTables.value = response.data.data.map(table => ({
      id: table.id,
      name: `${table.name}`
    }))
  } catch (error) {
    console.error('获取真值表失败:', error)
    ElMessage.error('获取真值表失败')
  }
}

// 获取测试计划列表
const fetchTestPlans = async () => {
  try {
    isLoading.value = true
    const response = await request({
      url: '/test-plans',
      method: 'get'
    })
    testPlans.value = response.data.data || []
  } catch (error) {
    console.error('获取测试计划列表失败:', error)
    ElMessage.error('获取测试计划列表失败')
  } finally {
    isLoading.value = false
  }
}

// 在组件挂载时获取数据
onMounted(() => {
  fetchTruthTables()
  fetchTestPlans()
})

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
  try {
    isLoading.value = true
    await request({
      url: '/test-plans',
      method: 'post',
      data: {
        name: plan.name,
        truth_table_id: plan.truth_table_id,
        description: plan.description,
        execution_mode: plan.execution_mode,
        failure_strategy: plan.failure_strategy
      }
    })
    ElMessage.success('测试计划创建成功')
    dialogVisible.value = false
    
    // 添加延时后再获取最新列表
    setTimeout(async () => {
      await fetchTestPlans()
      isLoading.value = false
    }, 1000)  // 延时1秒
  } catch (error) {
    console.error('创建测试计划失败:', error)
    ElMessage.error('创建测试计划失败')
    isLoading.value = false
  }
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

// 删除测试计划
const deletePlan = async (planId) => {
  try {
    await request({
      url: `/test-plans/${planId}`,
      method: 'delete'
    })
    ElMessage.success('测试计划删除成功')
    await fetchTestPlans()
    if (selectedPlanId.value === planId.toString()) {
      selectedPlanId.value = ''
    }
  } catch (error) {
    console.error('删除测试计划失败:', error)
    ElMessage.error('删除测试计划失败')
  }
}

// 在 PlanList 组件中添加删除事件监听
const handlePlanDelete = (planId) => {
  ElMessageBox.confirm(
    '确定要删除这个测试计划吗？',
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  )
    .then(() => {
      deletePlan(planId)
    })
    .catch(() => {
      // 用户点击取消
    })
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