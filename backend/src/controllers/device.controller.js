const pool = require("../utils/db");

const deviceController = {
  // 获取所有设备
  async getAllDevices(req, res) {
    try {
      const [rows] = await pool.query("SELECT * FROM devices");
      res.json(rows);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 创建设备
  async createDevice(req, res) {
    const { device_code, device_name } = req.body;
    try {
      const [result] = await pool.query(
        "INSERT INTO devices (device_code, device_name) VALUES (?, ?)",
        [device_code, device_name]
      );
      res.status(201).json({
        id: result.insertId,
        device_code,
        device_name
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 更新设备
  async updateDevice(req, res) {
    const { device_code, device_name } = req.body;
    try {
      await pool.query(
        "UPDATE devices SET device_code = ?, device_name = ? WHERE id = ?",
        [device_code, device_name, req.params.id]
      );
      res.json({ message: "Device updated successfully" });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // 删除设备
  async deleteDevice(req, res) {
    try {
      await pool.query("DELETE FROM devices WHERE id = ?", [req.params.id]);
      res.json({ message: "Device deleted successfully" });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = deviceController;
