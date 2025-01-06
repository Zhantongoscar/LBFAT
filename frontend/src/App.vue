<template>
  <el-container>
    <el-header>
      <div class="header-content">
        <div class="logo-title">
          <img src="@/assets/buhler-logo.png" alt="Bühler Logo" class="buhler-logo">
          <h1>Leybold Panel Test System V1.0.0</h1>
        </div>
        <div class="user-info" v-if="userStore.isAuthenticated">
          <el-dropdown>
            <span class="el-dropdown-link">
              <el-avatar
                :size="32"
                class="user-avatar"
              >
                {{ userStore.user?.username?.charAt(0).toUpperCase() || 'U' }}
              </el-avatar>
              <span class="username">{{ userStore.user?.username }}</span>
              <el-icon class="el-icon--right"><arrow-down /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item class="user-info-header">
                  <el-avatar
                    :size="50"
                    class="user-avatar-large"
                  >
                    {{ userStore.user?.username?.charAt(0).toUpperCase() || 'U' }}
                  </el-avatar>
                  <div class="user-detail">
                    <div>{{ userStore.user?.username }}</div>
                    <div class="user-role">{{ userStore.isAdmin ? '管理员' : '普通用户' }}</div>
                  </div>
                </el-dropdown-item>
                <el-dropdown-item>
                  <el-button type="text" @click="handleLogout">退出登录</el-button>
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>
    <el-container>
      <el-aside :width="isCollapse ? '64px' : '180px'" class="aside-container">
        <!-- 折叠按钮 -->
        <div class="collapse-btn" @click="toggleCollapse">
          <el-icon>
            <component :is="isCollapse ? 'Expand' : 'Fold'" />
          </el-icon>
        </div>
        
        <el-menu 
          router 
          :collapse="isCollapse"
          :collapse-transition="false"
          class="el-menu-vertical"
        >
          <el-sub-menu index="/test">
            <template #title>
              <el-icon><Tools /></el-icon>
              <span>测试管理</span>
            </template>
            <el-menu-item index="/test/template">
              <el-icon><Document /></el-icon>
              <template #title>真值表管理</template>
            </el-menu-item>
            <el-menu-item index="/projects" title="配置检查设备的mqtt 订阅topic">
              <el-icon><Document /></el-icon>
              <template #title>订阅管理</template>
            </el-menu-item>
            <el-menu-item index="/test/execution">
              <el-icon><VideoPlay /></el-icon>
              <template #title>测试执行</template>
            </el-menu-item>
            <el-menu-item index="/test/report">
              <el-icon><DataAnalysis /></el-icon>
              <template #title>测试报告</template>
            </el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="/device">
            <template #title>
              <el-icon><Monitor /></el-icon>
              <span>设备</span>
            </template>
            <el-menu-item index="/device-config" title="定义测试设备的类型和子通道类型">
              <el-icon><Setting /></el-icon>
              <template #title>设备定义</template>
            </el-menu-item>
            <el-menu-item index="/devices" title="本测试装置使用测试设备的订阅维护">
              <el-icon><Monitor /></el-icon>
              <template #title>在用设备</template>
            </el-menu-item>
            <el-menu-item index="/device-test" title="调试在线设备">
              <el-icon><Operation /></el-icon>
              <template #title>设备测试</template>
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item index="/drawings">
            <el-icon><Picture /></el-icon>
            <template #title>图纸管理</template>
          </el-menu-item>
          <el-menu-item index="/users" v-if="userStore.isAdmin">
            <el-icon><User /></el-icon>
            <template #title>用户管理</template>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <router-view></router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from './stores/user'
import { buhlerLogoBase64 } from './assets/buhler-logo.js'
import { 
  Monitor, 
  Message, 
  Operation, 
  Tools, 
  Document,
  Setting,
  VideoPlay,
  DataAnalysis,
  Expand,
  Fold,
  User,
  ArrowDown,
  SwitchButton,
  Picture
} from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'

