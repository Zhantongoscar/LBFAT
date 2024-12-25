import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // 状态
  const token = ref(localStorage.getItem('token') || '')
  const user = ref(null)
  const redirectPath = ref('')

  // 计算属性
  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'admin')

  // 方法
  function setToken(newToken) {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  function setUser(userData) {
    user.value = userData
    localStorage.setItem('userInfo', JSON.stringify(userData))
  }

  function setRedirectPath(path) {
    redirectPath.value = path
  }

  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
  }

  // 初始化时检查token和用户信息
  function init() {
    const storedToken = localStorage.getItem('token')
    const storedUser = localStorage.getItem('userInfo')
    
    if (storedToken) {
      token.value = storedToken
      if (storedUser) {
        try {
          user.value = JSON.parse(storedUser)
        } catch (e) {
          console.error('Failed to parse stored user data:', e)
          localStorage.removeItem('userInfo')
        }
      }
    } else {
      // 如果没有token，清除所有存储的信息
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