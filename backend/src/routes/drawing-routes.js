const express = require('express');
const router = express.Router();
const db = require('../utils/db');

// 获取图纸列表
router.get('/', async (req, res) => {
  try {
    const drawings = await db.query('SELECT * FROM drawings ORDER BY created_at DESC');
    res.json({
      code: 200,
      message: 'success',
      data: drawings
    });
  } catch (error) {
    console.error('获取图纸列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取图纸列表失败',
      error: error.message
    });
  }
});

// 创建图纸
router.post('/', async (req, res) => {
  try {
    const { drawing_number, version, description } = req.body;
    
    // 验证必填字段
    if (!drawing_number || !version) {
      return res.status(400).json({
        code: 400,
        message: '图纸编号和版本号不能为空'
      });
    }
    
    // 检查是否已存在相同编号和版本的图纸
    const existing = await db.query(
      'SELECT id FROM drawings WHERE drawing_number = ? AND version = ?',
      [drawing_number, version]
    );
    
    if (existing.length > 0) {
      return res.status(400).json({
        code: 400,
        message: '已存在相同编号和版本的图纸'
      });
    }
    
    // 创建图纸
    const result = await db.query(
      'INSERT INTO drawings (drawing_number, version, description) VALUES (?, ?, ?)',
      [drawing_number, version, description]
    );
    
    res.json({
      code: 200,
      message: '图纸创建成功',
      data: {
        id: result.insertId
      }
    });
  } catch (error) {
    console.error('创建图纸失败:', error);
    res.status(500).json({
      code: 500,
      message: '创建图纸失败',
      error: error.message
    });
  }
});

// 更新图纸
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { drawing_number, version, description } = req.body;
    
    // 验证必填字段
    if (!drawing_number || !version) {
      return res.status(400).json({
        code: 400,
        message: '图纸编号和版本号不能为空'
      });
    }
    
    // 检查图纸是否存在
    const existing = await db.query(
      'SELECT id FROM drawings WHERE id = ?',
      [id]
    );
    
    if (existing.length === 0) {
      return res.status(404).json({
        code: 404,
        message: '图纸不存在'
      });
    }
    
    // 检查是否已存在相同编号和版本的其他图纸
    const duplicate = await db.query(
      'SELECT id FROM drawings WHERE drawing_number = ? AND version = ? AND id != ?',
      [drawing_number, version, id]
    );
    
    if (duplicate.length > 0) {
      return res.status(400).json({
        code: 400,
        message: '已存在相同编号和版本的图纸'
      });
    }
    
    // 更新图纸
    await db.query(
      'UPDATE drawings SET drawing_number = ?, version = ?, description = ? WHERE id = ?',
      [drawing_number, version, description, id]
    );
    
    res.json({
      code: 200,
      message: '图纸更新成功'
    });
  } catch (error) {
    console.error('更新图纸失败:', error);
    res.status(500).json({
      code: 500,
      message: '更新图纸失败',
      error: error.message
    });
  }
});

// 删除图纸
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // 检查图纸是否存在
    const existing = await db.query(
      'SELECT id FROM drawings WHERE id = ?',
      [id]
    );
    
    if (existing.length === 0) {
      return res.status(404).json({
        code: 404,
        message: '图纸不存在'
      });
    }
    
    // 检查是否有关联的真值表
    const templates = await db.query(
      'SELECT id FROM test_templates WHERE drawing_id = ?',
      [id]
    );
    
    if (templates.length > 0) {
      return res.status(400).json({
        code: 400,
        message: '该图纸已关联真值表，无法删除'
      });
    }
    
    // 删除图纸
    await db.query('DELETE FROM drawings WHERE id = ?', [id]);
    
    res.json({
      code: 200,
      message: '图纸删除成功'
    });
  } catch (error) {
    console.error('删除图纸失败:', error);
    res.status(500).json({
      code: 500,
      message: '删除图纸失败',
      error: error.message
    });
  }
});

// 获取单个图纸
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const drawings = await db.query(
      'SELECT * FROM drawings WHERE id = ?',
      [id]
    );
    
    if (drawings.length === 0) {
      return res.status(404).json({
        code: 404,
        message: '图纸不存在'
      });
    }
    
    res.json({
      code: 200,
      message: 'success',
      data: drawings[0]
    });
  } catch (error) {
    console.error('获取图纸详情失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取图纸详情失败',
      error: error.message
    });
  }
});

module.exports = router; 