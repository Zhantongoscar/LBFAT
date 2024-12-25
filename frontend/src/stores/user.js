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
  }

  function setRedirectPath(path) {
    redirectPath.value = path
  }

  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
  }

  // 初始化时检查token是否有效
  function init() {
    const storedToken = localStorage.getItem('token')
    if (storedToken) {
      token.value = storedToken
    }
  }

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