const db = require('../utils/db');

class Device {
    // 获取所有设备
    static async findAll(filters = {}) {
        let sql = 'SELECT * FROM devices WHERE 1=1';
        const params = [];

        if (filters.projectName) {
            sql += ' AND project_name = ?';
            params.push(filters.projectName);
        }
        if (filters.status) {
            sql += ' AND status = ?';
            params.push(filters.status);
        }

        sql += ' ORDER BY updated_at DESC';
        const [rows] = await db.query(sql, params);
        return rows;
    }

    // 获取单个设备
    static async findOne(projectName, moduleType, serialNumber) {
        const sql = 'SELECT * FROM devices WHERE project_name = ? AND module_type = ? AND serial_number = ?';
        const [rows] = await db.query(sql, [projectName, moduleType, serialNumber]);
        return rows[0];
    }

    // 创建或更新设备
    static async upsert(device) {
        const sql = `
            INSERT INTO devices (project_name, module_type, serial_number, status, rssi)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                status = VALUES(status),
                rssi = VALUES(rssi)
        `;
        const [result] = await db.query(sql, [
            device.projectName,
            device.moduleType,
            device.serialNumber,
            device.status,
            device.rssi
        ]);
        return result;
    }

    // 更新设备状态
    static async updateStatus(projectName, moduleType, serialNumber, status, rssi) {
        const sql = 'UPDATE devices SET status = ?, rssi = ? WHERE project_name = ? AND module_type = ? AND serial_number = ?';
        const [result] = await db.query(sql, [status, rssi, projectName, moduleType, serialNumber]);
        return result;
    }

    // 批量更新项目下所有设备状态
    static async updateProjectDevicesStatus(projectName, status) {
        const sql = 'UPDATE devices SET status = ?, rssi = 0 WHERE project_name = ?';
        const [result] = await db.query(sql, [status, projectName]);
        return result;
    }

    // 删除设备
    static async delete(projectName, moduleType, serialNumber) {
        const sql = 'DELETE FROM devices WHERE project_name = ? AND module_type = ? AND serial_number = ?';
        const [result] = await db.query(sql, [projectName, moduleType, serialNumber]);
        return result;
    }
}

module.exports = Device; 