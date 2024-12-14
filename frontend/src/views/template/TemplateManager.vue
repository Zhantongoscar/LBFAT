<!-- 真值表管理页面 -->
<template>
  <div class="truth-table-manager">
    <el-container direction="vertical">
      <!-- 上部分：真值表列表和当前真值表信息 -->
      <el-container style="height: 300px;">
        <!-- 左侧真值表列表 -->
        <el-main class="list-container" style="width: 70%;">
          <el-card class="list-card">
            <template #header>
              <div class="card-header">
                <div class="header-left">
                  <el-button 
                    type="text" 
                    @click="isCollapse = !isCollapse"
                  >
                    <el-icon>
                      <component :is="isCollapse ? 'ArrowRight' : 'ArrowDown'" />
                    </el-icon>
                    真值表列表
                  </el-button>
                </div>
                <el-button type="primary" @click="showCreateDialog">新建真值表</el-button>
              </div>
            </template>

            <!-- 真值表列表 -->
            <el-collapse-transition>
              <div v-show="!isCollapse">
                <el-table 
                  :data="truthTables" 
                  style="width: 100%" 
                  v-loading="loading"
                  highlight-current-row
                  @current-change="handleCurrentChange"
                  :row-class-name="tableRowClassName"
                  max-height="200"
                >
                  <el-table-column prop="name" label="名称" />
                  <el-table-column label="图纸编号" width="120">
                    <template #default="{ row }">
                      {{ getDrawingNumber(row.drawing_id) }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="version" label="版本" width="80" />
                  <el-table-column label="操作" width="120" fixed="right">
                    <template #default="{ row }">
                      <el-button-group>
                        <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
                        <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
                      </el-button-group>
                    </template>
                  </el-table-column>
                </el-table>
              </div>
            </el-collapse-transition>
          </el-card>
        </el-main>

        <!-- 右侧当前真值表信息 -->
        <el-aside width="30%" class="info-container">
          <el-card v-if="currentTable" class="current-table-card">
            <template #header>
              <div class="card-header">
                <span>当前真值表</span>
              </div>
            </template>
            <div class="current-table-info">
              <div class="info-item">
                <label>名称：</label>
                <span>{{ currentTable.name }}</span>
              </div>
              <div class="info-item">
                <label>图纸编号：</label>
                <span>{{ getDrawingNumber(currentTable.drawing_id) }}</span>
              </div>
              <div class="info-item">
                <label>版本：</label>
                <span>{{ currentTable.version }}</span>
              </div>
              <div class="info-item">
                <label>描述：</label>
                <span>{{ currentTable.description || '-' }}</span>
              </div>
              <div class="info-item">
                <label>更新时间：</label>
                <span>{{ formatDate(currentTable.updated_at) }}</span>
              </div>
            </div>
          </el-card>
          <el-empty v-else description="未选择真值表" />
        </el-aside>
      </el-container>

      <!-- 下部分：编辑工作区 -->
      <el-main class="edit-container">
        <el-card v-if="currentTable" class="edit-card">
          <template #header>
            <div class="card-header">
              <span>编辑工作区 - {{ currentTable.name }}</span>
              <div class="header-actions">
                <el-button type="primary" size="small">保存</el-button>
                <el-tooltip
                  content="切换到测试执行界面"
                  placement="top"
                >
                  <el-button 
                    type="success" 
                    size="small"
                    @click="handleRunTest"
                  >
                    运行测试
                  </el-button>
                </el-tooltip>
              </div>
            </div>
          </template>
          <!-- 这里添加真值表编辑的具体内容 -->
          <div class="edit-area">
            <div class="groups-header">
              <h3>测试组列表</h3>
              <el-button type="primary" size="small" @click="handleAddGroup">
                添加测试组
              </el-button>
            </div>
            
            <!-- 测试组列表 -->
            <el-table :data="testGroups" style="width: 100%">
              <el-table-column prop="test_id" label="测试ID" width="120" />
              <el-table-column prop="level" label="级别" width="80">
                <template #default="{ row }">
                  <el-tag :type="row.level === 1 ? 'success' : 'warning'">
                    {{ row.level }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="description" label="描述" />
              <el-table-column prop="sequence" label="序号" width="80" />
              <el-table-column type="expand">
                <template #default="{ row }">
                  <div class="test-items-container">
                    <div class="items-header">
                      <h4>测试项列表</h4>
                      <el-button type="primary" size="small" @click="handleAddItem(row)">
                        添加测试项
                      </el-button>
                    </div>
                    <el-table :data="row.items || []" style="width: 100%">
                      <el-table-column prop="action" label="动作" width="120" />
                      <el-table-column prop="expected_result" label="预期结果" />
                      <el-table-column prop="sequence" label="序号" width="80" />
                      <el-table-column label="操作" width="200" fixed="right">
                        <template #default="scope">
                          <el-button-group>
                            <el-button type="primary" size="small" @click="handleEditItem(row, scope.row)">
                              编辑
                            </el-button>
                            <el-button type="danger" size="small" @click="handleDeleteItem(row, scope.row)">
                              删除
                            </el-button>
                          </el-button-group>
                        </template>
                      </el-table-column>
                    </el-table>
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button-group>
                    <el-button type="primary" size="small" @click="handleEditGroup(row)">
                      编辑
                    </el-button>
                    <el-button type="danger" size="small" @click="handleDeleteGroup(row)">
                      删除
                    </el-button>
                  </el-button-group>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-card>
        <el-empty v-else description="请选择一个真值表进行编辑" />
      </el-main>
    </el-container>

    <!-- 真值表新建/编辑对话框 -->
    <el-dialog
      :title="dialogTitle"
      v-model="dialogVisible"
      width="60%"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入真值表名称" />
        </el-form-item>
        <el-form-item label="图纸" prop="drawing_id">
          <el-select 
            v-model="form.drawing_id" 
            placeholder="请选择图纸"
            @change="handleDrawingChange"
            filterable
          >
            <el-option
              v-for="drawing in availableDrawings"
              :key="drawing.id"
              :label="drawing.drawing_number"
              :value="drawing.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="版本" prop="version">
          <el-select 
            v-model="form.version" 
            placeholder="请选择版本"
            :disabled="!form.drawing_id"
          >
            <el-option
              v-for="version in availableVersions"
              :key="version"
              :label="version"
              :value="version"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            rows="3"
            placeholder="请输入描述信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 测试组编辑对话框 -->
    <el-dialog
      :title="editingGroup ? '编辑测试组' : '新建测试组'"
      v-model="groupDialogVisible"
      width="50%"
    >
      <el-form ref="groupFormRef" :model="groupForm" :rules="groupRules" label-width="100px">
        <el-form-item label="测试ID" prop="test_id">
          <el-input v-model="groupForm.test_id" placeholder="请输入测试ID" />
        </el-form-item>
        <el-form-item label="级别" prop="level">
          <el-select v-model="groupForm.level" placeholder="请选择级别">
            <el-option :value="1" label="级别1" />
            <el-option :value="2" label="级别2" />
            <el-option :value="3" label="级别3" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="groupForm.description"
            type="textarea"
            rows="3"
            placeholder="请输入描述"
          />
        </el-form-item>
        <el-form-item label="序号" prop="sequence">
          <el-input-number v-model="groupForm.sequence" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="groupDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveGroup">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 测试项编辑对话框 -->
    <el-dialog
      :title="editingItem ? '编辑测试项' : '新建测试项'"
      v-model="itemDialogVisible"
      width="50%"
    >
      <el-form ref="itemFormRef" :model="itemForm" :rules="itemRules" label-width="100px">
        <el-form-item label="动作" prop="action">
          <el-input v-model="itemForm.action" placeholder="请输入测试动作" />
        </el-form-item>
        <el-form-item label="预期结果" prop="expected_result">
          <el-input
            v-model="itemForm.expected_result"
            type="textarea"
            rows="3"
            placeholder="请输入预期结果"
          />
        </el-form-item>
        <el-form-item label="序号" prop="sequence">
          <el-input-number v-model="itemForm.sequence" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="itemDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveItem">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowDown, ArrowRight } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import { getAvailableDrawings, getTruthTables, createTruthTable, updateTruthTable, deleteTruthTable, createTestGroup, updateTestGroup, deleteTestGroup } from '@/api/truthTable'

export default {
  name: 'TruthTableManager',
  components: {
    ArrowDown,
    ArrowRight
  },
  setup() {
    const router = useRouter()
    
    // 真值表数据
    const truthTables = ref([])
    const availableDrawings = ref([])
    const availableVersions = ref([])
    const loading = ref(false)
    const isCollapse = ref(false)
    const currentTable = ref(null)

    // 对话框控制
    const dialogVisible = ref(false)
    const dialogTitle = ref('')
    const isEdit = ref(false)

    // 表单数据
    const formRef = ref(null)
    const form = ref({
      id: null,
      name: '',
      drawing_id: '',
      version: '',
      description: ''
    })

    // 表单验证规则
    const rules = {
      name: [{ required: true, message: '请输入真值表名称', trigger: 'blur' }],
      drawing_id: [{ required: true, message: '请选择图纸', trigger: 'change' }],
      version: [{ required: true, message: '请选择版本', trigger: 'change' }]
    }

    // 测试组数据
    const testGroups = ref([])
    const editingGroup = ref(null)
    const groupDialogVisible = ref(false)
    const groupForm = ref({
      id: null,
      test_id: '',
      level: 1,
      description: '',
      sequence: 0,
      items: []
    })

    // 测试组表单验证规则
    const groupRules = {
      test_id: [{ required: true, message: '请输入测试ID', trigger: 'blur' }],
      level: [{ required: true, message: '请选择测试级别', trigger: 'change' }],
      description: [{ required: true, message: '请输入描述', trigger: 'blur' }]
    }

    // 测试项数据
    const itemDialogVisible = ref(false)
    const editingItem = ref(null)
    const currentGroup = ref(null)
    const itemForm = ref({
      id: null,
      action: '',
      expected_result: '',
      sequence: 0
    })

    // 测试项表单验证规则
    const itemRules = {
      action: [{ required: true, message: '请输入测试动作', trigger: 'blur' }],
      expected_result: [{ required: true, message: '请输入预期结果', trigger: 'blur' }]
    }

    // 获取真值表列表
    const fetchTruthTables = async () => {
      loading.value = true
      try {
        const res = await getTruthTables()
        truthTables.value = res.data.data
        
        // 如果有上次选中的真值表ID，则选中对应行
        const lastSelectedId = localStorage.getItem('lastSelectedTruthTableId')
        if (lastSelectedId) {
          const table = truthTables.value.find(t => t.id === parseInt(lastSelectedId))
          if (table) {
            currentTable.value = table
          }
        }
      } catch (error) {
        console.error('获取真值表列表失败:', error)
        ElMessage.error('获取真值表列表失败')
      } finally {
        loading.value = false
      }
    }

    // 处理当前选中行变化
    const handleCurrentChange = (row) => {
      currentTable.value = row
      if (row) {
        localStorage.setItem('lastSelectedTruthTableId', row.id)
        fetchTestGroups(row.id)
      } else {
        testGroups.value = []
      }
    }

    // 设置表格行的类名
    const tableRowClassName = ({ row }) => {
      if (currentTable.value && row.id === currentTable.value.id) {
        return 'current-row'
      }
      return ''
    }

    // 获取可图纸列表
    const fetchAvailableDrawings = async () => {
      try {
        const res = await getAvailableDrawings()
        availableDrawings.value = res.data.data
      } catch (error) {
        console.error('获取可用图纸列表失败:', error)
        ElMessage.error('获取可用图纸列表失败')
      }
    }

    // 处理图纸选择变化
    const handleDrawingChange = (drawingId) => {
      form.value.version = '' // 清空版本选择
      if (drawingId) {
        const selectedDrawing = availableDrawings.value.find(d => d.id === drawingId)
        if (selectedDrawing) {
          // 获取选中图纸的所有版本
          const versions = availableDrawings.value
            .filter(d => d.drawing_number === selectedDrawing.drawing_number)
            .map(d => d.version)
          availableVersions.value = versions
        }
      } else {
        availableVersions.value = []
      }
    }

    // 显示创建对话框
    const showCreateDialog = () => {
      isEdit.value = false
      dialogTitle.value = '新建真值表'
      form.value = {
        id: null,
        name: '',
        drawing_id: '',
        version: '',
        description: ''
      }
      availableVersions.value = []
      dialogVisible.value = true
    }

    // 显示编辑对话框
    const handleEdit = (row) => {
      isEdit.value = true
      dialogTitle.value = '编辑真值表'
      form.value = { ...row }
      handleDrawingChange(row.drawing_id)
      dialogVisible.value = true
    }

    // 处理删除
    const handleDelete = async (row) => {
      try {
        await ElMessageBox.confirm('确定要删除这个真值表吗？', '提示', {
          type: 'warning'
        })
        await deleteTruthTable(row.id)
        ElMessage.success('删除成功')
        
        // 如果删除的是当前选中的真值表，清空选中状态
        if (currentTable.value && currentTable.value.id === row.id) {
          currentTable.value = null
          localStorage.removeItem('lastSelectedTruthTableId')
        }
        
        fetchTruthTables()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除真值表失败:', error)
          ElMessage.error('删除真值表失败')
        }
      }
    }

    // 提交表单
    const handleSubmit = async () => {
      if (!formRef.value) return

      try {
        await formRef.value.validate()

        // 处理表单数据，确保没有undefined值
        const formData = {
          id: form.value.id || null,
          name: form.value.name || '',
          drawing_id: form.value.drawing_id || null,
          version: form.value.version || '',
          description: form.value.description || ''
        }

        if (isEdit.value) {
          await updateTruthTable(formData.id, formData)
          ElMessage.success('更新成功')
        } else {
          const res = await createTruthTable(formData)
          ElMessage.success('创建成功')
          // 选中新创建的真值表
          currentTable.value = res.data.data
          localStorage.setItem('lastSelectedTruthTableId', res.data.data.id)
        }

        dialogVisible.value = false
        fetchTruthTables()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('保存真值表失败:', error)
          ElMessage.error('保存真值表失败')
        }
      }
    }

    // 获取图纸编号
    const getDrawingNumber = (drawingId) => {
      const drawing = availableDrawings.value.find(d => d.id === drawingId)
      return drawing ? drawing.drawing_number : '-'
    }

    // 格式化日期
    const formatDate = (date) => {
      return new Date(date).toLocaleString()
    }

    // 添加运行测试方法
    const handleRunTest = () => {
      if (!currentTable.value) return
      
      // 导航到测试执行界面，并传递真值表信息
      router.push({
        path: '/test/execution',
        query: {
          truthTableId: currentTable.value.id,
          name: currentTable.value.name,
          drawingId: currentTable.value.drawing_id,
          version: currentTable.value.version
        }
      })
    }

    // 获取真值表的测试组
    const fetchTestGroups = async (tableId) => {
      try {
        const res = await getTruthTable(tableId)
        testGroups.value = res.data.data.groups || []
      } catch (error) {
        console.error('获取测试组失败:', error)
        ElMessage.error('获取测试组失败')
      }
    }

    // 添加测试组
    const handleAddGroup = () => {
      editingGroup.value = null
      groupForm.value = {
        id: null,
        test_id: '',
        level: 1,
        description: '',
        sequence: testGroups.value.length,
        items: []
      }
      groupDialogVisible.value = true
    }

    // 编辑测试组
    const handleEditGroup = (group) => {
      editingGroup.value = group
      groupForm.value = { ...group }
      groupDialogVisible.value = true
    }

    // 删除测试组
    const handleDeleteGroup = async (group) => {
      try {
        await ElMessageBox.confirm('确定要删除这个测试组吗？', '提示', {
          type: 'warning'
        })
        
        await deleteTestGroup(group.id)
        const index = testGroups.value.findIndex(g => g.id === group.id)
        if (index > -1) {
          testGroups.value.splice(index, 1)
        }
        ElMessage.success('删除成功')
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除测试组失败:', error)
          ElMessage.error('删除测试组失败')
        }
      }
    }

    // 保存测试组
    const handleSaveGroup = async () => {
      if (!currentTable.value) {
        ElMessage.warning('请先选择真值表')
        return
      }

      try {
        // 构造保存数据
        const saveData = {
          ...groupForm.value,
          truth_table_id: currentTable.value.id,
          items: groupForm.value.items || []
        }

        let res
        if (editingGroup.value) {
          // 更新测试组
          res = await updateTestGroup(editingGroup.value.id, saveData)
          const index = testGroups.value.findIndex(g => g.id === editingGroup.value.id)
          if (index > -1) {
            testGroups.value[index] = res.data.data
          }
        } else {
          // 创建新测试组
          res = await createTestGroup(saveData)
          testGroups.value.push(res.data.data)
        }

        groupDialogVisible.value = false
        ElMessage.success(editingGroup.value ? '更新成功' : '创建成功')
      } catch (error) {
        console.error('保存测试组失败:', error)
        ElMessage.error('保存测试组失败')
      }
    }

    // 添加测试项
    const handleAddItem = (group) => {
      currentGroup.value = group
      editingItem.value = null
      itemForm.value = {
        id: null,
        action: '',
        expected_result: '',
        sequence: (group.items || []).length
      }
      itemDialogVisible.value = true
    }

    // 编辑测试项
    const handleEditItem = (group, item) => {
      currentGroup.value = group
      editingItem.value = item
      itemForm.value = { ...item }
      itemDialogVisible.value = true
    }

    // 删除测试项
    const handleDeleteItem = async (group, item) => {
      try {
        await ElMessageBox.confirm('确定要删除这个测试项吗？', '提示', {
          type: 'warning'
        })
        const index = group.items.findIndex(i => i.id === item.id)
        if (index > -1) {
          group.items.splice(index, 1)
        }
        ElMessage.success('删除成功')
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除测试项失败:', error)
          ElMessage.error('删除测试项失败')
        }
      }
    }

    // 保存测试项
    const handleSaveItem = async () => {
      if (!currentGroup.value) return
      
      if (!currentGroup.value.items) {
        currentGroup.value.items = []
      }
      
      if (editingItem.value) {
        const index = currentGroup.value.items.findIndex(i => i.id === editingItem.value.id)
        if (index > -1) {
          currentGroup.value.items[index] = { ...itemForm.value }
        }
      } else {
        currentGroup.value.items.push({ ...itemForm.value })
      }
      itemDialogVisible.value = false
      ElMessage.success('保存成功')
    }

    onMounted(() => {
      fetchTruthTables()
      fetchAvailableDrawings()
    })

    return {
      // 数据
      truthTables,
      availableDrawings,
      availableVersions,
      loading,
      isCollapse,
      currentTable,

      // 对话框
      dialogVisible,
      dialogTitle,
      form,
      formRef,
      rules,

      // 方法
      showCreateDialog,
      handleEdit,
      handleDelete,
      handleSubmit,
      handleDrawingChange,
      handleCurrentChange,
      tableRowClassName,
      getDrawingNumber,
      formatDate,
      handleRunTest,

      // 测试组数据
      testGroups,
      groupDialogVisible,
      groupForm,
      groupRules,
      handleAddGroup,
      handleEditGroup,
      handleDeleteGroup,
      handleSaveGroup,

      // 测试项数据
      itemDialogVisible,
      itemForm,
      itemRules,
      handleAddItem,
      handleEditItem,
      handleDeleteItem,
      handleSaveItem,
    }
  }
}
</script>

<style scoped>
.truth-table-manager {
  height: 100%;
  padding: 20px;
}

.el-container {
  background-color: #fff;
}

.list-container {
  padding: 0 10px 0 0;
  overflow: hidden;
}

.info-container {
  padding: 0 0 0 10px;
  overflow: hidden;
}

.edit-container {
  margin-top: 20px;
  padding: 0;
}

.list-card, .current-table-card, .edit-card {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.current-table-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-item {
  display: flex;
  gap: 8px;
}

.info-item label {
  color: #606266;
  font-weight: bold;
  min-width: 80px;
}

.edit-area {
  min-height: 400px;
}

:deep(.el-table .current-row) {
  background-color: #ecf5ff;
}

:deep(.el-button.el-button--text) {
  display: flex;
  align-items: center;
  gap: 4px;
}

:deep(.el-main) {
  padding: 0;
}

:deep(.el-card__body) {
  height: calc(100% - 60px);
  overflow-y: auto;
}

.groups-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.groups-header h3 {
  margin: 0;
}

.test-items-container {
  padding: 20px;
  background-color: #f5f7fa;
}

.items-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.items-header h4 {
  margin: 0;
  color: #606266;
}
</style> 