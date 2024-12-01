import { createRouter, createWebHistory } from 'vue-router'
import DeviceList from '../views/DeviceList.vue'

const routes = [
  {
    path: '/',
    redirect: '/devices'
  },
  {
    path: '/devices',
    name: 'Devices',
    component: DeviceList
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
