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
      <!-- 上方：真值表管理区域 -->
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

      <!-- 下方：编辑区域和备选资源的左右布局 -->
      <div class="bottom-section">
        <!-- 左侧：真值表编辑区域 -->
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
                    <span>真值表编辑</span>
                    <div class="header-actions">
                      <el-button-group>
                        <el-button type="primary" @click="addNewTestId">新建测试组</el-button>
                        <el-button type="success" @click="addNewStep">添加步骤</el-button>
                      </el-button-group>
                      <el-button type="primary" @click="saveTemplate">保存</el-button>
                    </div>
                  </div>
                </template>

                <!-- 表格式编辑区域 -->
                <div class="table-editor">
                  <!-- 表头 -->
                  <div class="table-header">
                    <table>
                      <thead>
                        <tr>
                          <th class="column-testid">测试ID</th>
                          <th class="column-step">步骤</th>
                          <th class="column-desc">描述</th>
                          <th class="column-input">预期输入</th>
                          <th class="column-output">预期输出</th>
                          <th class="column-delay">延时(ms)</th>
                          <th class="column-actions">操作</th>
                        </tr>
                      </thead>
                    </table>
                  </div>

                  <!-- 表格内容 -->
                  <div class="table-body">
                    <table>
                      <tbody>
                        <template v-for="(group, groupIndex) in groupedSteps" :key="group.testId">
                          <!-- 测试组标题行 -->
                          <tr class="group-header" :class="{ 'expanded': isGroupExpanded(group.testId) }">
                            <td class="column-testid">
                              <div class="group-title" @click="toggleGroup(group.testId)">
                                <el-icon class="expand-icon">
                                  <component :is="isGroupExpanded(group.testId) ? 'ArrowDown' : 'ArrowRight'" />
                                </el-icon>
                                <span>{{ group.testId }}</span>
                                <span class="step-count">({{ group.steps.length }}步)</span>
                              </div>
                            </td>
                            <td class="column-step"></td>
                            <td class="column-desc"></td>
                            <td class="column-input"></td>
                            <td class="column-output"></td>
                            <td class="column-delay"></td>
                            <td class="column-actions">
                              <el-button-group>
                                <el-button 
                                  type="primary" 
                                  link 
                                  size="small"
                                  @click="addStepToGroup(group.testId)"
                                >
                                  添加步骤
                                </el-button>
                                <el-button 
                                  type="danger" 
                                  link 
                                  size="small"
                                  @click="deleteGroup(group.testId)"
                                >
                                  删除组
                                </el-button>
                              </el-button-group>
                            </td>
                          </tr>
                          <!-- 步骤行 -->
                          <template v-if="isGroupExpanded(group.testId)">
                            <tr 
                              v-for="(step, stepIndex) in group.steps" 
                              :key="stepIndex"
                              class="step-row"
                            >
                              <td class="column-testid">
                                <div class="step-indent"></div>
                              </td>
                              <td class="column-step">{{ stepIndex + 1 }}</td>
                              <td class="column-desc">
                                <el-input 
                                  v-model="step.description" 
                                  placeholder="步骤描述"
                                  size="small"
                                />
                              </td>
                              <td class="column-input">
                                <el-select 
                                  v-model="step.expectedInput" 
                                  multiple 
                                  placeholder="选择输入点位"
                                  size="small"
                                >
                                  <el-option
                                    v-for="point in inputPoints"
                                    :key="point.id"
                                    :label="point.name"
                                    :value="point.id"
                                  />
                                </el-select>
                              </td>
                              <td class="column-output">
                                <el-select 
                                  v-model="step.expectedOutput" 
                                  multiple 
                                  placeholder="选择输出点位"
                                  size="small"
                                >
                                  <el-option
                                    v-for="point in outputPoints"
                                    :key="point.id"
                                    :label="point.name"
                                    :value="point.id"
                                  />
                                </el-select>
                              </td>
                              <td class="column-delay">
                                <el-input-number 
                                  v-model="step.delay" 
                                  :min="0" 
                                  :step="100"
                                  controls-position="right"
                                  size="small"
                                />
                              </td>
                              <td class="column-actions">
                                <el-button-group>
                                  <el-button 
                                    type="primary" 
                                    :icon="ArrowUp"
                                    size="small"
                                    @click="moveStep(groupIndex, stepIndex, 'up')"
                                    :disabled="stepIndex === 0"
                                  />
                                  <el-button 
                                    type="primary" 
                                    :icon="ArrowDown"
                                    size="small"
                                    @click="moveStep(groupIndex, stepIndex, 'down')"
                                    :disabled="stepIndex === group.steps.length - 1"
                                  />
                                  <el-button 
                                    type="danger" 
                                    :icon="Delete"
                                    size="small"
                                    @click="deleteStep(groupIndex, stepIndex)"
                                  />
                                </el-button-group>
                              </td>
                            </tr>
                          </template>
                        </template>
                      </tbody>
                    </table>
                  </div>
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

        <!-- 右侧：备选资源区域 -->
        <el-collapse v-model="isResourceSectionExpanded" class="resource-section">
          <el-collapse-item name="resourceSection">
            <template #title>
              <div class="collapse-header">
                <span>备选资源</span>
              </div>
            </template>
            
            <el-card class="resource-card" shadow="never">
              <template #header>
                <div class="card-header">
                  <span>资源配置</span>
                  <el-button type="primary" @click="addNewResource">添加资源</el-button>
                </div>
              </template>

              <!-- 资源列表 -->
              <el-table :data="resourceList" border style="width: 100%">
                <el-table-column prop="id" label="资源ID" width="100" />
                <el-table-column prop="name" label="资源名称" width="150" />
                <el-table-column prop="type" label="类型" width="100" />
                <el-table-column prop="description" label="描述" />
                <el-table-column label="操作" width="150">
                  <template #default="scope">
                    <el-button-group>
                      <el-button 
                        type="primary" 
                        link 
                        @click="editResource(scope.row)"
                      >
                        编辑
                      </el-button>
                      <el-button 
                        type="danger" 
                        link 
                        @click="deleteResource(scope.row)"
                      >
                        删除
                      </el-button>
                    </el-button-group>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-collapse-item>
        </el-collapse>
      </div>
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

