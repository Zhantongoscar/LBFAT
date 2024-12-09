import { createRouter, createWebHashHistory } from 'vue-router'
import ProjectList from '../views/ProjectList.vue'
import DeviceList from '../views/DeviceList.vue'
import DeviceConfig from '../views/DeviceConfig.vue'
import MessageList from '../views/MessageList.vue'
import DeviceTest from '../views/DeviceTest.vue'

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
  },
  {
    path: '/messages',
    name: 'MessageList',
    component: MessageList
  },
  {
    path: '/device-test',
    name: 'DeviceTest',
    component: DeviceTest
  },
  {
    path: '/template',
    name: 'TemplateManager',
    component: () => import('../views/template/TemplateManager.vue')
  },
  {
    path: '/test-execution',
    name: 'TestExecution',
    component: () => import('../views/test/TestExecution.vue')
  },
  {
    path: '/test-report',
    name: 'TestReport',
    component: () => import('../views/test/TestReport.vue')
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

export default router
