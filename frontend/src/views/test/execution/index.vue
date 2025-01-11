<template>
  <div class="test-execution">
    <!-- 测试设备状态区域 -->
    <el-card class="status-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-button 
              type="text" 
              @click="isDeviceStatusCollapsed = !isDeviceStatusCollapsed"
            >
              <el-icon>
                <component :is="isDeviceStatusCollapsed ? 'ArrowRight' : 'ArrowDown'" />
              </el-icon>
              测试设备状态 {{ deviceCount }}/{{ totalDevices }}
            </el-button>
          </div>
        </div>
      </template>

      <el-collapse-transition>
        <div v-show="!isDeviceStatusCollapsed">
          <div class="device-status">
            <div class="status-section">
              <h3>在线设备</h3>
              <div class="device-grid">
                <div v-for="device in onlineDevices" :key="device.id" class="device-item">
                  <el-tag type="success">
                    {{ device.project_name }}-{{ device.module_type }}-{{ device.serial_number }}
                  </el-tag>
                </div>
              </div>
            </div>

            <div class="status-section">
              <h3>离线设备</h3>
              <div class="device-grid">
                <div v-for="device in offlineDevices" :key="device.id" class="device-item">
                  <el-tag type="info">
                    {{ device.project_name }}-{{ device.module_type }}-{{ device.serial_number }}
                  </el-tag>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-collapse-transition>
    </el-card>

    <!-- 测试实例列表区域 -->
    <el-card class="instance-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <el-button 
              type="text" 
              @click="isInstanceListCollapsed = !isInstanceListCollapsed"
            >
              <el-icon>
                <component :is="isInstanceListCollapsed ? 'ArrowRight' : 'ArrowDown'" />
              </el-icon>
              测试实例列表 {{ instanceCount }}
            </el-button>
          </div>
          <el-button type="primary" @click="handleCreateInstance">新建测试实例</el-button>
        </div>
      </template>

      <el-collapse-transition>
        <div v-show="!isInstanceListCollapsed">
          <!-- 原有的测试实例列表内容 -->
          // ... existing instance list code ...
        </div>
      </el-collapse-transition>
    </el-card>

    <!-- 测试实例详情区域 -->
    // ... existing instance detail code ...
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ArrowDown, ArrowRight } from '@element-plus/icons-vue'

// 折叠状态控制
const isDeviceStatusCollapsed = ref(true)  // 默认折叠
const isInstanceListCollapsed = ref(true)   // 默认折叠

// ... existing script code ...

</script>

<style scoped>
.test-execution {
  padding: 20px;
}

.status-card,
.instance-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}

.device-status {
  margin-top: 10px;
}

.status-section {
  margin-bottom: 20px;
}

.device-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 10px;
  margin-top: 10px;
}

.device-item {
  display: flex;
  align-items: center;
}
</style> 