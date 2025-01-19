const express = require('express')
const router = express.Router()
const db = require('../utils/db')

// 获取测试计划列表
router.get('/', async (req, res) => {
  try {
    const plans = await db.query(`
      SELECT p.*, t.name as truth_table_name 
      FROM test_plans p
      LEFT JOIN truth_tables t ON p.truth_table_id = t.id
      ORDER BY p.created_at DESC
    `)
    
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

module.exports = router 