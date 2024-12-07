const db = require('../utils/db');

class DeviceType {
    // 获取所有设备类型
    static async findAll() {
        const sql = `
            SELECT 
                dt.id,
                dt.type_name,
                dt.point_count,
                dt.description,
                dt.created_at,
                dt.updated_at
            FROM device_types dt
            ORDER BY dt.id
        `;
        const deviceTypes = await db.query(sql);

        // 获取每个设备类型的点位配置
        for (const deviceType of deviceTypes) {
            const pointsSql = `
                SELECT 
                    point_index,
                    point_type,
                    point_name,
                    description
                FROM device_type_points 
                WHERE device_type_id = ? 
                ORDER BY point_index
            `;
            deviceType.points = await db.query(pointsSql, [deviceType.id]);
        }

        return deviceTypes;
    }

    // 获取单个设备类型
    static async findById(id) {
        const sql = `
            SELECT 
                dt.id,
                dt.type_name,
                dt.point_count,
                dt.description,
                dt.created_at,
                dt.updated_at
            FROM device_types dt
            WHERE dt.id = ?
        `;
        const deviceTypes = await db.query(sql, [id]);
        if (deviceTypes.length === 0) {
            return null;
        }

        const deviceType = deviceTypes[0];

        // 获取点位配置
        const pointsSql = `
            SELECT 
                point_index,
                point_type,
                point_name,
                description
            FROM device_type_points 
            WHERE device_type_id = ? 
            ORDER BY point_index
        `;
        deviceType.points = await db.query(pointsSql, [id]);

        return deviceType;
    }
}

module.exports = DeviceType; 