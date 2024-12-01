const pool = require('../utils/db');
const logger = require('../utils/logger');

class DeviceMonitorService {
    async updateDeviceStatus(deviceType, deviceId, payload) {
        try {
            const deviceCode = `${deviceType}_${deviceId}`;
            const status = payload.status === 'online' ? 1 : 0;
            
            // 检查设备是否存在
            const [devices] = await pool.query(
                'SELECT id FROM devices WHERE device_code = ?',
                [deviceCode]
            );

            if (devices.length === 0) {
                // 设备不存在，创建新设备
                const [result] = await pool.query(
                    `INSERT INTO devices (device_code, device_name, device_type, status, last_online_time) 
                     VALUES (?, ?, ?, ?, NOW())`,
                    [deviceCode, `${deviceType}设备${deviceId}`, deviceType, status]
                );
                
                // 记录状态日志
                await this.logDeviceStatus(result.insertId, status, payload.rssi);
                logger.info(`New device created: ${deviceCode}`);
            } else {
                // 更新现有设备状态
                await pool.query(
                    `UPDATE devices 
                     SET status = ?, 
                         last_online_time = NOW() 
                     WHERE device_code = ?`,
                    [status, deviceCode]
                );
                
                // 记录状态日志
                await this.logDeviceStatus(devices[0].id, status, payload.rssi);
                logger.info(`Device status updated: ${deviceCode}`);
            }
        } catch (error) {
            logger.error('Error updating device status:', error);
            throw error;
        }
    }

    async logDeviceStatus(deviceId, status, rssi) {
        try {
            await pool.query(
                `INSERT INTO device_status_logs (device_id, status, rssi) 
                 VALUES (?, ?, ?)`,
                [deviceId, status, rssi]
            );
        } catch (error) {
            logger.error('Error logging device status:', error);
            throw error;
        }
    }

    async updateDeviceHeartbeat(deviceType, deviceId, payload) {
        try {
            const deviceCode = `${deviceType}_${deviceId}`;
            
            // 获取设备ID
            const [devices] = await pool.query(
                'SELECT id FROM devices WHERE device_code = ?',
                [deviceCode]
            );

            if (devices.length > 0) {
                // 记录心跳数据
                await pool.query(
                    `INSERT INTO device_heartbeats (device_id, rssi, network_delay) 
                     VALUES (?, ?, ?)`,
                    [devices[0].id, payload.rssi, payload.latency || 0]
                );

                // 更新连接质量
                await this.updateConnectionQuality(devices[0].id, payload);
                logger.info(`Device heartbeat recorded: ${deviceCode}`);
            }
        } catch (error) {
            logger.error('Error updating device heartbeat:', error);
            throw error;
        }
    }

    async updateConnectionQuality(deviceId, payload) {
        try {
            // 计算连接质量评分 (0-100)
            const rssiScore = this.calculateRssiScore(payload.rssi);
            const latencyScore = this.calculateLatencyScore(payload.latency);
            const totalScore = Math.round((rssiScore + latencyScore) / 2);

            await pool.query(
                `INSERT INTO device_connection_quality 
                 (device_id, signal_strength, network_delay, connection_score) 
                 VALUES (?, ?, ?, ?)`,
                [deviceId, payload.rssi, payload.latency, totalScore]
            );
        } catch (error) {
            logger.error('Error updating connection quality:', error);
            throw error;
        }
    }

    // 计算RSSI评分 (0-100)
    calculateRssiScore(rssi) {
        if (rssi >= -50) return 100;
        if (rssi <= -100) return 0;
        return Math.round(100 + (rssi + 50) * 2);
    }

    // 计算延迟评分 (0-100)
    calculateLatencyScore(latency) {
        if (!latency) return 100;
        if (latency <= 50) return 100;
        if (latency >= 1000) return 0;
        return Math.round(100 - (latency - 50) / 9.5);
    }
}

module.exports = new DeviceMonitorService(); 