<template>
  <div class="user-manager">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" @click="handleAdd">添加用户</el-button>
        </div>
      </template>

      <!-- 用户列表 -->
      <el-table :data="users" style="width: 100%" v-loading="loading">
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="display_name" label="显示名称" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="role" label="角色">
          <template #default="scope">
            <el-tag :type="getRoleType(scope.row.role)">{{ getRoleLabel(scope.row.role) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag :type="scope.row.status === 'active' ? 'success' : 'danger'">
              {{ scope.row.status === 'active' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button 
              size="small" 
              type="danger" 
              @click="handleDelete(scope.row)"
              :disabled="scope.row.username === 'root'"
            >删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加/编辑用户对话框 -->
    <el-dialog 
      :title="dialogType === 'add' ? '添加用户' : '编辑用户'" 
      v-model="dialogVisible"
      width="500px"
    >
      <el-form :model="userForm" :rules="rules" ref="userFormRef" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" :disabled="dialogType === 'edit'" />
        </el-form-item>
        <el-form-item label="显示名称" prop="display_name">
          <el-input v-model="userForm.display_name" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="dialogType === 'add'">
          <el-input v-model="userForm.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role" style="width: 100%">
            <el-option label="管理员" value="admin" />
            <el-option label="普通用户" value="user" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="userForm.status" style="width: 100%">
            <el-option label="启用" value="active" />
            <el-option label="禁用" value="inactive" />
          </el-select>
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
import api from '../utils/api'
import { useUserStore } from '../stores/user'

export default {
  name: 'UserManager',
  setup() {
    const userStore = useUserStore()
    const users = ref([])
    const loading = ref(false)
    const dialogVisible = ref(false)
    const dialogType = ref('add')
    const userFormRef = ref(null)

    const userForm = ref({
      username: '',
      display_name: '',
      email: '',
      password: '',
      role: 'user',
      status: 'active'
    })

    const rules = {
      username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
      ],
      display_name: [
        { required: true, message: '请输入显示名称', trigger: 'blur' }
      ],
      email: [
        { required: true, message: '请输入邮箱地址', trigger: 'blur' },
        { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
      ],
      password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 6, message: '密码长度不能小于6个字符', trigger: 'blur' }
      ],
      role: [
        { required: true, message: '请选择角色', trigger: 'change' }
      ],
      status: [
        { required: true, message: '请选择状态', trigger: 'change' }
      ]
    }

    // 获取用户列表
    const fetchUsers = async () => {
      loading.value = true
      try {
        const response = await api.get('/users')
        if (response.data.code === 200) {
          users.value = response.data.data
        } else {
          ElMessage.error(response.data.message || '获取用户列表失败')
        }
      } catch (error) {
        console.error('获取用户列表失败:', error)
        ElMessage.error(error.response?.data?.message || '获取用户列表失败')
      } finally {
        loading.value = false
      }
    }

    // 添加用户
    const handleAdd = () => {
      dialogType.value = 'add'
      userForm.value = {
        username: '',
        display_name: '',
        email: '',
        password: '',
        role: 'user',
        status: 'active'
      }
      dialogVisible.value = true
    }

    // 编辑用户
    const handleEdit = (row) => {
      dialogType.value = 'edit'
      userForm.value = { ...row }
      dialogVisible.value = true
    }

    // 删除用户
    const handleDelete = (row) => {
      if (row.username === 'root') {
        ElMessage.warning('不能删除root用户')
        return
      }

      ElMessageBox.confirm(
        `确定要删除用户 ${row.username} 吗？`,
        '警告',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).then(async () => {
        try {
          const response = await api.delete(`/users/${row.id}`)
          if (response.data.code === 200) {
            ElMessage.success('删除成功')
            fetchUsers()
          } else {
            ElMessage.error(response.data.message || '删除失败')
          }
        } catch (error) {
          console.error('删除用户失败:', error)
          ElMessage.error(error.response?.data?.message || '删除失败')
        }
      })
    }

    // 提交表单
    const handleSubmit = async () => {
      if (!userFormRef.value) return

      await userFormRef.value.validate(async (valid) => {
        if (valid) {
          try {
            let response
            if (dialogType.value === 'add') {
              console.log('准备创建用户:', userForm.value)
              response = await api.post('/users', userForm.value)
            } else {
              console.log('准备更新用户:', userForm.value)
              response = await api.put(`/users/${userForm.value.id}`, userForm.value)
            }

            if (response.data.code === 200) {
              ElMessage.success(dialogType.value === 'add' ? '添加成功' : '更新成功')
              dialogVisible.value = false
              fetchUsers()
            } else {
              ElMessage.error(response.data.message || (dialogType.value === 'add' ? '添加失败' : '更新失败'))
            }
          } catch (error) {
            console.error('操作失败:', error)
            ElMessage.error(error.response?.data?.message || (dialogType.value === 'add' ? '添加失败' : '更新失败'))
          }
        }
      })
    }

    // 获取角色标签类型
    const getRoleType = (role) => {
      const types = {
        admin: 'danger',
        user: 'info'
      }
      return types[role] || 'info'
    }

    // 获取角色显示文本
    const getRoleLabel = (role) => {
      const labels = {
        admin: '管理员',
        user: '普通用户'
      }
      return labels[role] || role
    }

    onMounted(() => {
      fetchUsers()
    })

    return {
      users,
      loading,
      dialogVisible,
      dialogType,
      userForm,
      userFormRef,
      rules,
      handleAdd,
      handleEdit,
      handleDelete,
      handleSubmit,
      getRoleType,
      getRoleLabel
    }
  }
}
</script>

<style scoped>
.user-manager {
  padding: 20px;
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