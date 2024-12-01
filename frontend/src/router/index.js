import { createRouter, createWebHistory } from 'vue-router'
import DeviceList from '../views/DeviceList.vue'

const routes = [
  {
    path: '/',
    redirect: '/devices'
  },
  {
    path: '/devices',
    name: 'DeviceList',
    component: DeviceList
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router 