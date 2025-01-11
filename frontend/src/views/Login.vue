<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <h2>登录</h2>
      </template>
      <el-form ref="loginForm" :model="loginForm" :rules="rules" @submit.prevent="handleLogin">
        <el-form-item prop="username">
          <div class="input-wrapper">
            <i class="el-icon"><User /></i>
            <input
              v-model="loginForm.username"
              type="text"
              placeholder="用户名"
              autocomplete="off"
              class="custom-input"
            />
          </div>
        </el-form-item>
        <el-form-item prop="password">
          <div class="input-wrapper">
            <i class="el-icon"><Lock /></i>
            <input
              v-model="loginForm.password"
              type="password"
              placeholder="密码"
              autocomplete="off"
              class="custom-input"
            />
          </div>
        </el-form-item>
        <el-form-item>
          <div class="input-wrapper button-wrapper">
            <el-button type="primary" :loading="loading" @click="handleLogin">
              {{ loading ? '登录中...' : '登录' }}
            </el-button>
          </div>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import api from '../utils/api'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const loginForm = ref({
  username: '',
  password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  try {
    loading.value = true
    const response = await api.post('/users/login', loginForm.value)
    const { token, user } = response.data.data
    
    // 存储令牌和用户信息
    userStore.setToken(token)
    userStore.setUser(user)
    
    ElMessage.success('登录成功')
    
    // 根据用户角色重定向到不同页面
    const redirectPath = userStore.redirectPath || (user.role === 'admin' ? '/projects' : '/test/execution')
    userStore.setRedirectPath('')
    router.push(redirectPath)
  } catch (error) {
    console.error('登录失败:', error)
    ElMessage.error(error.response?.data?.message || '登录失败，请重试')
  } finally {
    loading.value = false
  }
}

// 初始化检查
onMounted(() => {
  // 清除可能存在的过期状态
  if (!localStorage.getItem('token')) {
    userStore.logout()
  }
  
  // 如果已经登录，根据角色重定向
  if (userStore.isAuthenticated && userStore.user) {
    router.push(userStore.isAdmin ? '/projects' : '/test/execution')
  }
})
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f5f7fa;
  background-image: linear-gradient(45deg, #f5f7fa 0%, #e4e7ed 100%);
}

.login-card {
  width: 400px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.login-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}

.login-card :deep(.el-card__header) {
  text-align: center;
  padding: 20px;
  border-bottom: 1px solid #ebeef5;
  background-color: #fff;
  border-radius: 8px 8px 0 0;
}

.login-card h2 {
  margin: 0;
  font-size: 24px;
  color: #303133;
  font-weight: 600;
}

.login-card :deep(.el-card__body) {
  padding: 20px;
}

.input-wrapper {
  display: flex;
  align-items: center;
  background: none;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 0 15px;
  transition: all 0.3s ease;
  margin-bottom: 20px;
  width: 360px;
}

.input-wrapper:hover {
  border-color: #c0c4cc;
}

.input-wrapper:focus-within {
  border-color: #409eff;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.1);
}

.el-icon {
  color: #909399;
  margin-right: 8px;
  font-size: 18px;
}

.custom-input {
  flex: 1;
  border: none;
  outline: none;
  height: 40px;
  line-height: 40px;
  padding: 0;
  font-size: 14px;
  color: #606266;
  background: none;
  width: 100%;
}

.custom-input::placeholder {
  color: #c0c4cc;
}

.button-wrapper {
  padding: 0;
  border: none;
  background: none;
  box-shadow: none;
  margin-bottom: 0;
  width: 120px;
  float: left;
}

.button-wrapper:hover {
  border: none;
}

:deep(.el-button) {
  height: 40px;
  font-size: 16px;
  font-weight: 500;
  border-radius: 4px;
  transition: all 0.3s ease;
  width: 120px;
  padding: 0;
}

:deep(.el-button:hover) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

:deep(.el-form-item) {
  margin-bottom: 20px;
}

:deep(.el-form-item__error) {
  padding-top: 4px;
  color: #f56c6c;
}

:deep(.el-form) {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding-left: 20px;
}
</style> 