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
    redirect: '/login'
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
    meta: { 
      requiresAuth: true,
      requiresAdmin: true
    }
  },
  // 设备管理
  {
    path: '/devices',
    name: 'DeviceList',
    component: DeviceList,
    meta: { 
      requiresAuth: true,
      requiresAdmin: true
    }
  },
  // 设备配置
  {
    path: '/device-config',
    name: 'DeviceConfig',
    component: DeviceConfig,
    meta: { 
      requiresAuth: true,
      requiresAdmin: true
    }
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
    meta: { 
      requiresAuth: true,
      requiresAdmin: true
    }
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
        component: () => import('../views/test/TemplateManager.vue'),
        meta: {
          requiresAuth: true,
          requiresAdmin: true
        }
      },
      {
        path: 'execution',
        name: 'TestExecution',
        component: () => import('../views/test/TestExecution.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'report',
        name: 'TestReport',
        component: () => import('../views/test/TestReport.vue'),
        meta: { requiresAuth: true }
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
  
  // 根路径的处理
  if (to.path === '/') {
    if (userStore.isAuthenticated) {
      next(userStore.isAdmin ? '/projects' : '/test/execution')
    } else {
      next('/login')
    }
    return
  }
  
  // 访问登录页时的处理
  if (to.path === '/login') {
    if (userStore.isAuthenticated) {
      // 已登录用户重定向到对应的首页
      next(userStore.isAdmin ? '/projects' : '/test/execution')
    } else {
      // 未登录用户允许访问登录页
      next()
    }
    return
  }
  
  // 不需要认证的路由直接放行
  if (!to.meta.requiresAuth) {
    next()
    return
  }
  
  // 未登录用户处理
  if (!userStore.isAuthenticated) {
    // 保存目标路径并重定向到登录页
    userStore.setRedirectPath(to.fullPath)
    next('/login')
    return
  }
  
  // 需要管理员权限但不是管理员
  if (to.meta.requiresAdmin && !userStore.isAdmin) {
    next('/test/execution')
    return
  }
  
  // 其他情况放行
  next()
})

export default router
