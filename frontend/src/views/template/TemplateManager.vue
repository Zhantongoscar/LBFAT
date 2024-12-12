<template>
  <div class="template-manager">
    <!-- 当前编辑文件信息 -->
    <el-card class="current-file-card">
      <div class="current-file-info">
        <span class="label">当前编辑：</span>
        <template v-if="currentTemplate">
          <span class="value">{{ currentTemplate.name }}</span>
          <span class="sub-info">(图纸：{{ currentTemplate.drawingNo }}, 版本：V{{ currentTemplate.version }})</span>
          <span class="update-time">最后更新：{{ currentTemplate.updateTime }}</span>
        </template>
        <span v-else class="no-file">未选择真值表</span>
        <div class="action-buttons">
          <el-button type="primary" size="small" @click="showOpenDialog">打开其他</el-button>
          <el-button type="success" size="small" @click="showCreateDialog">新建真值表</el-button>
        </div>
      </div>
    </el-card>

    <div class="main-content">
      <!-- 编辑区域 -->
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
                      <el-button type="primary" @click="addNewTestGroup">新建测试组</el-button>
                    </el-button-group>
                    <el-button type="primary" @click="saveTemplate">保存</el-button>
                  </div>
                </div>
              </template>

              <!-- 测试组编辑区域 -->
              <div class="test-groups">
                <el-collapse v-model="expandedGroups">
                  <el-collapse-item
                    v-for="group in testGroups"
                    :key="group.testId"
                    :name="group.testId"
                  >
                    <template #title>
                      <div class="group-header">
                        <span class="group-title">
                          {{ group.description }}
                        </span>
                        <el-tag 
                          :type="group.level === 1 ? 'danger' : ''"
                          size="small"
                          @click.stop="editGroupLevel(group)"
                        >
                          {{ group.level === 1 ? '安全类' : '普通类' }}
                        </el-tag>
                      </div>
                    </template>

                    <!-- 测试组内容 -->
                    <div class="group-content">
                      <div class="group-actions">
                        <el-button-group>
                          <el-button 
                            type="primary" 
                            link 
                            @click="addTestItem(group.testId)"
                          >
                            添加测试项
                          </el-button>
                          <el-button 
                            type="danger" 
                            link 
                            @click="deleteGroup(group.testId)"
                          >
                            删除组
                          </el-button>
                        </el-button-group>
                      </div>

                      <!-- 测试项表格 -->
                      <el-table :data="group.items" border style="width: 100%">
                        <!-- 设备选择 -->
                        <el-table-column label="设备" width="180">
                          <template #default="scope">
                            <el-select 
                              v-model="scope.row.deviceId"
                              placeholder="选择设备"
                              @change="handleDeviceChange(scope.row)"
                            >
                              <el-option
                                v-for="device in deviceList"
                                :key="device.id"
                                :label="device.name"
                                :value="device.id"
                              />
                            </el-select>
                          </template>
                        </el-table-column>

                        <!-- 单元选择 -->
                        <el-table-column label="单元" width="180">
                          <template #default="scope">
                            <el-select 
                              v-model="scope.row.unitId"
                              placeholder="选择单元"
                              :disabled="!scope.row.deviceId"
                              @change="handleUnitChange(scope.row)"
                            >
                              <el-option
                                v-for="unit in getAvailableUnits(scope.row.deviceId)"
                                :key="unit.id"
                                :label="unit.name"
                                :value="unit.id"
                              />
                            </el-select>
                          </template>
                        </el-table-column>

                        <!-- 设定值/期待值 -->
                        <el-table-column label="设定值/期待值" width="180">
                          <template #default="scope">
                            <el-input-number
                              v-if="isOutputType(scope.row.unitType)"
                              v-model="scope.row.setValue"
                              :precision="2"
                              placeholder="设定值"
                            />
                            <el-input-number
                              v-else
                              v-model="scope.row.expectedValue"
                              :precision="2"
                              placeholder="期待值"
                            />
                          </template>
                        </el-table-column>

                        <!-- 使能状态 -->
                        <el-table-column label="使能" width="80">
                          <template #default="scope">
                            <el-switch v-model="scope.row.enabled" />
                          </template>
                        </el-table-column>

                        <!-- 描述 -->
                        <el-table-column label="描述" min-width="200">
                          <template #default="scope">
                            <el-input 
                              v-model="scope.row.description" 
                              type="textarea"
                              :rows="2"
                              placeholder="请输入测试项描述"
                            />
                          </template>
                        </el-table-column>

                        <!-- 错误提示列（仅DI/AI类型显示） -->
                        <el-table-column label="错误提示" min-width="200" v-if="hasInputTypeItems">
                          <template #default="scope">
                            <el-input 
                              v-if="scope.row.unitType === 'DI' || scope.row.unitType === 'AI'"
                              v-model="scope.row.errorMessage" 
                              type="textarea"
                              :rows="2"
                              placeholder="当采集值与预期不符时的错误提示"
                            />
                          </template>
                        </el-table-column>

                        <!-- 故障详情 -->
                        <el-table-column label="故障详情" min-width="200">
                          <template #default="scope">
                            <el-input 
                              v-model="scope.row.faultDetails" 
                              type="textarea"
                              :rows="2"
                              placeholder="故障原因分析和处理建议"
                            />
                          </template>
                        </el-table-column>

                        <!-- 操作 -->
                        <el-table-column label="操作" width="120" fixed="right">
                          <template #default="scope">
                            <el-button 
                              type="danger" 
                              link
                              @click="deleteTestItem(group.testId, scope.$index)"
                            >
                              删除
                            </el-button>
                          </template>
                        </el-table-column>
                      </el-table>
                    </div>
                  </el-collapse-item>
                </el-collapse>
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

    <!-- 新建测试组对话框 -->
    <el-dialog
      v-model="groupDialog.visible"
      :title="groupDialog.isEdit ? '编辑测试组' : '新建测试组'"
      width="500px"
    >
      <el-form :model="groupDialog.form" label-width="100px">
        <el-form-item label="测试ID" required>
          <el-input-number 
            v-model="groupDialog.form.testId" 
            :min="1"
            placeholder="请输入测试ID"
          />
        </el-form-item>
        <el-form-item label="测试级别" required>
          <el-select v-model="groupDialog.form.level">
            <el-option :value="1" label="安全类" />
            <el-option :value="2" label="普通类" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="groupDialog.form.description"
            type="textarea"
            placeholder="请输入描述信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="groupDialog.visible = false">取消</el-button>
          <el-button type="primary" @click="saveTestGroup">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 打开文件对话框 -->
    <el-dialog
      v-model="openDialog.visible"
      title="打开真值表"
      width="600px"
    >
      <el-table :data="recentTemplates" style="width: 100%">
        <el-table-column prop="drawingNo" label="图纸编号" width="120" />
        <el-table-column prop="version" label="版本号" width="100" />
        <el-table-column prop="name" label="名称" />
        <el-table-column prop="updateTime" label="更新时间" width="160" />
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button type="primary" link @click="openTemplate(row)">打开</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// 折叠面板状态
const isTemplateListExpanded = ref(['templateList'])
const isEditSectionExpanded = ref(['editSection'])
const isResourceSectionExpanded = ref(['resourceSection'])

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

