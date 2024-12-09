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

    <div class="main-content">
      <!-- 左侧：真值表管理 -->
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

      <!-- 右侧：真值表编辑区域 -->
      <el-collapse v-model="isEditSectionExpanded" class="edit-section">
        <el-collapse-item name="editSection">
          <template #title>
            <div class="collapse-header">
              <span>真值表编辑</span>
            </div>
          </template>

          <template v-if="currentTemplate">
            <el-card class="edit-card" shadow="never">
              <template #header>
                <div class="card-header">
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

            <!-- 真值表编译区域 -->
            <el-card class="compile-card">
              <template #header>
                <div class="card-header">
                  <span>真值表编译</span>
                  <div class="compile-actions">
                    <el-button type="primary" @click="compileTemplate">编译</el-button>
                    <el-button type="success" @click="exportCompiledTemplate">导出</el-button>
                  </div>
                </div>
              </template>

              <!-- 编译结果展示 -->
              <div class="compile-result">
                <el-tabs v-model="activeCompileTab">
                  <!-- JSON格式 -->
                  <el-tab-pane label="JSON格式" name="json">
                    <el-input
                      v-model="compiledJson"
                      type="textarea"
                      :rows="10"
                      readonly
                      placeholder="编译后的JSON格式"
                    />
                  </el-tab-pane>
                  
                  <!-- 表格格式 -->
                  <el-tab-pane label="表格格式" name="table">
                    <el-table :data="compiledTable" border style="width: 100%">
                      <el-table-column prop="testId" label="测试ID" width="120" />
                      <el-table-column prop="step" label="步骤" width="80" />
                      <el-table-column prop="description" label="描述" width="200" />
                      <el-table-column prop="inputs" label="输入点位">
                        <template #default="{ row }">
                          <el-tag 
                            v-for="input in row.inputs" 
                            :key="input"
                            size="small"
                            class="mx-1"
                          >
                            {{ input }}
                          </el-tag>
                        </template>
                      </el-table-column>
                      <el-table-column prop="outputs" label="输出点位">
                        <template #default="{ row }">
                          <el-tag 
                            v-for="output in row.outputs" 
                            :key="output"
                            type="success"
                            size="small"
                            class="mx-1"
                          >
                            {{ output }}
                          </el-tag>
                        </template>
                      </el-table-column>
                      <el-table-column prop="delay" label="延时(ms)" width="100" />
                    </el-table>
                  </el-tab-pane>
                </el-tabs>
              </div>
            </el-card>
          </template>
          <el-empty v-else description="请选择要编辑的真值表" />
        </el-collapse-item>
      </el-collapse>
    </div>

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
  const newTestId = `TEST${String(groupedTestSteps.value.length + 1).padStart(3, '0')}`
  testSteps.value.push({
    testId: newTestId,
    description: '新测试步骤',
    expectedInput: [],
    expectedOutput: [],
    delay: 1000
  })
  expandedTestIds.value.push(newTestId)
}

// 添加步骤到组
const addStepToGroup = (testId) => {
  testSteps.value.push({
    testId,
    description: '新步骤',
    expectedInput: [],
    expectedOutput: [],
    delay: 1000
  })
}

// 在组内移动步骤
const moveStepInGroup = (testId, index, direction) => {
  const groupSteps = testSteps.value.filter(step => step.testId === testId)
  if (direction === 'up' && index > 0) {
    const temp = groupSteps[index]
    groupSteps[index] = groupSteps[index - 1]
    groupSteps[index - 1] = temp
    // 更新原数组
    testSteps.value = testSteps.value.map(step => 
      step.testId === testId ? groupSteps.shift() : step
    )
  } else if (direction === 'down' && index < groupSteps.length - 1) {
    const temp = groupSteps[index]
    groupSteps[index] = groupSteps[index + 1]
    groupSteps[index + 1] = temp
    // 更新原数组
    testSteps.value = testSteps.value.map(step => 
      step.testId === testId ? groupSteps.shift() : step
    )
  }
}

