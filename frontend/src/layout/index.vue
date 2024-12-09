<template>
  <div class="app-wrapper">
    <!-- 侧边栏 -->
    <div class="sidebar-container">
      <el-menu
        :default-active="$route.path"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/projects">
          <el-icon><document /></el-icon>
          <span>项目列表</span>
        </el-menu-item>
        
        <el-menu-item index="/devices">
          <el-icon><monitor /></el-icon>
          <span>设备列表</span>
        </el-menu-item>

        <el-sub-menu index="/test">
          <template #title>
            <el-icon><tools /></el-icon>
            <span>测试管理</span>
          </template>
          <el-menu-item index="/test/template">真值表管理</el-menu-item>
          <el-menu-item index="/test/execution">测试执行</el-menu-item>
          <el-menu-item index="/test/report">测试报告</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </div>

    <!-- 主要内容区 -->
    <div class="main-container">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
import { defineComponent } from 'vue'
import { Document, Monitor, Tools } from '@element-plus/icons-vue'

export default defineComponent({
  name: 'Layout',
  components: {
    Document,
    Monitor,
    Tools
  }
})
</script>

<style scoped>
.app-wrapper {
  display: flex;
  height: 100vh;
}

.sidebar-container {
  width: 210px;
  height: 100%;
  background-color: #304156;
}

.main-container {
  flex: 1;
  overflow: auto;
  padding: 20px;
}
</style> 