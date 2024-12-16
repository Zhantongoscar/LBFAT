const db = require('../utils/db');
const logger = require('../utils/logger');

// 获取真值表列表
async function getTruthTables(req, res) {
    console.log('开始获取真值表列表');
    try {
        const connection = await db.getConnection();
        try {
            // 获取真值表列表，包括测试组数量
            const [tables] = await connection.query(
                `SELECT t.*, d.drawing_number,
                    (SELECT COUNT(*) FROM test_groups WHERE truth_table_id = t.id) as group_count
                FROM truth_tables t
                LEFT JOIN drawings d ON t.drawing_id = d.id
                ORDER BY t.updated_at DESC`
            );
            console.log('查询到真值表数量:', tables.length);

            // 获取每个真值表的测试组
            for (let table of tables) {
                const [groups] = await connection.query(
                    `SELECT g.*,
                        COALESCE(
                            JSON_ARRAYAGG(
                                IF(i.id IS NOT NULL,
                                    JSON_OBJECT(
                                        'id', i.id,
                                        'device_id', i.device_id,
                                        'point_type', i.point_type,
                                        'point_index', i.point_index,
                                        'action', i.action,
                                        'expected_result', i.expected_result,
                                        'fault_description', i.fault_description
                                    ),
                                    NULL
                                )
                            ),
                            '[]'
                        ) as items
                    FROM test_groups g
                    LEFT JOIN test_items i ON g.id = i.test_group_id
                    WHERE g.truth_table_id = ?
                    GROUP BY g.id
                    ORDER BY g.sequence`,
                    [table.id]
                );

                // 处理 items 字段
                table.groups = groups.map(group => {
                    try {
                        const items = JSON.parse(group.items);
                        return {
                            ...group,
                            items: Array.isArray(items) ? items.filter(item => item !== null) : []
                        };
                    } catch (error) {
                        console.error('解析测试项数据失败:', error);
                        return {
                            ...group,
                            items: []
                        };
                    }
                });
            }

            res.json({
                code: 200,
                message: 'success',
                data: tables
            });
        } finally {
            console.log('数据库连接已释放');
            connection.release();
        }
    } catch (error) {
        console.error('获取真值表列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取真值表列表失败',
            error: error.message
        });
    }
}

// 获取真值表详情
async function getTruthTable(req, res) {
    console.log('开始获取真值表详情，参数:', req.params);
    try {
        const { id } = req.params;
        console.log('真值表ID:', id);

        const connection = await db.getConnection();
        try {
            // 获取真值表基本信息
            console.log('执行真值表查询...');
            const [tables] = await connection.query(
                `SELECT t.*, d.drawing_number
                FROM truth_tables t
                LEFT JOIN drawings d ON t.drawing_id = d.id
                WHERE t.id = ?`,
                [id]
            );
            console.log('查询结果:', tables);

            if (tables.length === 0) {
                console.log('未找到指定的真值表');
                return res.status(404).json({
                    code: 404,
                    message: '未找到指定的真值表'
                });
            }

            const table = tables[0];

            // 获取测试组和测试项
            console.log('获取测试组数据...');
            const [groups] = await connection.query(
                `SELECT g.*,
                    COALESCE(
                        JSON_ARRAYAGG(
                            IF(i.id IS NOT NULL,
                                JSON_OBJECT(
                                    'id', i.id,
                                    'device_id', i.device_id,
                                    'point_type', i.point_type,
                                    'point_index', i.point_index,
                                    'action', i.action,
                                    'expected_result', i.expected_result,
                                    'fault_description', i.fault_description
                                ),
                                NULL
                            )
                        ),
                        '[]'
                    ) as items
                FROM test_groups g
                LEFT JOIN test_items i ON g.id = i.test_group_id
                WHERE g.truth_table_id = ?
                GROUP BY g.id
                ORDER BY g.sequence`,
                [id]
            );
            console.log('查询到的测试组数量:', groups.length);

            // 处理测试组数据
            table.groups = groups.map(group => {
                try {
                    console.log('处理测试组数据:', group);
                    const items = JSON.parse(group.items);
                    return {
                        ...group,
                        items: Array.isArray(items) ? items.filter(item => item !== null) : []
                    };
                } catch (error) {
                    console.error('解析测试项数据失败:', error);
                    return {
                        ...group,
                        items: []
                    };
                }
            });

            console.log('返回真值表数据:', table);
            res.json({
                code: 200,
                message: 'success',
                data: table
            });
        } finally {
            console.log('数据库连接已释放');
            connection.release();
        }
    } catch (error) {
        console.error('获取真值表详情失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取真值表详情失败',
            error: error.message
        });
    }
}

