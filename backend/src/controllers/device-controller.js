const Device = require('../models/device');

const deviceController = {
  // 获取所有设备
  async getAllDevices(req, res) {
    try {
      console.log('开始获取设备列表, 查询参数:', req.query);
      let devices = await Device.findAll(req.query);
      
      // 确保devices是数组
      if (!Array.isArray(devices)) {
        console.log('查询结果不是数组，进行转换');
        devices = devices ? [devices] : [];
      }
      
      console.log('最终返回数据:', {
        type: Array.isArray(devices) ? 'Array' : typeof devices,
        length: devices.length,
        data: devices
      });

      res.json({
        code: 200,
        message: 'success',
        data: devices
      });
    } catch (error) {
      console.error('获取设备列表失败:', error);
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
