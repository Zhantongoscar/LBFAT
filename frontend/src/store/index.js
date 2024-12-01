import { createStore } from 'vuex'

export default createStore({
  state: {
    devices: []
  },
  mutations: {
    setDevices(state, devices) {
      state.devices = devices
    }
  },
  actions: {
    updateDevices({ commit }, devices) {
      commit('setDevices', devices)
    }
  }
}) 