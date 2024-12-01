const pool = require('../utils/db');
const logger = require('../utils/logger');

const deviceStatusController = {
    // 获取所有设备列表
    async getAllDevices(req, res) {
        try {
            const [rows] = await pool.query('SELECT * FROM devices ORDER BY create_time DESC');
            res.json(rows);
        } catch (error) {
            logger.error('Get all devices error:', error);
            res.status(500).json({ error: error.message });
        }
    },

    // 获取设备当前状态
    async getDeviceStatus(req, res) {
        try {
            const { deviceId } = req.params;
            const [rows] = await pool.query(
                'SELECT * FROM devices WHERE device_code = ?',
                [deviceId]
            );
            res.json(rows[0] || { error: 'Device not found' });
        } catch (error) {
            logger.error('Get device status error:', error);
            res.status(500).json({ error: error.message });
        }
    },

    // 获取设备状态历史记录
    async getDeviceStatusHistory(req, res) {
        try {
            const { deviceId } = req.params;
            const { startTime, endTime, limit = 100 } = req.query;
            
            const [rows] = await pool.query(
                `SELECT * FROM device_status_logs 
                WHERE device_id = ? 
                AND create_time BETWEEN ? AND ?
                ORDER BY create_time DESC 
                LIMIT ?`,
                [deviceId, startTime, endTime, parseInt(limit)]
            );
            res.json(rows);
        } catch (error) {
            logger.error('Get device status history error:', error);
            res.status(500).json({ error: error.message });
        }
    },

    // 获取设备心跳历史
    async getDeviceHeartbeats(req, res) {
        try {
            const { deviceId } = req.params;
            const { limit = 100 } = req.query;
            
            const [rows] = await pool.query(
                `SELECT * FROM device_heartbeats 
                WHERE device_id = ? 
                ORDER BY create_time DESC 
                LIMIT ?`,
                [deviceId, parseInt(limit)]
            );
            res.json(rows);
        } catch (error) {
            logger.error('Get device heartbeats error:', error);
            res.status(500).json({ error: error.message });
        }
    },

    // 获取设备统计信息
    async getDeviceStats(req, res) {
        try {
            const { deviceId } = req.params;
            
            const [rows] = await pool.query(
                `SELECT 
                    COUNT(*) as total_heartbeats,
                    AVG(rssi) as avg_rssi,
                    MIN(rssi) as min_rssi,
                    MAX(rssi) as max_rssi
                FROM device_heartbeats 
                WHERE device_id = ? 
                AND create_time > DATE_SUB(NOW(), INTERVAL 24 HOUR)`,
                [deviceId]
            );
            res.json(rows[0]);
        } catch (error) {
            logger.error('Get device stats error:', error);
            res.status(500).json({ error: error.message });
        }
    }
};

module.exports = deviceStatusController; 