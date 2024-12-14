const db = require('../utils/db')
const logger = require('../utils/logger')

// 创建测试组
async function createTestGroup(req, res) {
    const { truth_table_id, test_id, level, description, sequence, items } = req.body

    try {
        // 开始事务
        const connection = await db.getConnection()
        await connection.beginTransaction()

        try {
            // 插入测试组
            const [result] = await connection.execute(
                'INSERT INTO test_groups (truth_table_id, test_id, level, description, sequence) VALUES (?, ?, ?, ?, ?)',
                [truth_table_id, test_id, level, description, sequence]
            )
            
            const groupId = result.insertId

            // 如果有测试项，插入测试项
            if (items && items.length > 0) {
                const itemValues = items.map(item => [
                    groupId,
                    item.action,
                    item.expected_result,
                    item.sequence
                ])

                await connection.query(
                    'INSERT INTO test_items (test_group_id, action, expected_result, sequence) VALUES ?',
                    [itemValues]
                )
            }

            // 提交事务
            await connection.commit()

            // 获取完整的测试组数据
            const [groups] = await connection.query(
                `SELECT g.*, 
                        JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'id', i.id,
                                'action', i.action,
                                'expected_result', i.expected_result,
                                'sequence', i.sequence
                            )
                        ) as items
                FROM test_groups g
                LEFT JOIN test_items i ON g.id = i.test_group_id
                WHERE g.id = ?
                GROUP BY g.id`,
                [groupId]
            )

            res.json({
                code: 0,
                message: '创建成功',
                data: groups[0]
            })
        } catch (error) {
            // 回滚事务
            await connection.rollback()
            throw error
        } finally {
            connection.release()
        }
    } catch (error) {
        logger.error('创建测试组失败:', error)
        res.status(500).json({
            code: 500,
            message: '���建测试组失败',
            error: error.message
        })
    }
}

// 更新测试组
async function updateTestGroup(req, res) {
    const { id } = req.params
    const { test_id, level, description, sequence, items } = req.body

    try {
        const connection = await db.getConnection()
        await connection.beginTransaction()

        try {
            // 更新测试组
            await connection.execute(
                'UPDATE test_groups SET test_id = ?, level = ?, description = ?, sequence = ? WHERE id = ?',
                [test_id, level, description, sequence, id]
            )

            // 删除原有的测试项
            await connection.execute('DELETE FROM test_items WHERE test_group_id = ?', [id])

            // 插入新的测试项
            if (items && items.length > 0) {
                const itemValues = items.map(item => [
                    id,
                    item.action,
                    item.expected_result,
                    item.sequence
                ])

                await connection.query(
                    'INSERT INTO test_items (test_group_id, action, expected_result, sequence) VALUES ?',
                    [itemValues]
                )
            }

            await connection.commit()

            // 获取更新后的完整数据
            const [groups] = await connection.query(
                `SELECT g.*, 
                        JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'id', i.id,
                                'action', i.action,
                                'expected_result', i.expected_result,
                                'sequence', i.sequence
                            )
                        ) as items
                FROM test_groups g
                LEFT JOIN test_items i ON g.id = i.test_group_id
                WHERE g.id = ?
                GROUP BY g.id`,
                [id]
            )

            res.json({
                code: 0,
                message: '更新成功',
                data: groups[0]
            })
        } catch (error) {
            await connection.rollback()
            throw error
        } finally {
            connection.release()
        }
    } catch (error) {
        logger.error('更新测试组失败:', error)
        res.status(500).json({
            code: 500,
            message: '更新测试组失败',
            error: error.message
        })
    }
}

// 删除测试组
async function deleteTestGroup(req, res) {
    const { id } = req.params

    try {
        const connection = await db.getConnection()
        await connection.beginTransaction()

        try {
            // 先删除关联的测试项
            await connection.execute('DELETE FROM test_items WHERE test_group_id = ?', [id])
            
            // 再删除测试组
            await connection.execute('DELETE FROM test_groups WHERE id = ?', [id])
            
            await connection.commit()

            res.json({
                code: 0,
                message: '删除成功'
            })
        } catch (error) {
            await connection.rollback()
            throw error
        } finally {
            connection.release()
        }
    } catch (error) {
        logger.error('删除测试组失败:', error)
        res.status(500).json({
            code: 500,
            message: '删除测试组失败',
            error: error.message
        })
    }
}

module.exports = {
    createTestGroup,
    updateTestGroup,
    deleteTestGroup
} 