// 获取可用的图纸列表
async function getAvailableDrawings(req, res) {
    try {
        const connection = await db.getConnection();
        try {
            const [drawings] = await connection.query(
                'SELECT * FROM drawings ORDER BY drawing_number, version'
            );
            res.json({
                code: 200,
                message: 'success',
                data: drawings
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('获取可用图纸列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取可用图纸列表失败',
            error: error.message
        });
    }
}

// 创建真值表
async function createTruthTable(req, res) {
    try {
        const { name, drawing_id, version, description } = req.body;
        
        // 验证必填字段
        if (!name || !drawing_id || !version) {
            return res.status(400).json({
                code: 400,
                message: '名称、图纸ID和版本号不能为空'
            });
        }

        const connection = await db.getConnection();
        try {
            // 创建真值表
            const [result] = await connection.query(
                'INSERT INTO truth_tables (name, drawing_id, version, description) VALUES (?, ?, ?, ?)',
                [name, drawing_id, version, description]
            );

            // 获取创建的真值表
            const [tables] = await connection.query(
                'SELECT * FROM truth_tables WHERE id = ?',
                [result.insertId]
            );

            res.json({
                code: 200,
                message: '真值表创建成功',
                data: tables[0]
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('创建真值表失败:', error);
        res.status(500).json({
            code: 500,
            message: '创建真值表失败',
            error: error.message
        });
    }
}

// 更新真值表
async function updateTruthTable(req, res) {
    try {
        const { id } = req.params;
        const { name, drawing_id, version, description } = req.body;

        // 验证必填字段
        if (!name || !drawing_id || !version) {
            return res.status(400).json({
                code: 400,
                message: '名称、图纸ID和版本号不能为空'
            });
        }

        const connection = await db.getConnection();
        try {
            // 更新真值表
            await connection.query(
                'UPDATE truth_tables SET name = ?, drawing_id = ?, version = ?, description = ? WHERE id = ?',
                [name, drawing_id, version, description, id]
            );

            // 获取更新后的真值表
            const [tables] = await connection.query(
                'SELECT * FROM truth_tables WHERE id = ?',
                [id]
            );

            if (tables.length === 0) {
                return res.status(404).json({
                    code: 404,
                    message: '未找到指定的真值表'
                });
            }

            res.json({
                code: 200,
                message: '真值表更新成功',
                data: tables[0]
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('更新真值表失败:', error);
        res.status(500).json({
            code: 500,
            message: '更新真值表失败',
            error: error.message
        });
    }
}

// 删除真值表
async function deleteTruthTable(req, res) {
    try {
        const { id } = req.params;

        const connection = await db.getConnection();
        try {
            // 删除真值表
            await connection.query(
                'DELETE FROM truth_tables WHERE id = ?',
                [id]
            );

            res.json({
                code: 200,
                message: '真值表删除成功'
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        console.error('删除真值表失败:', error);
        res.status(500).json({
            code: 500,
            message: '删除真值表失败',
            error: error.message
        });
    }
}

module.exports = {
    getTruthTables,
    getTruthTable,
    getAvailableDrawings,
    createTruthTable,
    updateTruthTable,
    deleteTruthTable
}; 