// 当前模板
const currentTemplate = ref({
  id: 1,
  drawingNo: 'DWG-001',
  version: '1.0',
  name: '测试模板1',
  updateTime: '2023-12-09 10:00:00'
})

// 测试组相关
const expandedGroups = ref(new Set())
const testGroups = ref([
  {
    testId: 1,
    level: 1, // 安全类
    description: '安全开关检查组',
    items: [
      {
        deviceId: 'device1',
        unitId: 'DI1',
        unitType: 'DI',
        expectedValue: 1,
        enabled: true,
        description: '安全开关检查',
        errorMessage: '安全开关状态异常，请检查开关位置是否正确',
        faultDetails: '1. 检查安全开关物理连接\n2. 检查安全回路是否完整\n3. 检查控制电源是否正常'
      }
    ]
  },
  {
    testId: 2,
    level: 2, // 普���类
    description: '电机控制测试组',
    items: [
      {
        deviceId: 'device1',
        unitId: 'DO1',
        unitType: 'DO',
        setValue: 1,
        enabled: true,
        description: '启动电机',
        faultDetails: '检查电机启动电路和控制回路'
      },
      {
        deviceId: 'device1',
        unitId: 'DI2',
        unitType: 'DI',
        expectedValue: 1,
        enabled: true,
        description: '检查电机运行状态',
        errorMessage: '电机未按预期运行，请检查电机控制回路',
        faultDetails: '1. 检查电机运行反馈信号\n2. 检查电机过载保护状态\n3. 检查变频器运行状态'
      },
      {
        deviceId: 'device1',
        unitId: 'AI1',
        unitType: 'AI',
        expectedValue: 220,
        enabled: true,
        description: '检查电机电压',
        errorMessage: '电机电压异常，请检查供电是否正常',
        faultDetails: '1. 检查供电电压是否正常\n2. 检查电压采集回路\n3. 检查变频器输出电压'
      }
    ]
  }
])