// 从组中删除步骤
const removeStepFromGroup = (testId, index) => {
  const stepIndex = testSteps.value.findIndex((step, i) => 
    step.testId === testId && i === index
  )
  if (stepIndex !== -1) {
    testSteps.value.splice(stepIndex, 1)
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
  // 模拟加载该模板的测试步骤
  testSteps.value = [
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
  ]
  // 默认展开第一个测试组
  expandedTestIds.value = ['TEST001']
}

// 删除真值表
const deleteTemplate = (template) => {
  ElMessageBox.confirm(
    `确定要删除真值表"${template.name}"吗？`,
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    templateList.value = templateList.value.filter(t => t.id !== template.id)
    if (currentTemplate.value?.id === template.id) {
      currentTemplate.value = null
      testSteps.value = []
    }
    ElMessage.success('删除成功')
  }).catch(() => {
    // 取消删除
  })
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
const saveTemplate = () => {
  ElMessage.success('保存成功（模拟）')
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

// 编译相关的状态
const activeCompileTab = ref('json')
const compiledJson = ref('')
const compiledTable = ref([])

// 编译真值表
const compileTemplate = () => {
  try {
    // 将测试步骤转换为编译格式
    const compiled = testSteps.value.map((step, index) => ({
      testId: step.testId,
      step: index + 1,
      description: step.description,
      inputs: step.expectedInput,
      outputs: step.expectedOutput,
      delay: step.delay
    }))
    
    // 更新编译结果
    compiledTable.value = compiled
    compiledJson.value = JSON.stringify(compiled, null, 2)
    
    ElMessage.success('编译成功')
  } catch (error) {
    ElMessage.error('编译失败：' + error.message)
  }
}

// 导出编译后的真值表
const exportCompiledTemplate = () => {
  try {
    const data = compiledJson.value
    const blob = new Blob([data], { type: 'application/json' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${currentTemplate.value.name}_compiled.json`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (error) {
    ElMessage.error('导出失败：' + error.message)
  }
}

// 编辑区域的展开状态
const isEditSectionExpanded = ref(['editSection'])
</script>

<style scoped>
.template-manager {
  padding: 20px;
}

.main-content {
  display: flex;
  gap: 20px;
  margin-top: 20px;
}

.template-list-section {
  flex: 1;
  min-width: 300px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.edit-section {
  flex: 2;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.current-file-card {
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.current-file-info {
  display: flex;
  align-items: center;
  padding: 10px;
}

.label {
  font-weight: bold;
  margin-right: 10px;
}

.value {
  color: #409EFF;
  margin-right: 10px;
}

.sub-info {
  color: #909399;
}

.no-file {
  color: #909399;
  font-style: italic;
}

.template-list-card {
  border: none;
}

.template-edit-card {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
}

.test-groups {
  margin-top: 20px;
}

.test-group-header {
  display: flex;
  align-items: center;
}

.test-id {
  font-weight: bold;
  margin-right: 10px;
}

.step-count {
  color: #909399;
}

.test-group-content {
  padding: 20px;
}

.group-actions {
  margin-bottom: 10px;
}

.actions {
  margin-top: 20px;
  text-align: right;
  padding: 0 20px 20px;
}

/* 添加过渡动画 */
.el-collapse-item__wrap {
  will-change: height;
  transition: height 0.3s ease-in-out;
}

.el-table {
  margin-top: 10px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

/* 优化表格内部样式 */
.el-table th {
  background-color: #f5f7fa;
}

.el-table td {
  padding: 8px 0;
}

/* 优化按钮组样式 */
.el-button-group {
  .el-button {
    margin-left: 0;
  }
}

/* 优化折叠面板样式 */
.el-collapse {
  border: none;
  
  .el-collapse-item__header {
    padding: 0 20px;
    font-size: 16px;
    font-weight: bold;
  }
  
  .el-collapse-item__content {
    padding: 0;
  }
}

/* 编译区域样式 */
.compile-card {
  margin-top: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.compile-actions {
  display: flex;
  gap: 10px;
}

.compile-result {
  margin-top: 10px;
}

.mx-1 {
  margin: 0 5px;
}

/* 优化文本域样式 */
:deep(.el-textarea__inner) {
  font-family: monospace;
  font-size: 14px;
  line-height: 1.5;
  padding: 12px;
}

/* 编译结果标签样式 */
.el-tag {
  margin: 2px;
}
</style> 