export default {
  components: {
    Monitor,
    Message,
    Operation,
    Tools,
    Document,
    Setting,
    VideoPlay,
    DataAnalysis,
    Expand,
    Fold,
    User,
    ArrowDown,
    SwitchButton,
    Picture
  },
  setup() {
    const router = useRouter()
    const userStore = useUserStore()
    const isCollapse = ref(false)
    
    const toggleCollapse = () => {
      isCollapse.value = !isCollapse.value
    }

    const handleLogout = () => {
      ElMessageBox.confirm(
        '确定要退出登录吗？',
        '提示',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning',
        }
      ).then(() => {
        userStore.logout()
        router.push('/login')
      })
    }
    
    return {
      isCollapse,
      toggleCollapse,
      userStore,
      handleLogout,
      buhlerLogoBase64
    }
  }
}
</script>

<style>
.el-header {
  background-color: #fff;
  color: #303133;
  line-height: normal;
  height: 70px !important;
  padding: 0;
  border-bottom: 1px solid #dcdfe6;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.12);
  position: relative;
  z-index: 100;
}

.el-header h1 {
  margin: 0;
  font-size: 22px;
  color: #303133;
  font-weight: 600;
  white-space: nowrap;
}

.aside-container {
  background-color: #003755;
  transition: width 0.3s;
  position: relative;
}

.collapse-btn {
  height: 40px;
  line-height: 40px;
  text-align: center;
  cursor: pointer;
  color: #ffffff;
  transition: background 0.3s;
}

.collapse-btn:hover {
  background: rgba(255, 255, 255, 0.1);
}

.el-menu-vertical {
  border-right: none;
  background-color: #003755;
}

.el-menu-vertical:not(.el-menu--collapse) {
  width: 180px;
}

/* 菜单项样式 */
.el-menu {
  border-right: none;
  background-color: #003755;
}

.el-menu-item {
  color: #ffffff !important;
  background-color: #003755 !important;
}

.el-menu-item.is-active {
  color: #ffffff !important;
  background-color: #004d7a !important;
}

.el-menu-item:hover {
  background-color: #004d7a !important;
}

.el-sub-menu__title {
  color: #ffffff !important;
  background-color: #003755 !important;
}

.el-sub-menu__title:hover {
  background-color: #004d7a !important;
}

/* 子菜单样式 */
.el-menu--popup {
  background-color: #003755 !important;
}

.el-sub-menu .el-menu {
  background-color: #003755 !important;
}

.el-sub-menu .el-menu-item {
  background-color: #003755 !important;
  color: #ffffff !important;
}

.el-sub-menu .el-menu-item:hover {
  background-color: #004d7a !important;
}

.el-sub-menu .el-menu-item.is-active {
  color: #ffffff !important;
  background-color: #004d7a !important;
}

/* 图标样式 */
.el-menu-item .el-icon,
.el-sub-menu__title .el-icon {
  color: inherit;
}

/* 主内容区样式 */
.el-main {
  padding: 20px;
  background-color: #f0f2f5;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  background-color: #fff;
  padding: 0 20px;
}

.logo-title {
  display: flex;
  align-items: center;
}

.buhler-logo {
  height: 60px;
  width: auto;
  margin-right: 20px;
}

.user-info {
  display: flex;
  align-items: center;
}

.el-dropdown-link {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.username {
  font-size: 14px;
  color: #606266;
}

.user-avatar {
  background-color: #409EFF;
  color: #fff;
}

.user-info-header {
  text-align: center;
  padding: 15px;
  border-bottom: 1px solid #eee;
  cursor: default;
  pointer-events: none;
}

.user-avatar-large {
  margin-bottom: 10px;
  background-color: #409EFF;
  color: #fff;
}

.user-detail {
  font-size: 14px;
  color: #606266;
}

.user-role {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
</style>
