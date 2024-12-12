<template>
  <el-container>
    <el-header>
      <div class="header-content">
        <h1>Leybold Panel Test System V1.0.0</h1>
        <div class="user-info" v-if="userStore.isAuthenticated">
          <el-dropdown>
            <span class="el-dropdown-link">
              <el-avatar
                :size="32"
                class="user-avatar"
                :src="userStore.user?.avatar"
              >
                {{ userStore.user?.username.charAt(0).toUpperCase() }}
              </el-avatar>
              {{ userStore.user?.username }}
              <el-icon class="el-icon--right"><arrow-down /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item class="user-info-header">
                  <el-avatar
                    :size="50"
                    class="user-avatar-large"
                    :src="userStore.user?.avatar"
                  >
                    {{ userStore.user?.username.charAt(0).toUpperCase() }}
                  </el-avatar>
                </el-dropdown-item>
                <el-dropdown-item>
                  <span>用户名：{{ userStore.user?.username }}</span>
                </el-dropdown-item>
                <el-dropdown-item>
                  <span>显示名称：{{ userStore.user?.display_name || '-' }}</span>
                </el-dropdown-item>
                <el-dropdown-item>
                  <span>角色：</span>
                  <el-tag size="small" :type="userStore.isAdmin ? 'danger' : 'info'">
                    {{ userStore.isAdmin ? '管理员' : '普通用户' }}
                  </el-tag>
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><switch-button /></el-icon>
                  退出登录
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
          <el-menu-item index="/projects">
            <el-icon><Document /></el-icon>
            <template #title>项目管理</template>
          </el-menu-item>
          <el-menu-item index="/device-config">
            <el-icon><Setting /></el-icon>
            <template #title>设备配置</template>
          </el-menu-item>
          <el-menu-item index="/devices">
            <el-icon><Monitor /></el-icon>
            <template #title>设备管理</template>
          </el-menu-item>
          <el-menu-item index="/users" v-if="userStore.isAdmin">
            <el-icon><User /></el-icon>
            <template #title>用户管理</template>
          </el-menu-item>
          <el-sub-menu index="/test">
            <template #title>
              <el-icon><Tools /></el-icon>
              <span>测试管理</span>
            </template>
            <el-menu-item index="/test/template">
              <el-icon><Document /></el-icon>
              <template #title>真值表管理</template>
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
          <el-menu-item index="/messages">
            <el-icon><Message /></el-icon>
            <template #title>消息管理</template>
          </el-menu-item>
          <el-menu-item index="/device-test">
            <el-icon><Operation /></el-icon>
            <template #title>设备测试</template>
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
  SwitchButton
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
    SwitchButton
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
      handleLogout
    }
  }
}
</script>

<style>
.el-header {
  background-color: #e4e7ed;
  color: #303133;
  line-height: 60px;
  padding: 0 20px;
  border-bottom: 1px solid #dcdfe6;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.12);
  position: relative;
  z-index: 100;
}

.el-header h1 {
  margin: 0;
  font-size: 20px;
  color: #303133;
  font-weight: 600;
}

.aside-container {
  background-color: #304156;
  transition: width 0.3s;
  position: relative;
}

.collapse-btn {
  height: 40px;
  line-height: 40px;
  text-align: center;
  cursor: pointer;
  color: #bfcbd9;
  transition: background 0.3s;
}

.collapse-btn:hover {
  background: rgba(0, 0, 0, 0.1);
}

.el-menu-vertical {
  border-right: none;
  background-color: #304156;
}

.el-menu-vertical:not(.el-menu--collapse) {
  width: 180px;
}

/* 菜单项样式 */
.el-menu {
  border-right: none;
  background-color: #304156;
}

.el-menu-item {
  color: #bfcbd9 !important;
  background-color: #304156 !important;
}

.el-menu-item.is-active {
  color: #409EFF !important;
  background-color: #263445 !important;
}

.el-menu-item:hover {
  background-color: #263445 !important;
}

.el-sub-menu__title {
  color: #bfcbd9 !important;
  background-color: #304156 !important;
}

.el-sub-menu__title:hover {
  background-color: #263445 !important;
}

/* 子菜单样式 */
.el-menu--popup {
  background-color: #304156 !important;
}

.el-sub-menu .el-menu {
  background-color: #304156 !important;
}

.el-sub-menu .el-menu-item {
  background-color: #304156 !important;
  color: #bfcbd9 !important;
}

.el-sub-menu .el-menu-item:hover {
  background-color: #263445 !important;
}

.el-sub-menu .el-menu-item.is-active {
  color: #409EFF !important;
  background-color: #263445 !important;
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
}

.user-info {
  display: flex;
  align-items: center;
}

.el-dropdown-link {
  display: flex;
  align-items: center;
  color: #303133;
  cursor: pointer;
  gap: 8px;
}

.user-avatar {
  background-color: #409EFF;
  color: #fff;
  font-weight: bold;
}

.user-avatar-large {
  background-color: #409EFF;
  color: #fff;
  font-weight: bold;
  margin-bottom: 8px;
}

.user-info-header {
  display: flex;
  justify-content: center;
  padding: 16px 0;
  pointer-events: none;
  cursor: default;
  border-bottom: 1px solid #ebeef5;
}

.el-dropdown-menu__item {
  display: flex;
  align-items: center;
  gap: 5px;
}

.el-icon {
  margin-right: 5px;
}
</style>
