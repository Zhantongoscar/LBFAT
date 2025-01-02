const { TestInstance, TestItemInstance, TestItem, TestGroup, TruthTable } = require('../models');
const { TestStatus, TestResult } = require('../constants/test-status');
const sequelize = require('../config/database');

// 获取或创建测试项
async function getOrCreateTestItems(instanceId) {
  try {
    // 1. 先查询该实例是否有测试项
    const existingItems = await TestItem.findAll({
      where: { test_instance_id: instanceId }
    });

    // 2. 如果已有测试项，直接返回
    if (existingItems && existingItems.length > 0) {
      return existingItems;
    }

    // 3. 如果没有测试项，则需要创建
    // 3.1 获取测试实例信息
    const testInstance = await TestInstance.findByPk(instanceId, {
      include: [{
        model: TruthTable,
        include: [{
          model: TestGroup,
          include: [TestItem]
        }]
      }]
    });

    // 3.2 基于真值表和测试组的测试项模板创建新的测试项
    if (testInstance && testInstance.TruthTable) {
      const newItems = [];
      for (const group of testInstance.TruthTable.TestGroups) {
        for (const templateItem of group.TestItems) {
          const newItem = await TestItem.create({
            test_instance_id: instanceId,
            test_group_id: group.id,
            name: templateItem.name,
            description: templateItem.description,
            device_id: templateItem.device_id,
            point_index: templateItem.point_index,
            input_values: templateItem.input_values,
            expected_values: templateItem.expected_values,
            timeout: templateItem.timeout,
            sequence: templateItem.sequence
          });
          newItems.push(newItem);
        }
      }
      return newItems;
    }

    throw new Error('无法创建测试项：找不到相关的测试实例或真值表');

  } catch (error) {
    console.error('获取或创建测试项时出错:', error);
    throw error;
  }
}

