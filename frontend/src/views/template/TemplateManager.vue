<template>
  <div class="template-manager">
    <!-- 当前编辑文件信息 -->
    <el-card class="current-file-card">
      <div class="current-file-info">
        <span class="label">当前编辑：</span>
        <template v-if="currentTemplate">
          <span class="value">{{ currentTemplate.name }}</span>
          <span class="sub-info">(图纸：{{ currentTemplate.drawingNo }}, 版本：V{{ currentTemplate.version }})</span>
        </template>
        <span v-else class="no-file">未选择真值表</span>
      </div>
    </el-card>

    <!-- 真值表列表（可折叠） -->
    <el-collapse v-model="isTemplateListExpanded" class="template-list-section">
      <el-collapse-item name="templateList">
        <template #title>
          <div class="collapse-header">
            <span>真值表管理</span>
          </div>
        </template>
        
        <el-card class="template-list-card" shadow="never">
          <template #header>
            <div class="card-header">
              <el-button type="primary" @click="showCreateDialog">新建真值表</el-button>
            </div>
          </template>

          <!-- 真值表列表 -->
          <el-table :data="templateList" style="width: 100%" height="250">
            <el-table-column prop="id" label="ID" width="180" />
            <el-table-column prop="drawingNo" label="图纸编号" width="180" />
            <el-table-column prop="version" label="版本" width="100" />
            <el-table-column prop="name" label="名称" />
            <el-table-column prop="updateTime" label="更新时间" width="180" />
            <el-table-column label="操作" width="150">
              <template #default="scope">
                <el-button type="primary" link @click="editTemplate(scope.row)">编辑</el-button>
                <el-button type="danger" link @click="deleteTemplate(scope.row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-collapse-item>
    </el-collapse>

    <!-- 真值表编辑区域 -->
    <el-card v-if="currentTemplate" class="template-edit-card">
      <template #header>
        <div class="card-header">
          <span>真值表编辑</span>
          <el-button type="primary" @click="addNewTestId">添加新测试ID</el-button>
        </div>
      </template>

      <!-- 按TestID分组的测试步骤 -->
      <el-collapse v-model="expandedTestIds" class="test-groups">
        <el-collapse-item 
          v-for="group in groupedTestSteps" 
          :key="group.testId" 
          :name="group.testId"
        >
          <template #title>
            <div class="test-group-header">
              <span class="test-id">测试ID: {{ group.testId }}</span>
              <span class="step-count">({{ group.steps.length }} 个步骤)</span>
            </div>
          </template>

          <!-- 测试步骤表格 -->
          <div class="test-group-content">
            <div class="group-actions">
              <el-button type="primary" link @click="addStepToGroup(group.testId)">
                添加步骤
              </el-button>
            </div>

            <el-table :data="group.steps" border style="width: 100%">
              <el-table-column label="步骤序号" width="90">
                <template #default="scope">
                  <span>{{ scope.$index + 1 }}</span>
                </template>
              </el-table-column>
              
              <el-table-column label="步骤描述" width="200">
                <template #default="scope">
                  <el-input v-model="scope.row.description" placeholder="步骤描述"/>
                </template>
              </el-table-column>

              <el-table-column label="预期输入" width="200">
                <template #default="scope">
                  <el-select v-model="scope.row.expectedInput" multiple placeholder="选择输入点位">
                    <el-option
                      v-for="point in inputPoints"
                      :key="point.id"
                      :label="point.name"
                      :value="point.id"
                    />
                  </el-select>
                </template>
              </el-table-column>

              <el-table-column label="预期输出" width="200">
                <template #default="scope">
                  <el-select v-model="scope.row.expectedOutput" multiple placeholder="选择输出点位">
                    <el-option
                      v-for="point in outputPoints"
                      :key="point.id"
                      :label="point.name"
                      :value="point.id"
                    />
                  </el-select>
                </template>
              </el-table-column>

              <el-table-column label="延时(ms)" width="120">
                <template #default="scope">
                  <el-input-number 
                    v-model="scope.row.delay" 
                    :min="0" 
                    :step="100"
                    placeholder="延时"/>
                </template>
              </el-table-column>

              <el-table-column label="操作" width="150">
                <template #default="scope">
                  <el-button-group>
                    <el-button 
                      type="primary" 
                      :icon="ArrowUp"
                      @click="moveStepInGroup(group.testId, scope.$index, 'up')"
                      :disabled="scope.$index === 0"/>
                    <el-button 
                      type="primary" 
                      :icon="ArrowDown"
                      @click="moveStepInGroup(group.testId, scope.$index, 'down')"
                      :disabled="scope.$index === group.steps.length - 1"/>
                    <el-button 
                      type="danger" 
                      :icon="Delete"
                      @click="removeStepFromGroup(group.testId, scope.$index)"/>
                  </el-button-group>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-collapse-item>
      </el-collapse>

      <!-- 保存按钮 -->
      <div class="actions">
        <el-button type="primary" @click="saveTemplate">保存</el-button>
      </div>
    </el-card>

    <!-- 新建真值表对话框 -->
    <el-dialog
      v-model="createDialog.visible"
      title="新建真值表"
      width="500px"
    >
      <el-form :model="createDialog.form" label-width="100px">
        <el-form-item label="图纸编号" required>
          <el-select
            v-model="createDialog.form.drawingNo"
            placeholder="请选择图纸"
            @change="handleDrawingSelect"
          >
            <el-option
              v-for="drawing in drawingList"
              :key="drawing.id"
              :label="drawing.drawingNo"
              :value="drawing.drawingNo"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="版本" required>
          <el-input v-model="createDialog.form.version" placeholder="请输入版本号"/>
        </el-form-item>
        <el-form-item label="名称" required>
          <el-input v-model="createDialog.form.name" placeholder="请输入真值表名称"/>
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="createDialog.form.description"
            type="textarea"
            placeholder="请输入描述信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="createDialog.visible = false">取消</el-button>
          <el-button type="primary" @click="createTemplate">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowUp, ArrowDown, Delete } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// 真值表列表
