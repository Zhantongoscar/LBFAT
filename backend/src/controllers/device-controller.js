const Device = require('../models/device');

const deviceController = {
  // 获取所有设备
  async getAllDevices(req, res) {
    try {
      const devices = await Device.findAll(req.query);
      res.json({
        code: 200,
        message: 'success',
        data: devices
      });
    } catch (error) {
      res.status(500).json({
        code: 500,
        message: error.message
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
