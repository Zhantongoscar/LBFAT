import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // 状态
  const token = ref('')
  const user = ref(null)
  const redirectPath = ref('')

  // 计算属性
  const isAuthenticated = computed(() => {
    return !!token.value && !!user.value && 
           typeof user.value === 'object' && 
           !!user.value.username && 
           !!user.value.role
  })
  const isAdmin = computed(() => user.value?.role === 'admin')

  // 方法
  function setToken(newToken) {
    if (!newToken) {
      console.warn('Attempting to set empty token')
      return
    }
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  function setUser(userData) {
    if (!userData || typeof userData !== 'object') {
      console.warn('Invalid user data:', userData)
      return
    }
    user.value = userData
    localStorage.setItem('user', JSON.stringify(userData))
  }

  function setRedirectPath(path) {
    redirectPath.value = path
  }

  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    redirectPath.value = ''
  }

  // 初始化时检查token和用户信息
  function init() {
    const storedToken = localStorage.getItem('token')
    const storedUser = localStorage.getItem('user')
    
    if (!storedToken || !storedUser) {
      logout()
      return
    }

    try {
      const parsedUser = JSON.parse(storedUser)
      if (!parsedUser || typeof parsedUser !== 'object' || !parsedUser.username || !parsedUser.role) {
        throw new Error('Invalid user data structure')
      }
      token.value = storedToken
      user.value = parsedUser
    } catch (e) {
      console.error('Failed to initialize user state:', e)
      logout()
    }
  }

  // 立即初始化
  init()

  return {
    // 状态
    token,
    user,
    redirectPath,
    // 计算属性
    isAuthenticated,
    isAdmin,
    // 方法
    setToken,
    setUser,
    setRedirectPath,
    logout,
    init
  }
}) 