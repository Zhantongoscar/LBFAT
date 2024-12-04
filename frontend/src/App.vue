<template>
  <el-container>
    <el-header>
      <h1>LBFAT System</h1>
    </el-header>
    <el-container>
      <el-aside width="200px">
        <el-menu router>
          <el-menu-item index="/projects">
            <span>项目管理</span>
          </el-menu-item>
          <el-menu-item index="/devices">
            <span>设备管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <router-view></router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<style>
.el-header {
  background-color: #409EFF;
  color: white;
  line-height: 60px;
}
.el-aside {
  background-color: #f8f9fa;
}
</style>
