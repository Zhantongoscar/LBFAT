import { createRouter, createWebHashHistory } from 'vue-router'
import ProjectList from '../views/ProjectList.vue'
import DeviceList from '../views/DeviceList.vue'

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
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

export default router