// 当前编辑的真值表 - 添加默认值用于测试
const currentTemplate = ref({
  id: 1,
  drawingNo: 'DWG-001',
  version: '1.0',
  name: '测试模板1',
  updateTime: '2023-12-09 10:00:00'
})

// 测试步骤数据 - 添加测试数据
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

// 输入输出点位
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

// 分组后的测试步骤
const groupedSteps = computed(() => {
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
  return Object.values(groups)
})

// 折叠面板的展开状态
const isTemplateListExpanded = ref(['templateList'])  // 真值表管理默认展开
const isEditSectionExpanded = ref(['editSection'])    // 真值表编辑默认展开
const isResourceSectionExpanded = ref(['resourceSection'])  // 备选资源默认展开

// 展开的测试组
const expandedGroups = ref(new Set(['TEST001', 'TEST002']))  // 所有测试组默认展开

// 检查组是否展开
const isGroupExpanded = (testId) => {
  return expandedGroups.value.has(testId)
}

// 切换组的展开状态
const toggleGroup = (testId) => {
  if (expandedGroups.value.has(testId)) {
    expandedGroups.value.delete(testId)
  } else {
    expandedGroups.value.add(testId)
  }
}

// 添加新的测试组
const addNewTestId = () => {
  const newTestId = `TEST${String(groupedSteps.value.length + 1).padStart(3, '0')}`
  testSteps.value.push({
    testId: newTestId,
    description: '新步骤',
    expectedInput: [],
    expectedOutput: [],
    delay: 1000
  })
  expandedGroups.value.add(newTestId)
}

// 添加新步骤到指定组
const addStepToGroup = (testId) => {
  testSteps.value.push({
    testId,
    description: '新步骤',
    expectedInput: [],
    expectedOutput: [],
    delay: 1000
  })
}

// 添加新步骤（添加到最后一个组）
const addNewStep = () => {
  if (groupedSteps.value.length === 0) {
    addNewTestId()
  } else {
    const lastGroup = groupedSteps.value[groupedSteps.value.length - 1]
    addStepToGroup(lastGroup.testId)
  }
}