module.exports = {
  // 获取测试实例列表
  getTestInstances: async (req, res) => {
    try {
      const instances = await TestInstance.findAll({
        include: [{
          model: TestItemInstance,
          as: 'items'
        }],
        order: [['created_at', 'DESC']]
      });
      res.json(instances);
    } catch (error) {
      console.error('Error getting test instances:', error);
      res.status(500).json({ message: '获取测试实例列表失败' });
    }
  },

  // 创建测试实例
  createTestInstance: async (req, res) => {
    try {
      const { truth_table_id, product_sn, operator } = req.body;
      
      if (!truth_table_id || !product_sn || !operator) {
        return res.status(400).json({
          code: 400,
          message: '缺少必要参数：truth_table_id, product_sn, operator 为必填项'
        });
      }

      const instance = await TestInstance.create({
        truth_table_id,
        product_sn,
        operator,
        status: 'pending'
      });

      res.status(201).json({
        code: 201,
        message: '创建测试实例成功',
        data: instance
      });
    } catch (error) {
      console.error('创建测试实例失败:', error);
      res.status(500).json({
        code: 500,
        message: '创建测试实例失败',
        error: error.message
      });
    }
  },

  // 获取测试实例的测试项
  getTestInstanceItems: async (req, res) => {
    try {
      const { instanceId } = req.params;
      const items = await getOrCreateTestItems(instanceId);
      
      res.json({
        code: 200,
        message: '获取测试项成功',
        data: items
      });
    } catch (error) {
      console.error('获取测试项失败:', error);
      res.status(500).json({
        code: 500,
        message: '获取测试项失败',
        error: error.message
      });
    }
  },

  // 获取单个测试实例详情
  getTestInstance: async (req, res) => {
    try {
      const { id } = req.params;
      const instance = await TestInstance.findByPk(id, {
        include: [{
          model: TestItemInstance,
          as: 'items'
        }]
      });
      if (!instance) {
        return res.status(404).json({ message: '测试实例不存在' });
      }
      res.json(instance);
    } catch (error) {
      console.error('Error getting test instance:', error);
      res.status(500).json({ message: '获取测试实例详情失败' });
    }
  },

  // 开始测试
  startTest: async (req, res) => {
    try {
      const { id } = req.params;
      const instance = await TestInstance.findByPk(id);
      if (!instance) {
        return res.status(404).json({ message: '测试实例不存在' });
      }
      
      if (instance.status !== TestStatus.PENDING) {
        return res.status(400).json({ message: '只有待执行的测试实例可以开始' });
      }

      await instance.update({
        status: TestStatus.RUNNING,
        start_time: new Date()
      });

      res.json(instance);
    } catch (error) {
      console.error('Error starting test:', error);
      res.status(500).json({ message: '开始测试失败' });
    }
  },

  // 完成/中止测试
  completeTest: async (req, res) => {
    try {
      const { id } = req.params;
      const { result } = req.body;
      
      const instance = await TestInstance.findByPk(id);
      if (!instance) {
        return res.status(404).json({ message: '测试实例不存在' });
      }

      await instance.update({
        status: TestStatus.COMPLETED,
        result: result || TestResult.UNKNOWN,
        end_time: new Date()
      });

      res.json(instance);
    } catch (error) {
      console.error('Error completing test:', error);
      res.status(500).json({ message: '完成测试失败' });
    }
  },

  // 更新测试项状态
  updateTestItemStatus: async (req, res) => {
    try {
      const { id, itemId } = req.params;
      const { status, result } = req.body;

      const testItem = await TestItemInstance.findOne({
        where: {
          instance_id: id,
          id: itemId
        }
      });

      if (!testItem) {
        return res.status(404).json({ message: '测试项不存在' });
      }

      await testItem.update({ status, result });
      res.json(testItem);
    } catch (error) {
      console.error('Error updating test item status:', error);
      res.status(500).json({ message: '更新测试项状态失败' });
    }
  },

  // 删除测试实例
  deleteTestInstance: async (req, res) => {
    try {
      const { id } = req.params;
      const instance = await TestInstance.findByPk(id);
      
      if (!instance) {
        return res.status(404).json({ message: '测试实例不存在' });
      }

      if (instance.status !== TestStatus.PENDING) {
        return res.status(400).json({ message: '只有待执行的测试实例可以删除' });
      }

      await instance.destroy();
      res.status(200).json({ message: '删除成功' });
    } catch (error) {
      console.error('Error deleting test instance:', error);
      res.status(500).json({ message: '删除测试实例失败' });
    }
  },

  // 创建测试项实例
  createTestItemInstances: async (req, res) => {
    const transaction = await sequelize.transaction();
    
    try {
      const { id } = req.params; // 测试实例ID
      
      // 获取测试实例
      const instance = await TestInstance.findByPk(id, { transaction });
      if (!instance) {
        await transaction.rollback();
        return res.status(404).json({ message: '测试实例不存在' });
      }

      // 获取真值表关联的所有测试组
      const testGroups = await TestGroup.findAll({
        where: { truth_table_id: instance.truth_table_id },
        transaction
      });

      // 获取所有测试组关联的测试项
      const testItems = await TestItem.findAll({
        where: {
          test_group_id: testGroups.map(group => group.id)
        },
        transaction
      });

      // 为每个测试项创建测试项实例
      const testItemInstances = await Promise.all(
        testItems.map(item => 
          TestItemInstance.create({
            instance_id: instance.id,
            test_item_id: item.id,
            execution_status: 'pending',
            result_status: 'unknown',
            actual_value: null,
            error_message: null
          }, { transaction })
        )
      );

      await transaction.commit();
      
      res.status(201).json({
        message: '测试项创建成功',
        count: testItemInstances.length
      });
    } catch (error) {
      await transaction.rollback();
      console.error('Error creating test item instances:', error);
      res.status(500).json({ 
        message: '创建测试项失败',
        error: error.message 
      });
    }
  }
}; 