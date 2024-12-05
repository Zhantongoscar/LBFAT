import { createRouter, createWebHashHistory } from 'vue-router'
import ProjectList from '../views/ProjectList.vue'
import DeviceList from '../views/DeviceList.vue'
import DeviceConfig from '../views/DeviceConfig.vue'

const routes = [
  {
    path: '/',
    redirect: '/projects'
  },
  {
    path: '/projects',
    name: 'ProjectList',
    component: ProjectList
  },
  {
    path: '/devices',
    name: 'DeviceList',
    component: DeviceList
  },
  {
    path: '/device-config',
    name: 'DeviceConfig',
    component: DeviceConfig
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

export default router
