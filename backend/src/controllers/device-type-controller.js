const db = require('../utils/db');

const deviceTypeController = {
    // 获取所有设备类型
    async getAllTypes(req, res) {
        try {
            console.log('开始查询设备类型...');
            
            // 1. 先获取所有设备类型
            const deviceTypes = await db.query('SELECT * FROM device_types');
            console.log('设备类型查询结果:', deviceTypes);

            // 2. 获取每个设备类型的点位配置
            const result = await Promise.all(deviceTypes.map(async (type) => {
                const points = await db.query(
                    'SELECT point_index, point_type, point_name, description FROM device_type_points WHERE device_type_id = ? ORDER BY point_index',
                    [type.id]
                );
                return {
                    ...type,
                    points: points || []
                };
            }));

            console.log('格式化后的数据:', result);

            res.json({
                code: 200,
                message: 'success',
                data: result
            });
        } catch (error) {
            console.error('获取设备类型失败:', error);
            res.status(500).json({
                code: 500,
                message: error.message || '获取设备类型失败'
            });
        }
    },

    // 获取单个设备类型
    async getType(req, res) {
        try {
            const { id } = req.params;
            const sql = `
                SELECT dt.*, 
                       GROUP_CONCAT(
                           JSON_OBJECT(
                               'point_index', dtp.point_index,
                               'point_type', dtp.point_type,
                               'point_name', dtp.point_name,
                               'description', dtp.description
                           ) ORDER BY dtp.point_index
                       ) as points
                FROM device_types dt
                LEFT JOIN device_type_points dtp ON dt.id = dtp.device_type_id
                WHERE dt.id = ?
                GROUP BY dt.id
            `;
            const [type] = await db.query(sql, [id]);
            
            if (!type) {
                return res.status(404).json({
                    code: 404,
                    message: '设备类型不存在'
                });
            }

            // 解析points字符串为JSON数组
            type.points = type.points ? type.points.split(',').map(p => JSON.parse(p)) : [];

            res.json({
                code: 200,
                message: 'success',
                data: type
            });
        } catch (error) {
            console.error('获取设备类型失败:', error);
            res.status(500).json({
                code: 500,
                message: error.message
            });
        }
    },

    // 创建设备类型
    async createType(req, res) {
        try {
            const { type_name, point_count, description, points } = req.body;
            
            // 开始事务
            await db.query('START TRANSACTION');

            // 插入设备类型
            const [result] = await db.query(
                'INSERT INTO device_types (type_name, point_count, description) VALUES (?, ?, ?)',
                [type_name, point_count, description]
            );

            // 插入点位配置
            if (points && points.length > 0) {
                const pointValues = points.map(p => [
                    result.insertId,
                    p.point_index,
                    p.point_type,
                    p.point_name,
                    p.description
                ]);
                
                await db.query(
                    'INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES ?',
                    [pointValues]
                );
            }

            // 提交事务
            await db.query('COMMIT');

            res.json({
                code: 200,
                message: '创建成功',
                data: { id: result.insertId }
            });
        } catch (error) {
            // 回滚事务
            await db.query('ROLLBACK');
            console.error('创建设备类型失败:', error);
            res.status(500).json({
                code: 500,
                message: error.message
            });
        }
    },

    // 更新设备类型
    async updateType(req, res) {
        try {
            const { id } = req.params;
            const { type_name, point_count, description, points } = req.body;

            // 开始事务
            await db.query('START TRANSACTION');

            // 更新设备类型
            await db.query(
                'UPDATE device_types SET type_name = ?, point_count = ?, description = ? WHERE id = ?',
                [type_name, point_count, description, id]
            );

            // 删除原有点位配置
            await db.query('DELETE FROM device_type_points WHERE device_type_id = ?', [id]);

            // 插入新的点位配置
            if (points && points.length > 0) {
                const pointValues = points.map(p => [
                    id,
                    p.point_index,
                    p.point_type,
                    p.point_name,
                    p.description
                ]);
                
                await db.query(
                    'INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES ?',
                    [pointValues]
                );
            }

            // 提交事务
            await db.query('COMMIT');

            res.json({
                code: 200,
                message: '更新成功'
            });
        } catch (error) {
            // 回滚事务
            await db.query('ROLLBACK');
            console.error('更新设备类型失败:', error);
            res.status(500).json({
                code: 500,
                message: error.message
            });
        }
    },

    // 删除设备类型
    async deleteType(req, res) {
        try {
            const { id } = req.params;
            
            // 开始事务
            await db.query('START TRANSACTION');

            // 删除设备类型（级联删除会自动删相关的点位配置）
            await db.query('DELETE FROM device_types WHERE id = ?', [id]);

            // 提交事务
            await db.query('COMMIT');

            res.json({
                code: 200,
                message: '删除成功'
            });
        } catch (error) {
            // 回滚事务
            await db.query('ROLLBACK');
            console.error('删除设备类型失败:', error);
            res.status(500).json({
                code: 500,
                message: error.message
            });
        }
    }
};

module.exports = deviceTypeController; 