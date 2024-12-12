<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <h2>系统登录</h2>
      </template>
      
      <el-form 
        ref="loginForm"
        :model="formData"
        :rules="rules"
        label-width="80px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input 
            v-model="formData.username"
            placeholder="请输入用户名"
          />
        </el-form-item>
        
        <el-form-item label="密码" prop="password">
          <el-input 
            v-model="formData.password"
            type="password"
            placeholder="请输入密码"
            show-password
          />
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            @click="handleLogin"
            :loading="loading"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { ElMessage } from 'element-plus'
import axios from 'axios'

export default {
  name: 'Login',
  setup() {
    const router = useRouter()
    const userStore = useUserStore()
    const loginForm = ref(null)
    const loading = ref(false)
    
    // 配置 axios
    const axiosInstance = axios.create({
      baseURL: '/api',
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json'
      }
    })
    
    const formData = reactive({
      username: '',
      password: ''
    })
    
    const rules = {
      username: [
        { required: true, message: '请输入用户名', trigger: 'blur' }
      ],
      password: [
        { required: true, message: '请输入密码', trigger: 'blur' }
      ]
    }
    
    const handleLogin = async () => {
      if (!loginForm.value) return
      
      try {
        await loginForm.value.validate()
        loading.value = true
        
        const response = await axiosInstance.post('/users/login', formData)
        const data = response.data
        
        if (response.status === 200 && data.code === 200) {
          console.log('登录响应数据:', data.data)
          console.log('用户信息:', data.data.user)
          userStore.setToken(data.data.token)
          userStore.setUser(data.data.user)
          console.log('Store中的用户信息:', userStore.user)
          console.log('是否是管理员:', userStore.isAdmin)
          ElMessage.success('登录成功')
          
          // 获取重定向路径
          const redirectPath = userStore.redirectPath
          // 重置重定向路径
          userStore.setRedirectPath('/')
          // 跳转到目标页面
          router.push(redirectPath)
        } else {
          ElMessage.error(data.message || '登录失败')
        }
      } catch (error) {
        console.error('登录失败:', error)
        ElMessage.error(error.response?.data?.message || '登录失败')
      } finally {
        loading.value = false
      }
    }
    
    return {
      loginForm,
      formData,
      rules,
      loading,
      handleLogin
    }
  }
}
</script>

<style scoped>
.login-container {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #f5f7fa;
}

.login-card {
  width: 400px;
}

.login-card :deep(.el-card__header) {
  text-align: center;
}

.el-button {
  width: 100%;
}
</style> 