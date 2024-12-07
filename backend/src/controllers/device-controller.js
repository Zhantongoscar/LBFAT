const Device = require('../models/device');

const deviceController = {
  // 获取所有设备
  async getAllDevices(req, res) {
    try {
      console.log('=== 控制器开始处理请求 ===');
      console.log('查询参数:', req.query);
      
      const devices = await Device.findAll(req.query);
      console.log('=== 控制器收到查询结果 ===');
      console.log('devices类型:', typeof devices);
      console.log('devices是否为数组:', Array.isArray(devices));
      console.log('devices长度:', devices ? devices.length : 0);
      console.log('devices内容:', JSON.stringify(devices, null, 2));

      console.log('=== 准备发送响应 ===');
      const response = {
        code: 200,
        message: 'success',
        data: devices
      };
      console.log('响应内容:', JSON.stringify(response, null, 2));
      
      res.json(response);
    } catch (error) {
      console.error('=== 处理出错 ===');
      console.error('错误详情:', error);
      res.status(500).json({
        code: 500,
        message: error.message || '获取设备列表失败'
      });
    }
  },

  // 创建设备
  async createDevice(req, res) {
    try {
      const device = await Device.upsert(req.body);
      res.status(201).json({
        code: 200,
        message: 'Device created successfully',
        data: device
      });
    } catch (error) {
      res.status(500).json({
        code: 500,
        message: error.message
      });
    }
  },

  // 更新设备
  async updateDevice(req, res) {
    try {
      const { projectName, moduleType, serialNumber } = req.params;
      const result = await Device.updateStatus(
        projectName,
        moduleType,
        serialNumber,
        req.body.status,
        req.body.rssi
      );
      res.json({
        code: 200,
        message: 'Device updated successfully'
      });
    } catch (error) {
      res.status(500).json({
        code: 500,
        message: error.message
      });
    }
  },

  // 删除设备
  async deleteDevice(req, res) {
    try {
      const { projectName, moduleType, serialNumber } = req.params;
      await Device.delete(projectName, moduleType, serialNumber);
      res.json({
        code: 200,
        message: 'Device deleted successfully'
      });
    } catch (error) {
      res.status(500).json({
        code: 500,
        message: error.message
      });
    }
  }
};

module.exports = deviceController;
