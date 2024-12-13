const db = require('../utils/db');

const deviceTypeController = {
    // 获取所有设备类型
    async getAllTypes(req, res) {
        try {
            console.log('=== 开始获取设备类型列表 ===');
            console.log('请求头:', req.headers);
            console.log('请求参数:', req.query);
            
            const deviceTypes = await db.query(`
                SELECT 
                    dt.id,
                    dt.type_name,
                    dt.point_count,
                    dt.description,
                    dt.created_at,
                    dt.updated_at
                FROM device_types dt
                ORDER BY dt.id
            `);
            console.log('查询结果:', deviceTypes);
            console.log(`获取到 ${deviceTypes.length} 个设备类型`);

            // 分别查询每个设备类型的点位配置
            const result = await Promise.all(deviceTypes.map(async (type) => {
                console.log(`正在查询设备类型 ${type.id} 的点位配置`);
                const points = await db.query(`
                    SELECT 
                        point_index,
                        point_type,
                        point_name,
                        description
                    FROM device_type_points 
                    WHERE device_type_id = ? 
                    ORDER BY point_index
                `, [type.id]);
                console.log(`设备类型 ${type.id} 有 ${points.length} 个点位配置`);

                return {
                    ...type,
                    points: points || []
                };
            }));

            console.log('=== 查询完成 ===');
            console.log('最终结果:', result);

            res.json({
                code: 200,
                message: 'success',
                data: result
            });
        } catch (error) {
            console.error('获取设备类型失败:', error);
            console.error('错误堆栈:', error.stack);
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
            console.log('获取设备类型:', id);

            // 查询设备类型基本信息
            const [deviceType] = await db.query(`
                SELECT 
                    id,
                    type_name,
                    point_count,
                    description,
                    created_at,
                    updated_at
                FROM device_types 
                WHERE id = ?
            `, [id]);

            if (!deviceType) {
                return res.status(404).json({
                    code: 404,
                    message: '设备类型不存在'
                });
            }

            // 查询点位配置
            const points = await db.query(`
                SELECT 
                    point_index,
                    point_type,
                    point_name,
                    description
                FROM device_type_points 
                WHERE device_type_id = ? 
                ORDER BY point_index
            `, [id]);

            const result = {
                ...deviceType,
                points: points || []
            };

            console.log('查询结果:', result);

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

    // 创建设备类型
    async createType(req, res) {
        let connection;
        try {
            const { type_name, point_count, description, points } = req.body;
            console.log('创建设备类型:', { type_name, point_count, description, points });
            
            // 获取连接并开始事务
            connection = await db.getConnection();
            await connection.beginTransaction();

            // 插入设备类型
            const [result] = await connection.execute(
                'INSERT INTO device_types (type_name, point_count, description) VALUES (?, ?, ?)',
                [type_name, point_count, description]
            );

            const deviceTypeId = result.insertId;
            console.log('设备类型已创建, ID:', deviceTypeId);

            // 插入��位配置
            if (Array.isArray(points) && points.length > 0) {
                for (const point of points) {
                    await connection.execute(
                        `INSERT INTO device_type_points 
                        (device_type_id, point_index, point_type, point_name, description) 
                        VALUES (?, ?, ?, ?, ?)`,
                        [
                            deviceTypeId,
                            point.point_index,
                            point.point_type,
                            point.point_name || '',
                            point.description || ''
                        ]
                    );
                }
                console.log(`已插入 ${points.length} 个点位配置`);
            }

            // 提交事务
            await connection.commit();
            console.log('事务已提交');

            res.json({
                code: 200,
                message: '创建成功',
                data: { id: deviceTypeId }
            });
        } catch (error) {
            console.error('创建设备类型失败:', error);
            if (connection) {
                await connection.rollback();
                console.log('事务已回滚');
            }
            res.status(500).json({
                code: 500,
                message: error.message || '创建设备类型失败'
            });
        } finally {
            if (connection) {
                connection.release();
                console.log('数据库连接已释放');
            }
        }
    },

    // 更新设备类型
    async updateType(req, res) {
        let connection;
        try {
            const { id } = req.params;
            const { type_name, point_count, description, points } = req.body;
            console.log('更新设备类型:', { id, type_name, point_count, description, points });

            // 获取连接并开始事务
            connection = await db.getConnection();
            await connection.beginTransaction();

            // 更新设备类型
            await connection.execute(
                'UPDATE device_types SET type_name = ?, point_count = ?, description = ? WHERE id = ?',
                [type_name, point_count, description, id]
            );

            // 删除原有点位配置
            await connection.execute('DELETE FROM device_type_points WHERE device_type_id = ?', [id]);

            // 插入新的点位配置
            if (Array.isArray(points) && points.length > 0) {
                for (const point of points) {
                    await connection.execute(
                        `INSERT INTO device_type_points 
                        (device_type_id, point_index, point_type, point_name, description) 
                        VALUES (?, ?, ?, ?, ?)`,
                        [
                            id,
                            point.point_index,
                            point.point_type,
                            point.point_name || '',
                            point.description || ''
                        ]
                    );
                }
                console.log(`已更新 ${points.length} 个点位配置`);
            }

            // 提交事务
            await connection.commit();
            console.log('事务已提交');

            res.json({
                code: 200,
                message: '更新成功'
            });
        } catch (error) {
            console.error('更新设备类型失败:', error);
            if (connection) {
                await connection.rollback();
                console.log('事务已回滚');
            }
            res.status(500).json({
                code: 500,
                message: error.message || '更新设备类型失败'
            });
        } finally {
            if (connection) {
                connection.release();
                console.log('数据库连接已释放');
            }
        }
    },

    // 删除设备类型
    async deleteType(req, res) {
        let connection;
        try {
            const { id } = req.params;
            console.log('删除设备类型:', id);

            // 获取连接并开始事务
            connection = await db.getConnection();
            await connection.beginTransaction();

            // 删除点位配置
            await connection.execute('DELETE FROM device_type_points WHERE device_type_id = ?', [id]);
            
            // 删除设备类型
            await connection.execute('DELETE FROM device_types WHERE id = ?', [id]);

            // 提交事务
            await connection.commit();
            console.log('事务已提交');

            res.json({
                code: 200,
                message: '删除成功'
            });
        } catch (error) {
            console.error('删除设备类型失败:', error);
            if (connection) {
                await connection.rollback();
                console.log('事务已回滚');
            }
            res.status(500).json({
                code: 500,
                message: error.message || '删除设备类型失败'
            });
        } finally {
            if (connection) {
                connection.release();
                console.log('数据库连接已释放');
            }
        }
    }
};

module.exports = deviceTypeController; 