// 移动步骤
const moveStep = (groupIndex, stepIndex, direction) => {
  const group = groupedSteps.value[groupIndex]
  if (!group) return

  if (direction === 'up' && stepIndex > 0) {
    const steps = group.steps
    ;[steps[stepIndex], steps[stepIndex - 1]] = [steps[stepIndex - 1], steps[stepIndex]]
  } else if (direction === 'down' && stepIndex < group.steps.length - 1) {
    const steps = group.steps
    ;[steps[stepIndex], steps[stepIndex + 1]] = [steps[stepIndex + 1], steps[stepIndex]]
  }
}

// 删除步骤
const deleteStep = (groupIndex, stepIndex) => {
  const group = groupedSteps.value[groupIndex]
  if (!group) return

  group.steps.splice(stepIndex, 1)
  if (group.steps.length === 0) {
    deleteGroup(group.testId)
  }
}

// 删除测试组
const deleteGroup = (testId) => {
  ElMessageBox.confirm(
    `确定要删除测试组"${testId}"吗？`,
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    testSteps.value = testSteps.value.filter(step => step.testId !== testId)
    expandedGroups.value.delete(testId)
    ElMessage.success('删除成功')
  }).catch(() => {
    // 取消删除
  })
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
  expandedGroups.value.add('TEST001')
}

// 显示创建对话框
const showCreateDialog = () => {
  createDialog.value.visible = true
}

// 处理图纸选择
const handleDrawingSelect = () => {
  // TODO: 根据选择的图纸加载相关信息
}

// 创建真值表
const createTemplate = () => {
  // TODO: 实现创建真值表的逻辑
  ElMessage.success('创建成功（模拟）')
  createDialog.value.visible = false
}

// 保存真值表
const saveTemplate = () => {
  // TODO: 实现保存真值表的逻辑
  ElMessage.success('保存成功（模拟）')
}
</script>

<style scoped>
.template-manager {
  padding: 20px;
}

.main-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.template-list-section {
  width: 100%;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.bottom-section {
  display: flex;
  gap: 20px;
  min-height: 600px;
}

.edit-section {
  width: 75%;  /* 使用百分比替代flex */
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.resource-section {
  width: 25%;  /* 使用百分比替代flex */
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

/* 优化表格部样式 */
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

.header-actions {
  display: flex;
  gap: 10px;
}

.spreadsheet-view {
  overflow-x: auto;
}

.test-id-cell {
  display: flex;
  align-items: center;
  gap: 5px;
}

/* 确保表格内的输入框和选择器样式正确 */
:deep(.el-input__inner) {
  padding: 0 8px;
}

:deep(.el-select) {
  width: 100%;
}

:deep(.el-table .cell) {
  padding: 8px;
}

.table-editor {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  overflow: hidden;
}

.table-header {
  background-color: #f5f7fa;
  border-bottom: 1px solid #dcdfe6;
}

.table-body {
  overflow-y: auto;
  max-height: calc(100vh - 300px);
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 8px;
  border: 1px solid #dcdfe6;
  text-align: left;
}

th {
  font-weight: bold;
  background-color: #f5f7fa;
}

.column-testid { width: 150px; }
.column-step { width: 80px; }
.column-desc { width: 200px; }
.column-input { width: 200px; }
.column-output { width: 200px; }
.column-delay { width: 120px; }
.column-actions { width: 150px; }

.group-header {
  background-color: #f5f7fa;
}

.group-title {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 0;
}

.expand-icon {
  transition: transform 0.3s;
}

.group-header.expanded .expand-icon {
  transform: rotate(90deg);
}

.step-indent {
  padding-left: 24px;
}

.step-count {
  color: #909399;
  font-size: 12px;
}

.step-row:hover {
  background-color: #f5f7fa;
}

/* 确保表格内的输入控件样式正确 */
:deep(.el-input__inner),
:deep(.el-select),
:deep(.el-input-number) {
  width: 100%;
}

:deep(.el-select .el-input__inner) {
  padding: 0 8px;
}

:deep(.el-input-number .el-input__inner) {
  text-align: center;
}
</style> 