// 设备和单元相关
const deviceList = ref([
  { id: 'device1', name: 'EDB4-1', type: 'EDB' },
  { id: 'device2', name: 'EDB4-2', type: 'EDB' }
])

const unitTypes = {
  INPUT: ['DI', 'AI'],
  OUTPUT: ['DO', 'AO']
}

// 对话框状��
const groupDialog = ref({
  visible: false,
  isEdit: false,
  editingGroup: null,
  form: {
    testId: null,
    level: 2,
    description: ''
  }
})

// 图纸列表
const drawingList = ref([
  { id: 1, drawingNo: 'DWG-001', name: '图纸1' },
  { id: 2, drawingNo: 'DWG-002', name: '图纸2' }
])

// 创建对话框状态
const createDialog = ref({
  visible: false,
  form: {
    drawingNo: '',
    version: '',
    name: '',
    description: ''
  }
})

// 资源列表
const resourceList = ref([
  { id: 'RES001', name: '资源1', type: 'DI', description: '数字输入资源' },
  { id: 'RES002', name: '资源2', type: 'DO', description: '数字输出资源' }
])

// 打开文件对话框状态
const openDialog = ref({
  visible: false
})

// 最近使用的模板列表
const recentTemplates = ref([
  {
    id: 1,
    drawingNo: 'DWG-001',
    version: '1.0',
    name: '测试模板1',
    updateTime: '2024-01-20 10:00:00'
  },
  {
    id: 2,
    drawingNo: 'DWG-002',
    version: '1.0',
    name: '测试模板2',
    updateTime: '2024-01-20 11:00:00'
  }
])

// 基本操作函数
const showCreateDialog = () => {
  createDialog.value.visible = true
}

const editTemplate = (template) => {
  currentTemplate.value = template
  // 默认展开第一个测试组
  if (testGroups.value.length > 0) {
    expandedGroups.value.add(testGroups.value[0].testId)
  }
}

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
    const index = templateList.value.findIndex(t => t.id === template.id)
    if (index !== -1) {
      templateList.value.splice(index, 1)
      if (currentTemplate.value?.id === template.id) {
        currentTemplate.value = null
      }
    }
  })
}

// 编辑组级别
const editGroupLevel = (group) => {
  group.level = group.level === 1 ? 2 : 1
}

// 编辑组
const editGroup = (group) => {
  groupDialog.value.isEdit = true
  groupDialog.value.form = {
    testId: group.testId,
    level: group.level,
    description: group.description
  }
  groupDialog.value.editingGroup = group
  groupDialog.value.visible = true
}

// 保存测试组
const saveTestGroup = () => {
  const { testId, level, description } = groupDialog.value.form
  
  if (groupDialog.value.isEdit) {
    // 编辑已有组
    const group = groupDialog.value.editingGroup
    group.testId = testId
    group.level = level
    group.description = description
  } else {
    // 创建新组
    testGroups.value.push({
      testId,
      level,
      description,
      items: []
    })
    expandedGroups.value.add(testId)
  }
  
  groupDialog.value.visible = false
  groupDialog.value.editingGroup = null
}

// 添加测试项
const addTestItem = (testId) => {
  const group = testGroups.value.find(g => g.testId === testId)
  if (group) {
    group.items.push({
      deviceId: '',
      unitId: '',
      unitType: '',
      setValue: null,
      expectedValue: null,
      enabled: true,
      description: '',
      errorMessage: '',
      faultDetails: ''
    })
  }
}

// 删除测试项
const deleteTestItem = (testId, itemIndex) => {
  const group = testGroups.value.find(g => g.testId === testId)
  if (group) {
    group.items.splice(itemIndex, 1)
  }
}

// 设备和单元选择处理
const handleDeviceChange = (row) => {
  row.unitId = ''
  row.unitType = ''
}

const handleUnitChange = (row) => {
  const unit = getAvailableUnits().find(u => u.id === row.unitId)
  if (unit) {
    row.unitType = unit.type
    row.setValue = null
    row.expectedValue = null
  }
}

