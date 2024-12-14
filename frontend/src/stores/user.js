import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token'),
    user: JSON.parse(localStorage.getItem('user')),
    redirectPath: '/'
  }),

  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
    isLoggedIn: (state) => !!state.token && !!state.user,
    isAdmin: (state) => state.user?.role === 'admin'
  },

  actions: {
    setToken(token) {
      this.token = token
      localStorage.setItem('token', token)
    },

    setUser(user) {
      this.user = user
      localStorage.setItem('user', JSON.stringify(user))
    },

    setRedirectPath(path) {
      this.redirectPath = path
    },

    logout() {
      this.token = null
      this.user = null
      this.redirectPath = '/'
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
}) 