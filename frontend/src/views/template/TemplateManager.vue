<!-- 真值表管理页面 -->
<template>
  <div class="truth-table-manager">
    <el-card class="list-card">
      <template #header>
        <div class="card-header">
          <span>真值表列表</span>
          <el-button type="primary" @click="showCreateDialog">新建真值表</el-button>
        </div>
      </template>

      <!-- 真值表列表 -->
      <el-table :data="truthTables" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="名称" />
        <el-table-column label="图纸编号" width="120">
          <template #default="{ row }">
            {{ getDrawingNumber(row.drawing_id) }}
          </template>
        </el-table-column>
        <el-table-column prop="version" label="版本" width="100" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="updated_at" label="更新时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.updated_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button-group>
              <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
              <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
            </el-button-group>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

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
          <el-select v-model="form.drawing_id" placeholder="请选择图纸">
            <el-option
              v-for="drawing in drawings"
              :key="drawing.id"
              :label="drawing.drawing_number"
              :value="drawing.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="版本" prop="version">
          <el-input v-model="form.version" placeholder="请输入版本号" />
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
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '@/utils/api'

export default {
  name: 'TruthTableManager',
  setup() {
    // 真值表数据
    const truthTables = ref([])
    const drawings = ref([])
    const loading = ref(false)

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
      version: [{ required: true, message: '请输入版本号', trigger: 'blur' }]
    }

    // 获取真值表列表
    const fetchTruthTables = async () => {
      loading.value = true
      try {
        const res = await api.get('/api/truth-tables')
        truthTables.value = res.data.data
      } catch (error) {
        console.error('获取真值表列表失败:', error)
        ElMessage.error('获取真值表列表失败')
      } finally {
        loading.value = false
      }
    }

    // 获取图纸列表
    const fetchDrawings = async () => {
      try {
        const res = await api.get('/api/drawings')
        drawings.value = res.data.data
      } catch (error) {
        console.error('获取图纸列表失败:', error)
        ElMessage.error('获取图纸列表失败')
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
      dialogVisible.value = true
    }

    // 显示编辑对话框
    const handleEdit = (row) => {
      isEdit.value = true
      dialogTitle.value = '编辑真值表'
      form.value = { ...row }
      dialogVisible.value = true
    }

    // 处理删除
    const handleDelete = async (row) => {
      try {
        await ElMessageBox.confirm('确定要删除这个真值表吗？', '提示', {
          type: 'warning'
        })
        await api.delete(`/api/truth-tables/${row.id}`)
        ElMessage.success('删除成功')
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

        if (isEdit.value) {
          await api.put(`/api/truth-tables/${form.value.id}`, form.value)
          ElMessage.success('更新成功')
        } else {
          await api.post('/api/truth-tables', form.value)
          ElMessage.success('创建成功')
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
      const drawing = drawings.value.find(d => d.id === drawingId)
      return drawing ? drawing.drawing_number : '-'
    }

    // 格式化日期
    const formatDate = (date) => {
      return new Date(date).toLocaleString()
    }

    onMounted(() => {
      fetchTruthTables()
      fetchDrawings()
    })

    return {
      // 数据
      truthTables,
      drawings,
      loading,

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
      getDrawingNumber,
      formatDate
    }
  }
}
</script>

<style scoped>
.truth-table-manager {
  padding: 20px;
}

.list-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 