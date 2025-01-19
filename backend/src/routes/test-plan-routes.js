const express = require('express')
const router = express.Router()
const db = require('../utils/db')

// 获取测试计划列表
router.get('/', async (req, res) => {
  try {
    // 获取测试计划基本信息
    const plans = await db.query(`
      SELECT p.*, t.name as truth_table_name 
      FROM test_plans p
      LEFT JOIN truth_tables t ON p.truth_table_id = t.id
      ORDER BY p.created_at DESC
    `)
    
    // 获取每个计划关联的测试组
    for (let plan of plans) {
      const groups = await db.query(`
        SELECT 
          g.*,
          tg.sequence,
          tg.dependencies,
          tg.created_at,
          tg.updated_at
        FROM test_groups g
        JOIN test_plan_groups tg ON g.id = tg.group_id
        WHERE tg.plan_id = ?
        ORDER BY tg.sequence
      `, [plan.id])
      plan.groups = groups
    }

    res.json({
      code: 200,
      message: 'success',
      data: plans
    })
  } catch (error) {
    console.error('获取测试计划列表失败:', error)
    res.status(500).json({
      code: 500,
      message: '获取测试计划列表失败',
      error: error.message
    })
  }
})

// 创建测试计划
router.post('/', async (req, res) => {
  try {
    const { name, truth_table_id, description, execution_mode, failure_strategy } = req.body

    // 验证必填字段
    if (!name || !truth_table_id) {
      return res.status(400).json({
        code: 400,
        message: '计划名称和关联真值表不能为空'
      })
    }

    // 检查真值表是否存在
    const truthTables = await db.query(
      'SELECT id FROM truth_tables WHERE id = ?',
      [truth_table_id]
    )

    if (truthTables.length === 0) {
      return res.status(400).json({
        code: 400,
        message: '关联的真值表不存在'
      })
    }

    // 创建测试计划
    const result = await db.query(
      `INSERT INTO test_plans 
       (name, truth_table_id, description, execution_mode, failure_strategy)
       VALUES (?, ?, ?, ?, ?)`,
      [name, truth_table_id, description, execution_mode, failure_strategy]
    )

    // 获取真值表下的所有测试组
    const groups = await db.query(
      'SELECT id, sequence FROM test_groups WHERE truth_table_id = ?',
      [truth_table_id]
    )

    // 创建测试实例
    const testInstance = await db.query(
      `INSERT INTO test_instances 
       (truth_table_id, product_sn, operator, status, result)
       VALUES (?, ?, ?, 'pending', 'unknown')`,
      [truth_table_id, 'TBD', 'system']  // 临时使用系统默认值
    )

    // 关联测试组到测试计划
    if (groups.length > 0) {
      // 构建批量插入的值
      const values = groups.map(group => [result.insertId, group.id, group.sequence])
      
      // 修改批量插入的SQL语句格式
      await db.query(
        `INSERT INTO test_plan_groups (plan_id, group_id, sequence) VALUES ${values.map(() => '(?,?,?)').join(',')}`,
        values.flat()
      )

      // 为每个组创建实例
      const instanceValues = groups.map(group => [testInstance.insertId, group.id])
      await db.query(
        `INSERT INTO test_instance_groups (instance_id, group_id) VALUES ${instanceValues.map(() => '(?,?)').join(',')}`,
        instanceValues.flat()
      )
    }

    res.json({
      code: 200,
      message: '测试计划创建成功',
      data: {
        id: result.insertId
      }
    })
  } catch (error) {
    console.error('创建测试计划失败:', error)
    res.status(500).json({
      code: 500,
      message: '创建测试计划失败',
      error: error.message
    })
  }
})

// 删除测试计划
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params

    // 检查测试计划是否存在
    const plan = await db.query('SELECT id FROM test_plans WHERE id = ?', [id])
    if (plan.length === 0) {
      return res.status(404).json({
        code: 404,
        message: '测试计划不存在'
      })
    }

    // 删除测试计划
    await db.query('DELETE FROM test_plans WHERE id = ?', [id])

    res.json({
      code: 200,
      message: '测试计划删除成功'
    })
  } catch (error) {
    console.error('删除测试计划失败:', error)
    res.status(500).json({
      code: 500,
      message: '删除测试计划失败',
      error: error.message
    })
  }
})

// 更新测试组实例配置
router.put('/:planId/groups/:groupId', async (req, res) => {
  try {
    const { planId, groupId } = req.params
    const { enabled, config } = req.body

    // 检查实例是否存在
    const instance = await db.query(
      'SELECT id FROM test_instance_groups WHERE instance_id = ? AND group_id = ?',
      [planId, groupId]
    )

    if (instance.length === 0) {
      return res.status(404).json({
        code: 404,
        message: '测试组实例不存在'
      })
    }

    // 更新配置
    await db.query(
      'UPDATE test_instance_groups SET status = ?, result = ? WHERE instance_id = ? AND group_id = ?',
      [enabled ? 'pending' : 'skipped', 'unknown', planId, groupId]
    )

    res.json({
      code: 200,
      message: '测试组实例配置更新成功'
    })
  } catch (error) {
    console.error('更新测试组实例配置失败:', error)
    res.status(500).json({
      code: 500,
      message: '更新测试组实例配置失败',
      error: error.message
    })
  }
})

module.exports = router 