const templateList = ref([
  {
    id: 1,
    drawingNo: 'DWG-001',
    version: '1.0',
    name: '测试模板1',
    updateTime: '2023-12-09 10:00:00'
  },
  {
    id: 2,
    drawingNo: 'DWG-002',
    version: '1.0',
    name: '测试模板2',
    updateTime: '2023-12-09 11:00:00'
  }
])

// 当前编辑的真值表
const currentTemplate = ref(null)
// 测试步骤数据
const testSteps = ref([
  {
    testId: 'TEST001',
    description: '初始状态检查',
    expectedInput: ['IN1', 'IN2'],
    expectedOutput: ['OUT1'],
    delay: 1000
  },
  {
    testId: 'TEST001',
    description: '执行操作1',
    expectedInput: ['IN3'],
    expectedOutput: ['OUT2', 'OUT3'],
    delay: 500
  },
  {
    testId: 'TEST002',
    description: '状态验证',
    expectedInput: ['IN4'],
    expectedOutput: ['OUT4'],
    delay: 1000
  }
])

// 图纸列表
const drawingList = ref([
  {
    id: 1,
    drawingNo: 'DWG-001',
    name: '图纸1'
  },
  {
    id: 2,
    drawingNo: 'DWG-002',
    name: '图纸2'
  }
])

// 折叠状态
const isTemplateListExpanded = ref(['templateList'])
// 展开的测试ID
const expandedTestIds = ref([])

// 新建对话框数据
const createDialog = ref({
  visible: false,
  form: {
    drawingNo: '',
    version: '',
    name: '',
    description: ''
  }
})

// 按testId分组的测试步骤
const groupedTestSteps = computed(() => {
  const groups = {}
  testSteps.value.forEach(step => {
    if (!groups[step.testId]) {
      groups[step.testId] = {
        testId: step.testId,
        steps: []
      }
    }
    groups[step.testId].steps.push(step)
  })
  return Object.values(groups).sort((a, b) => a.testId.localeCompare(b.testId))
})

// 模拟的输入输出点位数据
const inputPoints = ref([
  { id: 'IN1', name: '输入点1' },
  { id: 'IN2', name: '输入点2' },
  { id: 'IN3', name: '输入点3' },
  { id: 'IN4', name: '输入点4' }
])

const outputPoints = ref([
  { id: 'OUT1', name: '输出点1' },
  { id: 'OUT2', name: '输出点2' },
  { id: 'OUT3', name: '输出点3' },
  { id: 'OUT4', name: '输出点4' }
])

// 添加新的测试ID组
const addNewTestId = () => {
  const newTestId = `T${groupedTestSteps.value.length + 1}`
  testSteps.value.push({
    testId: newTestId,
    description: '',
    expectedInput: [],
    expectedOutput: [],
    delay: 100
  })
  expandedTestIds.value.push(newTestId)
}

// 向指定组添加步骤
const addStepToGroup = (testId) => {
  testSteps.value.push({
    testId,
    description: '',
    expectedInput: [],
    expectedOutput: [],
    delay: 100
  })
}

// 在组内移动步骤
const moveStepInGroup = (testId, index, direction) => {
  const groupSteps = groupedTestSteps.value.find(g => g.testId === testId).steps
  if (direction === 'up' && index > 0) {
    [groupSteps[index], groupSteps[index - 1]] = [groupSteps[index - 1], groupSteps[index]]
  } else if (direction === 'down' && index < groupSteps.length - 1) {
    [groupSteps[index], groupSteps[index + 1]] = [groupSteps[index + 1], groupSteps[index]]
  }
}

// 从组中删除步骤
const removeStepFromGroup = (testId, index) => {
  const groupIndex = testSteps.value.findIndex(step => 
    step.testId === testId && 
    step === groupedTestSteps.value.find(g => g.testId === testId).steps[index]
  )
  if (groupIndex > -1) {
    testSteps.value.splice(groupIndex, 1)
  }
}

// 显示新建对话框
const showCreateDialog = () => {
  createDialog.value.visible = true
  createDialog.value.form = {
    drawingNo: '',
    version: '',
    name: '',
    description: ''
  }
}

