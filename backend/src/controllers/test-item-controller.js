const TestItem = require('../models/test-item');
const { Op } = require('sequelize');

class TestItemController {
  // 获取指定测试组的所有测试项
  static async getByGroupId(req, res) {
    try {
      const { groupId } = req.params;
      const items = await TestItem.findAll({
        where: { test_group_id: groupId },
        order: [['sequence', 'ASC']]
      });
      res.json(items);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // 创建新测试项
  static async create(req, res) {
    try {
      const item = await TestItem.create(req.body);
      res.status(201).json(item);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // 更新测试项
  static async update(req, res) {
    try {
      const { id } = req.params;
      const [updated] = await TestItem.update(req.body, {
        where: { id }
      });
      if (updated) {
        const item = await TestItem.findByPk(id);
        res.json(item);
      } else {
        res.status(404).json({ error: '测试项不存在' });
      }
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // 删除测试项
  static async delete(req, res) {
    try {
      const { id } = req.params;
      const deleted = await TestItem.destroy({
        where: { id }
      });
      if (deleted) {
        res.status(204).send();
      } else {
        res.status(404).json({ error: '测试项不存在' });
      }
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // 批量更新测试项顺序
  static async updateSequences(req, res) {
    try {
      const { items } = req.body;
      await Promise.all(
        items.map(item => 
          TestItem.update(
            { sequence: item.sequence },
            { where: { id: item.id } }
          )
        )
      );
      res.status(200).json({ message: '更新成功' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = TestItemController; 