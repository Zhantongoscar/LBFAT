import { createStore } from 'vuex'

export default createStore({
  state: {
    token: localStorage.getItem('token'),
    user: JSON.parse(localStorage.getItem('user')),
    redirectPath: '/'
  },
  
  mutations: {
    setToken(state, token) {
      state.token = token
      localStorage.setItem('token', token)
    },
    
    setUser(state, user) {
      state.user = user
      localStorage.setItem('user', JSON.stringify(user))
    },
    
    setRedirectPath(state, path) {
      state.redirectPath = path
    },
    
    logout(state) {
      state.token = null
      state.user = null
      state.redirectPath = '/'
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  },
  
  getters: {
    isAuthenticated: state => !!state.token,
    isAdmin: state => state.user?.role === 'admin',
    redirectPath: state => state.redirectPath
  }
}) 