// 创建新真值表
const createTemplate = async () => {
  try {
    const { drawingNo, version, name, description } = createDialog.value.form
    
    // 验证必填字段
    if (!drawingNo || !version || !name) {
      ElMessage.error('请填写必填字段')
      return
    }

    // TODO: 调用API创建真值表
    const newTemplate = {
      id: `${drawingNo}-V${version}`,
      drawingNo,
      version,
      name,
      description,
      updateTime: new Date().toLocaleString()
    }

    templateList.value.unshift(newTemplate)
    createDialog.value.visible = false
    ElMessage.success('创建成功')
    
    // 自动切换到编辑模式
    currentTemplate.value = newTemplate
    testSteps.value = []
  } catch (error) {
    console.error('创建真值表失败:', error)
    ElMessage.error('创建失败: ' + error.message)
  }
}

// 编辑真值表
const editTemplate = (template) => {
  currentTemplate.value = template
  // TODO: 加载真值表的测试步骤数据
  loadTestSteps(template.id)
}

// 删除真值表
const deleteTemplate = async (template) => {
  try {
    await ElMessageBox.confirm('确定要删除该真值表吗？', '提示', {
      type: 'warning'
    })
    // TODO: 调用API删除真值表
    const index = templateList.value.findIndex(t => t.id === template.id)
    if (index > -1) {
      templateList.value.splice(index, 1)
    }
    if (currentTemplate.value?.id === template.id) {
      currentTemplate.value = null
      testSteps.value = []
    }
    ElMessage.success('删除成功')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除真值表失败:', error)
      ElMessage.error('删除失败: ' + error.message)
    }
  }
}

// 加载测试步骤数据
const loadTestSteps = async (templateId) => {
  try {
    // TODO: 调用API获取测试步骤数据
    testSteps.value = []
  } catch (error) {
    console.error('加载测试步骤失败:', error)
    ElMessage.error('加载失败: ' + error.message)
  }
}

// 图纸选择处理
const handleDrawingSelect = (drawingNo) => {
  const drawing = drawingList.value.find(d => d.drawingNo === drawingNo)
  if (drawing) {
    createDialog.value.form.name = `${drawing.drawingNo}测试模板`
  }
}

// 保存模板
const saveTemplate = async () => {
  try {
    if (!currentTemplate.value) {
      ElMessage.error('请先选择或创建真值表')
      return
    }

    if (testSteps.value.length === 0) {
      ElMessage.error('请至少添加一个测试步骤')
      return
    }

    // 验证每个测试步骤
    for (const step of testSteps.value) {
      if (!step.testId) {
        ElMessage.error('每个步骤都需要测试ID')
        return
      }
      if (step.expectedInput.length === 0 && step.expectedOutput.length === 0) {
        ElMessage.error('每个步骤都需要至少一个输入或输出点位')
        return
      }
    }

    // TODO: 调用API保存模板
    console.log('保存模板:', {
      template: currentTemplate.value,
      steps: testSteps.value
    })
    
    ElMessage.success('保存成功')
  } catch (error) {
    console.error('保存模板失败:', error)
    ElMessage.error('保存失败: ' + error.message)
  }
}

// 初始化数据
const initData = async () => {
  try {
    // TODO: 这里应该调用后端API获取数据
    // const response = await fetch('/api/templates')
    // templateList.value = await response.json()
    console.log('初始化数据完成')
  } catch (error) {
    ElMessage.error('获取数据失败：' + error.message)
  }
}

// 组件挂载时获取数据
onMounted(() => {
  initData()
})
</script>

<style scoped>
.template-manager {
  padding: 20px;
}

.current-file-card {
  margin-bottom: 20px;
}

.current-file-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.current-file-info .label {
  font-weight: bold;
}

.current-file-info .value {
  color: #409EFF;
}

.current-file-info .sub-info {
  color: #909399;
  font-size: 14px;
}

.current-file-info .no-file {
  color: #909399;
  font-style: italic;
}

.template-list-section {
  margin-bottom: 20px;
}

.template-edit-card {
  margin-bottom: 20px;
}

.test-groups {
  margin-top: 20px;
}

.test-group-header {
  display: flex;
  align-items: center;
  gap: 10px;
}

.test-group-header .test-id {
  font-weight: bold;
}

.test-group-header .step-count {
  color: #909399;
  font-size: 14px;
}

.test-group-content {
  padding: 10px 0;
}

.group-actions {
  margin-bottom: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.actions {
  margin-top: 20px;
  text-align: right;
}

:deep(.el-collapse-item__header) {
  padding: 0 20px;
}

:deep(.el-collapse-item__content) {
  padding: 0;
}

:deep(.el-card.template-list-card) {
  border: none;
  margin: 0;
}

:deep(.el-card.template-list-card .el-card__header) {
  padding: 10px 20px;
  border-top: 1px solid #EBEEF5;
}

:deep(.el-table) {
  margin-bottom: 20px;
}

:deep(.el-form-item) {
  margin-bottom: 20px;
}
</style> 