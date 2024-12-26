const TestGroup = require('../models/test-group');

// 获取指定真值表下的所有测试组
exports.getTestGroups = async (req, res) => {
  try {
    const { truth_table_id } = req.params;
    const groups = await TestGroup.findAll({
      where: { truth_table_id },
      order: [['sequence', 'ASC']]
    });
    res.json({ code: 200, data: groups });
  } catch (error) {
    console.error('获取测试组失败:', error);
    res.status(500).json({ code: 500, message: '获取测试组失败' });
  }
};

// 创建测试组
exports.createTestGroup = async (req, res) => {
  try {
    const { name, description, level, sequence, truth_table_id } = req.body;
    const group = await TestGroup.create({
      name,
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
    const { id } = req.params;
    const { name, description, level, sequence } = req.body;
    const group = await TestGroup.findByPk(id);
    
    if (!group) {
      return res.status(404).json({ code: 404, message: '测试组不存在' });
    }

    await group.update({ name, description, level, sequence });
    res.json({ code: 200, data: group });
  } catch (error) {
    console.error('更新测试组失败:', error);
    res.status(500).json({ code: 500, message: '更新测试组失败' });
  }
};

// 删除测试组
exports.deleteTestGroup = async (req, res) => {
  try {
    const { id } = req.params;
    const group = await TestGroup.findByPk(id);
    
    if (!group) {
      return res.status(404).json({ code: 404, message: '测试组不存在' });
    }

    await group.destroy();
    res.json({ code: 200, message: '删除成功' });
  } catch (error) {
    console.error('删除测试组失败:', error);
    res.status(500).json({ code: 500, message: '删除测试组失败' });
  }
}; 