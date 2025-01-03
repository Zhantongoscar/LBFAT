const TestItem = require('../models/test-item');
const { Op } = require('sequelize');

class TestItemController {
  // 获取指定测试组的所有测试项
  static async getByGroupId(req, res) {
    try {
      const { groupId } = req.params;
      console.log('\n========== 测试项查询开始 ==========');
      console.log('请求URL:', req.originalUrl);
      console.log('请求方法:', req.method);
      console.log('请求参数 - groupId:', groupId);
      console.log('请求头:', JSON.stringify(req.headers, null, 2));
      
      console.log('\n----- 开始数据库查询 -----');
      console.log('查询条件:', { test_group_id: groupId });
      
      const items = await TestItem.findAll({
        where: { test_group_id: groupId },
        include: [{
          model: require('../models/device'),
          as: 'device',
          attributes: ['project_name', 'module_type', 'serial_number']
        }],
        order: [['sequence', 'ASC']],
        raw: true,
        nest: true,
        logging: (sql) => {
          console.log('\n执行的SQL语句:', sql);
        }
      });
      
      console.log('\n----- 数据库查询结果 -----');
      console.log('查询到的记录数:', items.length);
      console.log('查询结果:', JSON.stringify(items, null, 2));
      
      const response = {
        code: 200,
        message: 'success',
        data: items || []
      };
      
      console.log('\n----- 发送响应数据 -----');
      console.log('响应数据:', JSON.stringify(response, null, 2));
      
      res.json(response);
      console.log('\n========== 测试项查询完成 ==========\n');
    } catch (error) {
      console.error('\n========== 测试项查询失败 ==========');
      console.error('错误类型:', error.name);
      console.error('错误消息:', error.message);
      console.error('错误堆栈:', error.stack);
      console.error('================================\n');
      
      res.status(500).json({
        code: 500,
        message: '获取测试项失败',
        error: error.message
      });
    }
  }

  // 创建新测试项
  static async create(req, res) {
    try {
      console.log('\n========== 创建测试项开始 ==========');
      console.log('请求体数据:', JSON.stringify(req.body, null, 2));
      
      const item = await TestItem.create(req.body);
      console.log('创建成功，新记录:', JSON.stringify(item, null, 2));
      
      res.status(201).json({
        code: 201,
        message: '创建成功',
        data: item
      });
      
      console.log('\n========== 创建测试项完成 ==========\n');
    } catch (error) {
      console.error('\n========== 创建测试项失败 ==========');
      console.error('错误类型:', error.name);
      console.error('错误消息:', error.message);
      console.error('错误堆栈:', error.stack);
      console.error('================================\n');
      
      // 根据错误类型返回不同的状态码
      const statusCode = error.name === 'SequelizeValidationError' ? 400 : 500;
      
      res.status(statusCode).json({
        code: statusCode,
        message: '创建失败',
        error: error.message
      });
    }
  }

  // 更新测试项
  static async update(req, res) {
    try {
      const { id } = req.params;
      console.log('\n========== 更新测试项开始 ==========');
      console.log('请求参数 - id:', id);
      console.log('请求体:', JSON.stringify(req.body, null, 2));

      const [updated] = await TestItem.update(req.body, {
        where: { id }
      });

      if (updated) {
        const item = await TestItem.findByPk(id);
        console.log('更新成功，更新后的数据:', JSON.stringify(item, null, 2));
        res.json({
          code: 200,
          message: '更新成功',
          data: item
        });
      } else {
        console.log('测试项不存在');
        res.status(404).json({
          code: 404,
          message: '测试项不存在'
        });
      }
      console.log('\n========== 更新测试项完成 ==========\n');
    } catch (error) {
      console.error('\n========== 更新测试项失败 ==========');
      console.error('错误类型:', error.name);
      console.error('错误消息:', error.message);
      console.error('错误堆栈:', error.stack);
      console.error('================================\n');
      
      res.status(500).json({
        code: 500,
        message: '更新测试项失败',
        error: error.message
      });
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