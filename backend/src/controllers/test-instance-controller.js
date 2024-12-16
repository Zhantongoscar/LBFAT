const db = require('../utils/db');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

// 创建测试实例
async function createTestInstance(req, res) {
    const { 
        truth_table_id,
        product_sn,
        product_model,
        firmware_version,
        operator
    } = req.body;

    try {
        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            // 生成实例ID
            const instanceId = uuidv4();

            // 创建测试实例
            await connection.execute(
                `INSERT INTO test_instances 
                (instance_id, truth_table_id, product_sn, product_model, firmware_version, operator)
                VALUES (?, ?, ?, ?, ?, ?)`,
                [instanceId, truth_table_id, product_sn, product_model, firmware_version, operator]
            );

            // 获取真值表的所有测试组和测试项
            const [groups] = await connection.query(
                `SELECT g.*, i.*
                FROM test_groups g
                LEFT JOIN test_items i ON g.id = i.test_group_id
                WHERE g.truth_table_id = ?
                ORDER BY g.sequence, i.sequence`,
                [truth_table_id]
            );

            // 为每个测试项创建实例
            for (const group of groups) {
                if (group.id) {
                    await connection.execute(
                        `INSERT INTO test_item_instances
                        (instance_id, group_id, item_id)
                        VALUES (?, ?, ?)`,
                        [instanceId, group.id, group.item_id]
                    );
                }
            }

            await connection.commit();

            res.json({
                code: 200,
                message: '测试实例创建成功',
                data: { instanceId }
            });
        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }
    } catch (error) {
        logger.error('创建测试实例失败:', error);
        res.status(500).json({
            code: 500,
            message: '创建测试实例失败',
            error: error.message
        });
    }
}

// 开始测试
async function startTest(req, res) {
    const { instanceId } = req.params;

    try {
        const connection = await db.getConnection();
        try {
            // 更新测试实例状态
            await connection.execute(
                `UPDATE test_instances 
                SET status = 'running', start_time = CURRENT_TIMESTAMP
                WHERE instance_id = ? AND status = 'pending'`,
                [instanceId]
            );

            res.json({
                code: 200,
                message: '测试开始执行'
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        logger.error('开始测试失败:', error);
        res.status(500).json({
            code: 500,
            message: '开始测试失败',
            error: error.message
        });
    }
}

// 更新测试项状态
async function updateTestItemStatus(req, res) {
    const { instanceId, itemId } = req.params;
    const {
        execution_status,
        result_status,
        actual_value,
        error_code,
        error_message
    } = req.body;

    try {
        const connection = await db.getConnection();
        try {
            await connection.execute(
                `UPDATE test_item_instances
                SET execution_status = ?,
                    result_status = ?,
                    actual_value = ?,
                    error_code = ?,
                    error_message = ?,
                    end_time = CASE 
                        WHEN ? IN ('completed', 'skipped', 'timeout') 
                        THEN CURRENT_TIMESTAMP 
                        ELSE end_time 
                    END
                WHERE instance_id = ? AND id = ?`,
                [
                    execution_status,
                    result_status,
                    actual_value,
                    error_code,
                    error_message,
                    execution_status,
                    instanceId,
                    itemId
                ]
            );

            // 添加执行日志
            await connection.execute(
                `INSERT INTO test_execution_logs
                (instance_id, item_instance_id, log_level, log_message)
                VALUES (?, ?, ?, ?)`,
                [
                    instanceId,
                    itemId,
                    error_message ? 'error' : 'info',
                    error_message || `测试项状态更新: ${execution_status}`
                ]
            );

            res.json({
                code: 200,
                message: '测试项状态更新成功'
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        logger.error('更新测试项状态失败:', error);
        res.status(500).json({
            code: 500,
            message: '更新测试项状态失败',
            error: error.message
        });
    }
}

// 完成测试
async function completeTest(req, res) {
    const { instanceId } = req.params;
    const { result } = req.body;

    try {
        const connection = await db.getConnection();
        try {
            await connection.execute(
                `UPDATE test_instances
                SET status = 'completed',
                    result = ?,
                    end_time = CURRENT_TIMESTAMP
                WHERE instance_id = ? AND status = 'running'`,
                [result, instanceId]
            );

            res.json({
                code: 200,
                message: '测试完成'
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        logger.error('完成测试失败:', error);
        res.status(500).json({
            code: 500,
            message: '完成测试失败',
            error: error.message
        });
    }
}

// 获取测试实例详情
async function getTestInstance(req, res) {
    const { instanceId } = req.params;

    try {
        const connection = await db.getConnection();
        try {
            // 获取测试实例基本信息
            const [instances] = await connection.query(
                `SELECT * FROM test_instances WHERE instance_id = ?`,
                [instanceId]
            );

            if (instances.length === 0) {
                return res.status(404).json({
                    code: 404,
                    message: '未找到测试实例'
                });
            }

            const instance = instances[0];

            // 获取测试项实例列表
            const [items] = await connection.query(
                `SELECT i.*, g.description as group_description
                FROM test_item_instances i
                LEFT JOIN test_groups g ON i.group_id = g.id
                WHERE i.instance_id = ?
                ORDER BY g.sequence, i.id`,
                [instanceId]
            );

            // 获取执行日志
            const [logs] = await connection.query(
                `SELECT * FROM test_execution_logs
                WHERE instance_id = ?
                ORDER BY created_at DESC`,
                [instanceId]
            );

            res.json({
                code: 200,
                message: 'success',
                data: {
                    ...instance,
                    items,
                    logs
                }
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        logger.error('获取测试实例详情失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取测试实例详情失败',
            error: error.message
        });
    }
}

// 获取测试实例列表
async function getTestInstances(req, res) {
    const { 
        product_sn,
        status,
        result,
        start_date,
        end_date,
        page = 1,
        page_size = 10
    } = req.query;

    try {
        const connection = await db.getConnection();
        try {
            let whereClause = '1=1';
            const params = [];

            if (product_sn) {
                whereClause += ' AND product_sn = ?';
                params.push(product_sn);
            }
            if (status) {
                whereClause += ' AND status = ?';
                params.push(status);
            }
            if (result) {
                whereClause += ' AND result = ?';
                params.push(result);
            }
            if (start_date) {
                whereClause += ' AND DATE(created_at) >= ?';
                params.push(start_date);
            }
            if (end_date) {
                whereClause += ' AND DATE(created_at) <= ?';
                params.push(end_date);
            }

            // 获取总记录数
            const [countResult] = await connection.query(
                `SELECT COUNT(*) as total FROM test_instances WHERE ${whereClause}`,
                params
            );
            const total = countResult[0].total;

            // 获取分页数据
            const offset = (page - 1) * page_size;
            const [instances] = await connection.query(
                `SELECT * FROM test_instances 
                WHERE ${whereClause}
                ORDER BY created_at DESC
                LIMIT ? OFFSET ?`,
                [...params, parseInt(page_size), offset]
            );

            res.json({
                code: 200,
                message: 'success',
                data: {
                    total,
                    page,
                    page_size: parseInt(page_size),
                    items: instances
                }
            });
        } finally {
            connection.release();
        }
    } catch (error) {
        logger.error('获取测试实例列表失败:', error);
        res.status(500).json({
            code: 500,
            message: '获取测试实例列表失败',
            error: error.message
        });
    }
}

module.exports = {
    createTestInstance,
    startTest,
    updateTestItemStatus,
    completeTest,
    getTestInstance,
    getTestInstances
}; 