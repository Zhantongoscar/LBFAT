import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import UserManager from '../views/UserManager.vue'
import ProjectList from '../views/ProjectList.vue'
import DeviceList from '../views/DeviceList.vue'
import DeviceConfig from '../views/DeviceConfig.vue'
import MessageList from '../views/MessageList.vue'
import DeviceTest from '../views/DeviceTest.vue'
import DrawingManager from '../views/DrawingManager.vue'
import { useUserStore } from '../stores/user'

const routes = [
  {
    path: '/',
    redirect: '/projects'
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresAuth: false }
  },
  // 项目管理
  {
    path: '/projects',
    name: 'ProjectList',
    component: ProjectList,
    meta: { requiresAuth: true }
  },
  // 设备管理
  {
    path: '/devices',
    name: 'DeviceList',
    component: DeviceList,
    meta: { requiresAuth: true }
  },
  // 设备配置
  {
    path: '/device-config',
    name: 'DeviceConfig',
    component: DeviceConfig,
    meta: { requiresAuth: true }
  },
  // 消息列表
  {
    path: '/messages',
    name: 'MessageList',
    component: MessageList,
    meta: { requiresAuth: true }
  },
  // 设备测试
  {
    path: '/device-test',
    name: 'DeviceTest',
    component: DeviceTest,
    meta: { requiresAuth: true }
  },
  // 图纸管理
  {
    path: '/drawings',
    name: 'DrawingManager',
    component: DrawingManager,
    meta: { requiresAuth: true }
  },
  // 用户管理（仅管理员可访问）
  {
    path: '/users',
    name: 'UserManager',
    component: UserManager,
    meta: { 
      requiresAuth: true,
      requiresAdmin: true
    }
  },
  // 测试相关路由
  {
    path: '/test',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'template',
        name: 'TemplateManager',
        component: () => import('../views/template/TemplateManager.vue')
      },
      {
        path: 'execution',
        name: 'TestExecution',
        component: () => import('../views/test/TestExecution.vue')
      },
      {
        path: 'report',
        name: 'TestReport',
        component: () => import('../views/test/TestReport.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  // 如果用户已登录且要去登录页，重定向到首页
  if (to.path === '/login' && userStore.isAuthenticated) {
    next('/projects')
    return
  }
  
  // 不需要认证的路由直接放行
  if (!to.meta.requiresAuth) {
    next()
    return
  }
  
  // 未登录跳转到登录页
  if (!userStore.isAuthenticated) {
    userStore.setRedirectPath(to.fullPath)
    next('/login')
    return
  }
  
  // 需要管理员权限但不是管理员
  if (to.meta.requiresAdmin && !userStore.isAdmin) {
    next('/projects')
    return
  }
  
  next()
})

export default router
