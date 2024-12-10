<template>
  <el-container>
    <el-header>
      <h1>Leybold Panel Test System V1.0.0</h1>
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
          <el-menu-item index="/devices">
            <el-icon><Monitor /></el-icon>
            <template #title>设备管理</template>
          </el-menu-item>
          <el-menu-item index="/messages">
            <el-icon><Message /></el-icon>
            <template #title>消息管理</template>
          </el-menu-item>
          <el-menu-item index="/device-config">
            <el-icon><Setting /></el-icon>
            <template #title>设备配置</template>
          </el-menu-item>
          <el-menu-item index="/device-test">
            <el-icon><Operation /></el-icon>
            <template #title>设备测试</template>
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
  Fold
} from '@element-plus/icons-vue'

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
    Fold
  },
  setup() {
    const isCollapse = ref(false)
    
    const toggleCollapse = () => {
      isCollapse.value = !isCollapse.value
    }
    
    return {
      isCollapse,
      toggleCollapse
    }
  }
}
</script>

<style>
.el-header {
  background-color: #409EFF;
  color: white;
  line-height: 60px;
  padding: 0 20px;
}

.el-header h1 {
  margin: 0;
  font-size: 20px;
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
</style>
