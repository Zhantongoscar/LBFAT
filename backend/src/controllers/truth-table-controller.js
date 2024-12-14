const db = require('../utils/db');

// 获取所有真值表
exports.getAllTables = async (req, res) => {
    try {
        console.log('开始获取真值表列表');
        const sql = 'SELECT * FROM truth_tables ORDER BY updated_at DESC';
        
        const truthTables = await db.query(sql);
        console.log('查询到真值表数量:', truthTables.length);
        
        res.json({
            code: 200,
            message: 'success',
            data: truthTables
        });
    } catch (error) {
        console.error('获取真值表列表失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message || '获取真值表列表失败'
        });
    }
};

// 获取单个真值表
exports.getTable = async (req, res) => {
    try {
        const { id } = req.params;
        
        // 获取真值表基本信息
        const [truthTable] = await db.query(`
            SELECT 
                t.*,
                d.drawing_number,
                d.version as drawing_version,
                u1.username as creator_name,
                u2.username as updater_name
            FROM truth_tables t
            LEFT JOIN drawings d ON t.drawing_id = d.id
            LEFT JOIN users u1 ON t.created_by = u1.id
            LEFT JOIN users u2 ON t.updated_by = u2.id
            WHERE t.id = ?
        `, [id]);

        if (!truthTable) {
            return res.status(404).json({
                code: 404,
                message: '真值表不存在'
            });
        }

        // 获取测试组信息
        const groups = await db.query(`
            SELECT *
            FROM test_groups
            WHERE truth_table_id = ?
            ORDER BY sequence
        `, [id]);

        // 获取每个测试组的测试项
        for (const group of groups) {
            group.items = await db.query(`
                SELECT *
                FROM test_items
                WHERE group_id = ?
                ORDER BY sequence
            `, [group.id]);
        }

        truthTable.groups = groups;

        res.json({
            code: 200,
            message: 'success',
            data: truthTable
        });
    } catch (error) {
        console.error('获取真值表详情失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message || '获取真值表详情失败'
        });
    }
};

// 创建真值表
exports.createTable = async (req, res) => {
    let connection;
    try {
        const { name, drawing_id, version, description, groups } = req.body;
        const userId = req.user?.id;

        // 验证必填字段
        if (!name || !drawing_id || !version) {
            return res.status(400).json({
                code: 400,
                message: '名称、图纸ID和版本号为必填项'
            });
        }

        // 获取连接并开始事务
        connection = await db.getConnection();
        await connection.beginTransaction();

        // 创建真值表
        const [result] = await connection.execute(
            `INSERT INTO truth_tables 
            (name, drawing_id, version, description, created_by, updated_by) 
            VALUES (?, ?, ?, ?, ?, ?)`,
            [name, drawing_id, version, description, userId, userId]
        );

        const truthTableId = result.insertId;

        // 创建测试组和测试项
        if (Array.isArray(groups)) {
            for (const group of groups) {
                const [groupResult] = await connection.execute(
                    `INSERT INTO test_groups 
                    (truth_table_id, test_id, level, description, sequence) 
                    VALUES (?, ?, ?, ?, ?)`,
                    [truthTableId, group.test_id, group.level, group.description, group.sequence]
                );

                const groupId = groupResult.insertId;

                if (Array.isArray(group.items)) {
                    for (const item of group.items) {
                        await connection.execute(
                            `INSERT INTO test_items 
                            (group_id, device_id, unit_id, unit_type, set_value, 
                            expected_value, enabled, description, error_message, 
                            fault_details, sequence) 
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                            [groupId, item.device_id, item.unit_id, item.unit_type,
                            item.set_value, item.expected_value, item.enabled,
                            item.description, item.error_message, item.fault_details,
                            item.sequence]
                        );
                    }
                }
            }
        }

        await connection.commit();

        res.status(201).json({
            code: 201,
            message: '创建成功',
            data: { id: truthTableId }
        });
    } catch (error) {
        if (connection) {
            await connection.rollback();
        }
        console.error('创建真值表失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message || '创建真值表失败'
        });
    } finally {
        if (connection) {
            connection.release();
        }
    }
};

// 更新真值表
exports.updateTable = async (req, res) => {
    let connection;
    try {
        const { id } = req.params;
        const { name, drawing_id, version, description, groups } = req.body;
        const userId = req.user?.id;

        connection = await db.getConnection();
        await connection.beginTransaction();

        // 更新真值表基本信息
        await connection.execute(
            `UPDATE truth_tables 
            SET name = ?, drawing_id = ?, version = ?, 
                description = ?, updated_by = ?
            WHERE id = ?`,
            [name, drawing_id, version, description, userId, id]
        );

        // 删除原有的测试组和测试项
        await connection.execute('DELETE FROM test_groups WHERE truth_table_id = ?', [id]);

        // 创建新的测试组和测试项
        if (Array.isArray(groups)) {
            for (const group of groups) {
                const [groupResult] = await connection.execute(
                    `INSERT INTO test_groups 
                    (truth_table_id, test_id, level, description, sequence) 
                    VALUES (?, ?, ?, ?, ?)`,
                    [id, group.test_id, group.level, group.description, group.sequence]
                );

                const groupId = groupResult.insertId;

                if (Array.isArray(group.items)) {
                    for (const item of group.items) {
                        await connection.execute(
                            `INSERT INTO test_items 
                            (group_id, device_id, unit_id, unit_type, set_value, 
                            expected_value, enabled, description, error_message, 
                            fault_details, sequence) 
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                            [groupId, item.device_id, item.unit_id, item.unit_type,
                            item.set_value, item.expected_value, item.enabled,
                            item.description, item.error_message, item.fault_details,
                            item.sequence]
                        );
                    }
                }
            }
        }

        await connection.commit();

        res.json({
            code: 200,
            message: '更新成功'
        });
    } catch (error) {
        if (connection) {
            await connection.rollback();
        }
        console.error('更新真值表失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message || '更新真值表失败'
        });
    } finally {
        if (connection) {
            connection.release();
        }
    }
};

// 删除真值表
exports.deleteTable = async (req, res) => {
    let connection;
    try {
        const { id } = req.params;

        connection = await db.getConnection();
        await connection.beginTransaction();

        // 删除真值表（级联删除会自动删除相关的测试组和测试项）
        await connection.execute('DELETE FROM truth_tables WHERE id = ?', [id]);

        await connection.commit();

        res.json({
            code: 200,
            message: '删除成功'
        });
    } catch (error) {
        if (connection) {
            await connection.rollback();
        }
        console.error('删除真值表失败:', error);
        res.status(500).json({
            code: 500,
            message: error.message || '删除真值表失败'
        });
    } finally {
        if (connection) {
            connection.release();
        }
    }
}; 