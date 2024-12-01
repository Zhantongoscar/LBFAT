/**
 * 状态管理设计
 * @description 定义前端状态管理机制
 * @author -
 * @date 2024-01-21
 */

# Store命名规范
- const devicestore = defineStore('device', {
+ const deviceStore = defineStore('device', {

# 状态命名规范
  state: () => ({
-   devicelist: [],
+   deviceList: [],
-   currentdevice: null,
+   currentDevice: null,
  }),

# Action命名规范
  actions: {
-   async getdevicelist() {
+   async getDeviceList() {
-   async updatedevicestatus() {
+   async updateDeviceStatus() {
  }
} 