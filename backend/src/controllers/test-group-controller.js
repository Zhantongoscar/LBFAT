const TestGroup = require('../models/test-group');

// 获取指定真值表下的所有测试组
exports.getTestGroups = async (req, res) => {
  try {
    console.log('获取测试组列表 - 请求参数:', req.params);
    const { id: truth_table_id } = req.params;
    
    console.log('查询条件:', { truth_table_id });
    const groups = await TestGroup.findAll({
      where: { truth_table_id },
      order: [['sequence', 'ASC']]
    });
    
    console.log('查询结果:', groups);
    res.json({ code: 200, data: groups });
  } catch (error) {
    console.error('获取测试组失败 - 详细错误:', {
      message: error.message,
      stack: error.stack,
      params: req.params
    });
    res.status(500).json({ 
      code: 500, 
      message: '获取测试组失败',
      error: error.message 
    });
  }
};

// 创建测试组
exports.createTestGroup = async (req, res) => {
  try {
    const { id: truth_table_id } = req.params;
    const { description, level, sequence } = req.body;
    const group = await TestGroup.create({
      description,
      level,
      sequence,
      truth_table_id
    });
    res.json({ code: 200, data: group });
  } catch (error) {
    console.error('创建测试组失败:', error);
    res.status(500).json({ code: 500, message: '创建测试组失败' });
  }
};

// 更新测试组
exports.updateTestGroup = async (req, res) => {
  try {
    const { group_id } = req.params;
    const { description, level, sequence } = req.body;
    const group = await TestGroup.findByPk(group_id);
    
    if (!group) {
      return res.status(404).json({ code: 404, message: '测试组不存在' });
    }

    await group.update({ description, level, sequence });
    res.json({ code: 200, data: group });
  } catch (error) {
    console.error('更新测试组失败:', error);
    res.status(500).json({ code: 500, message: '更新测试组失败' });
  }
};

// 删除测试组
exports.deleteTestGroup = async (req, res) => {
  try {
    const { id: truth_table_id, group_id } = req.params;
    console.log('删除测试组，参数:', { truth_table_id, group_id }); // 添加日志
    
    const group = await TestGroup.findOne({
      where: {
        id: group_id,
        truth_table_id
      }
    });
    
    if (!group) {
      console.log('测试组不存在:', { truth_table_id, group_id }); // 添加日志
      return res.status(404).json({ code: 404, message: '测试组不存在' });
    }

    await group.destroy();
    console.log('测试组删除成功:', { truth_table_id, group_id }); // 添加日志
    res.json({ code: 200, message: '删除成功' });
  } catch (error) {
    console.error('删除测试组失败:', error);
    res.status(500).json({ code: 500, message: '删除测试组失败' });
  }
}; 