const getAvailableUnits = (deviceId) => {
  // 这里应该根据设备类型返回对应的单元列表
  return [
    { id: 'DI1', name: 'DI1', type: 'DI' },
    { id: 'DI2', name: 'DI2', type: 'DI' },
    { id: 'DO1', name: 'DO1', type: 'DO' },
    { id: 'DO2', name: 'DO2', type: 'DO' },
    { id: 'AI1', name: 'AI1', type: 'AI' },
    { id: 'AO1', name: 'AO1', type: 'AO' }
  ]
}

const isOutputType = (unitType) => {
  return unitTypes.OUTPUT.includes(unitType)
}

// 资源操作
const addNewResource = () => {
  // TODO: 实现添加资源的逻辑
  ElMessage.info('添加资源功能开发中')
}

const editResource = (resource) => {
  // TODO: 实现编辑资源的逻辑
  ElMessage.info('编辑资源功能开发中')
}

const deleteResource = (resource) => {
  ElMessageBox.confirm(
    `确定要删除资源"${resource.name}"吗？`,
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    const index = resourceList.value.findIndex(r => r.id === resource.id)
    if (index !== -1) {
      resourceList.value.splice(index, 1)
    }
  })
}

// 创建真值表
const createTemplate = () => {
  const { drawingNo, version, name, description } = createDialog.value.form
  const newTemplate = {
    id: templateList.value.length + 1,
    drawingNo,
    version,
    name,
    description,
    updateTime: new Date().toLocaleString()
  }
  templateList.value.push(newTemplate)
  createDialog.value.visible = false
  editTemplate(newTemplate)
}

// 处理图纸选择
const handleDrawingSelect = () => {
  const drawing = drawingList.value.find(d => d.drawingNo === createDialog.value.form.drawingNo)
  if (drawing) {
    createDialog.value.form.name = drawing.name
  }
}

// 检查是否有输入类型的测试项
const hasInputTypeItems = computed(() => {
  return testGroups.value.some(group => 
    group.items.some(item => 
      item.unitType === 'DI' || item.unitType === 'AI'
    )
  )
})

// 显示打开文件对话框
const showOpenDialog = () => {
  openDialog.value.visible = true
}

// 打开模板
const openTemplate = (template) => {
  currentTemplate.value = template
  openDialog.value.visible = false
  // 默认展开第一个测试组
  if (testGroups.value.length > 0) {
    expandedGroups.value.add(testGroups.value[0].testId)
  }
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
  font-size: 16px;
  margin-right: 10px;
}

.sub-info {
  color: #666;
  margin-right: 10px;
}

.update-time {
  color: #999;
  font-size: 14px;
}

.no-file {
  color: #999;
  font-style: italic;
}

.action-buttons {
  margin-left: auto;
  display: flex;
  gap: 10px;
}

.template-list-section {
  width: 100%;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.template-list-card {
  border: none;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
}

.bottom-section {
  display: flex;
  gap: 20px;
  margin-top: 20px;
}

.edit-section {
  width: 100%;
}

.edit-card {
  margin-bottom: 20px;
}

.group-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 10px;
}

.test-id {
  font-weight: bold;
  font-size: 14px;
  color: #303133;
}

.item-count {
  color: #909399;
  font-size: 12px;
}

.group-content {
  padding: 20px;
}

.group-actions {
  margin-bottom: 10px;
}

.error-message-input {
  margin-top: 8px;
}

.fault-details-input {
  width: 100%;
}

/* 确保表格内的输入控件样式正确 */
:deep(.el-input),
:deep(.el-select),
:deep(.el-input-number) {
  width: 100%;
}

/* 调整表格单元格的内边距 */
:deep(.el-table .cell) {
  padding: 12px 8px;
}

/* 优化文本域的显示 */
:deep(.el-textarea__inner) {
  font-size: 13px;
  line-height: 1.4;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.custom-tree-node {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding-right: 8px;
}

.unit-type {
  font-size: 12px;
  padding: 2px 6px;
  background-color: #f0f0f0;
  border-radius: 4px;
  color: #666;
}

.resource-card :deep(.el-tree-node__content) {
  height: 32px;
}

.resource-card :deep(.el-tree-node.is-dragging .el-tree-node__content) {
  background-color: #f5f7fa;
  opacity: 0.8;
}

.resource-card :deep(.el-tree-node.is-drop-inner > .el-tree-node__content) {
  background-color: #e6f1fc;
}
</style> 