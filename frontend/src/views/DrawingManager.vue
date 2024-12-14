<!-- 图纸管理页面 -->
<template>
  <div class="drawing-manager">
    <el-card class="list-card">
      <template #header>
        <div class="card-header">
          <span>图纸列表</span>
          <el-button type="primary" @click="showDrawingDialog">新建图纸</el-button>
        </div>
      </template>

      <!-- 图纸列表 -->
      <el-table :data="drawings" style="width: 100%" v-loading="loading">
        <el-table-column prop="drawing_number" label="图纸编号" width="150" />
        <el-table-column prop="version" label="版本号" width="100" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="created_at" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
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

    <!-- 图纸新建/编辑对话框 -->
    <el-dialog
      :title="dialogTitle"
      v-model="dialogVisible"
      width="50%"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="图纸编号" prop="drawing_number">
          <el-input v-model="form.drawing_number" placeholder="请输入图纸编号" />
        </el-form-item>
        <el-form-item label="版本号" prop="version">
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
  name: 'DrawingManager',
  setup() {
    // 数据列表
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
      drawing_number: '',
      version: '',
      description: ''
    })

    // 表单验证规则
    const rules = {
      drawing_number: [{ required: true, message: '请输入图纸编号', trigger: 'blur' }],
      version: [{ required: true, message: '请输入版本号', trigger: 'blur' }]
    }

    // 获取图纸列表
    const fetchDrawings = async () => {
      loading.value = true
      try {
        const res = await api.get('/api/drawings')
        drawings.value = res.data.data
      } catch (error) {
        console.error('获取图纸列表失败:', error)
        ElMessage.error('获取图纸列表失败')
      } finally {
        loading.value = false
      }
    }

    // 显示创建对话框
    const showDrawingDialog = () => {
      isEdit.value = false
      dialogTitle.value = '新建图纸'
      form.value = {
        id: null,
        drawing_number: '',
        version: '',
        description: ''
      }
      dialogVisible.value = true
    }

    // 显示编辑对话框
    const handleEdit = (row) => {
      isEdit.value = true
      dialogTitle.value = '编辑图纸'
      form.value = { ...row }
      dialogVisible.value = true
    }

    // 处理删除
    const handleDelete = async (row) => {
      try {
        await ElMessageBox.confirm('确定要删除这个图纸吗？', '提示', {
          type: 'warning',
          message: '删除图纸将同时删除与之关联的真值表，是否继续？'
        })
        await api.delete(`/api/drawings/${row.id}`)
        ElMessage.success('删除成功')
        fetchDrawings()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除图纸失败:', error)
          ElMessage.error('删除图纸失败')
        }
      }
    }

    // 提交表单
    const handleSubmit = async () => {
      if (!formRef.value) return

      try {
        await formRef.value.validate()

        if (isEdit.value) {
          await api.put(`/api/drawings/${form.value.id}`, form.value)
          ElMessage.success('更新成功')
        } else {
          await api.post('/api/drawings', form.value)
          ElMessage.success('创建成功')
        }

        dialogVisible.value = false
        fetchDrawings()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('保存图纸失败:', error)
          ElMessage.error('保存图纸失败')
        }
      }
    }

    // 格式化日期
    const formatDate = (date) => {
      return new Date(date).toLocaleString()
    }

    onMounted(() => {
      fetchDrawings()
    })

    return {
      drawings,
      loading,
      dialogVisible,
      dialogTitle,
      form,
      formRef,
      rules,
      showDrawingDialog,
      handleEdit,
      handleDelete,
      handleSubmit,
      formatDate
    }
  }
}
</script>

<style scoped>
.drawing-manager {
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