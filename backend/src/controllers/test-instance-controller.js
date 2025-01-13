const { TestInstance, TestItemInstance, TestItem, TestGroup, TruthTable } = require('../models');
const { TestStatus, TestResult } = require('../constants/test-status');
const sequelize = require('../config/database');
const testMqttService = require('../services/test-mqtt-service');
const logger = require('../utils/logger');

// 获取或创建测试项
async function getOrCreateTestItems(instanceId) {
  try {
    console.log('\n========== 开始获取测试项 ==========');
    console.log('实例ID:', instanceId);

    // 1. 先查询该实例是否有测试项
    console.log('\n----- 步骤1: 查询测试项 -----');
    const existingItems = await TestItemInstance.findAll({
      where: { instance_id: instanceId },
      include: [{
        model: TestItem,
        as: 'testItem',
        required: false,  // LEFT JOIN
        attributes: ['id', 'device_id', 'point_index', 'name', 'test_group_id', 'input_values', 'expected_values'],
        include: [{
          model: TestGroup,
          as: 'group',
          required: false,  // LEFT JOIN
          attributes: ['id', 'description', 'level', 'sequence']
        }]
      }],
      order: [['id', 'ASC']]
    });

    console.log('查询到的测试项数量:', existingItems.length);
    console.log('第一个测试项数据:', JSON.stringify(existingItems[0], null, 2));

    // 2. 如果已有测试项，直接返回成功
    if (existingItems && existingItems.length > 0) {
      console.log('\n----- 步骤2: 处理已存在的测试项 -----');
      // 处理数据，添加所有必要字段
      const processedItems = existingItems.map(item => {
        const testItem = item.testItem || {};
        const group = testItem.group || {};
        const processed = {
          ...item.toJSON(),
          device_id: testItem.device_id,
          point_index: testItem.point_index,
          name: testItem.name,
          test_group_id: testItem.test_group_id,
          group: {
            id: group.id,
            description: group.description,
            level: group.level,
            sequence: group.sequence
          }
        };
        console.log('处理后的测试项:', JSON.stringify(processed, null, 2));
        return processed;
      });
      
      const response = {
        code: 200,
        message: "测试项已存在",
        data: {
          count: processedItems.length,
          items: processedItems
        }
      };
      
      console.log('\n响应数据:', JSON.stringify(response, null, 2));
      console.log('\n========== 获取测试项完成 ==========\n');
      return response;
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

    // 3.2 基于真值表和测试组创建新的测试项实例
    if (testInstance && testInstance.truthTable) {
      const newItems = [];
      for (const group of testInstance.truthTable.groups) {
        for (const item of group.items) {
          const newItem = await TestItemInstance.create({
            instance_id: instanceId,
            test_item_id: item.id,
            execution_status: 'pending',
            result_status: 'unknown'
          });
          newItems.push(newItem);
        }
      }
      return {
        code: 201,
        message: "测试项创建成功",
        data: {
          count: newItems.length,
          items: newItems
        }
      };
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
      console.log('\n========== 获取测试实例列表开始 ==========');
      const instances = await TestInstance.findAll({
        include: [{
          model: TestItemInstance,
          as: 'items',
          include: [{
            model: TestItem,
            as: 'testItem',
            attributes: ['id', 'device_id', 'point_index', 'name', 'test_group_id', 'input_values', 'expected_values'],
            include: [{
              model: TestGroup,
              as: 'group',
              attributes: ['id', 'description', 'level', 'sequence']
            }]
          }]
        }],
        order: [['created_at', 'DESC']]
      });
      
      console.log('查询到的实例数量:', instances.length);
      console.log('第一个实例的数据:', JSON.stringify(instances[0], null, 2));
      
      res.json(instances);
      console.log('\n========== 获取测试实例列表完成 ==========\n');
    } catch (error) {
      console.error('获取测试实例列表失败:', error);
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
    console.log('\n========== 创建测试项实例开始 ==========');
    console.log('请求参数:', {
        url: req.originalUrl,
        method: req.method,
        params: req.params,
        body: req.body
    });

    const transaction = await sequelize.transaction();
    
    try {
        const { id } = req.params;
        console.log('测试实例ID:', id);
        
        // 1. 查询测试实例及关联数据
        console.log('\n----- 步骤1: 查询测试实例 -----');
        const instance = await TestInstance.findByPk(id, {
            include: [{
                model: TruthTable,
                as: 'truthTable',
                include: [{
                    model: TestGroup,
                    as: 'groups',
                    include: [{
                        model: TestItem,
                        as: 'items'
                    }]
                }]
            }],
            transaction
        });
        console.log('查询到的测试实例:', JSON.stringify(instance, null, 2));

        // 2. 检查测试实例是否存在
        console.log('\n----- 步骤2: 检查测试实例 -----');
        if (!instance) {
            console.log('测试实例不存在');
            await transaction.rollback();
            return res.status(404).json({
                code: 404,
                message: '测试实例不存在',
                debug: {
                    instanceId: id,
                    timestamp: new Date().toISOString()
                }
            });
        }

        // 3. 检查关联的真值表
        console.log('\n----- 步骤3: 检查真值表 -----');
        if (!instance.truthTable) {
            console.log('未找到关联的真值表');
            await transaction.rollback();
            return res.status(404).json({
                code: 404,
                message: '未找到关联的真值表',
                debug: {
                    instanceId: id,
                    truthTableId: instance.truth_table_id,
                    timestamp: new Date().toISOString()
                }
            });
        }
        console.log('关联的真值表:', JSON.stringify(instance.truthTable, null, 2));

        // 4. 检查已存在的测试项
        console.log('\n----- 步骤4: 检查已存在的测试项 -----');
        const existingItems = await TestItemInstance.findAll({
            where: { instance_id: id },
            transaction
        });
        console.log('已存在的测试项数量:', existingItems.length);

        if (existingItems && existingItems.length > 0) {
            console.log('该测试实例已存在测试项');
            await transaction.rollback();
            return res.status(200).json({
                code: 200,
                message: '测试项已存在',
                data: {
                    count: existingItems.length,
                    items: existingItems
                }
            });
        }

        // 5. 创建测试项实例
        console.log('\n----- 步骤5: 创建测试项实例 -----');
        const testItemInstances = [];
        console.log('测试组数量:', instance.truthTable.groups.length);

        for (const group of instance.truthTable.groups) {
            console.log('\n处理测试组:', {
                groupId: group.id,
                description: group.description,
                itemCount: group.items.length
            });

            for (const templateItem of group.items) {
                console.log('创建测试项:', {
                    name: templateItem.name,
                    deviceId: templateItem.device_id,
                    pointIndex: templateItem.point_index
                });

                const newItem = await TestItemInstance.create({
                    instance_id: instance.id,
                    test_item_id: templateItem.id,
                    test_group_id: group.id,
                    name: templateItem.name,
                    description: templateItem.description,
                    device_id: templateItem.device_id,
                    point_index: templateItem.point_index,
                    input_values: templateItem.input_values,
                    expected_values: templateItem.expected_values,
                    timeout: templateItem.timeout,
                    sequence: templateItem.sequence,
                    execution_status: 'pending',
                    result_status: 'unknown',
                    actual_value: null,
                    error_message: null
                }, { transaction });

                testItemInstances.push(newItem);
            }
        }

        console.log('\n----- 步骤6: 提交事务 -----');
        await transaction.commit();
        console.log('事务提交成功');
        
        const response = {
            code: 201,
            message: '测试项创建成功',
            data: {
                count: testItemInstances.length,
                items: testItemInstances
            },
            debug: {
                instanceId: id,
                createdItemsCount: testItemInstances.length,
                timestamp: new Date().toISOString()
            }
        };
        console.log('\n响应数据:', JSON.stringify(response, null, 2));
        res.status(201).json(response);

    } catch (error) {
        console.error('\n========== 创建测试项实例失败 ==========');
        console.error('错误类型:', error.name);
        console.error('错误消息:', error.message);
        console.error('错误堆栈:', error.stack);
        
        await transaction.rollback();
        console.log('事务已回滚');

        res.status(500).json({ 
            code: 500,
            message: '创建测试项失败',
            error: error.message,
            debug: {
                errorType: error.name,
                errorMessage: error.message,
                timestamp: new Date().toISOString(),
                // 如果是Sequelize错误，添加额外信息
                sequelizeError: error.name.includes('Sequelize') ? {
                    fields: error.fields,
                    sql: error.sql,
                    parameters: error.parameters
                } : undefined
            }
        });
    }
    console.log('\n========== 创建测试项实例结束 ==========\n');
  },

  // 执行测试项
  executeTestItem: async (req, res) => {
    const transaction = await sequelize.transaction();
    try {
      const { instanceId, itemId } = req.params;
      logger.info('开始执行测试项:', { instanceId, itemId });

      // 1. 获取测试项实例
      const testItem = await TestItemInstance.findOne({
        where: {
          instance_id: instanceId,
          id: itemId
        },
        include: [{
          model: TestItem,
          as: 'testItem',
          required: true,
          attributes: ['id', 'device_id', 'point_index', 'name', 'test_group_id', 'input_values', 'expected_values', 'mode'],
          include: [{
            model: TestGroup,
            as: 'group',
            required: false,
            attributes: ['id', 'description', 'level', 'sequence']
          }]
        }],
        transaction
      });

      if (!testItem) {
        await transaction.rollback();
        return res.status(404).json({ 
          code: 404,
          message: '测试项不存在' 
        });
      }

      // 2. 检查测试项状态
      if (testItem.execution_status !== 'pending') {
        await transaction.rollback();
        return res.status(400).json({
          code: 400,
          message: '只有待执行的测试项可以执行'
        });
      }

      // 3. 更新状态为执行中
      await testItem.update({
        execution_status: 'running',
        start_time: new Date()
      }, { transaction });

      // 4. 根据mode执行测试
      const { project_name, module_type, serial_number, channel } = testItem.testItem;
      let response;
      
      if (testItem.testItem.mode === 'read') {
        // 读取命令
        response = await testMqttService.sendReadCommand(
          project_name,
          module_type,
          serial_number,
          channel
        );
      } else {
        // 写入命令
        response = await testMqttService.sendWriteCommand(
          project_name,
          module_type,
          serial_number,
          channel,
          testItem.testItem.expected_values
        );
      }

      // 5. 更新测试结果
      const passed = Math.abs(response.value - testItem.testItem.expected_values) <= testItem.testItem.tolerance;
      await testItem.update({
        execution_status: 'completed',
        result_status: passed ? 'passed' : 'failed',
        actual_value: response.value,
        end_time: new Date()
      }, { transaction });

      await transaction.commit();
      
      res.json({
        code: 200,
        message: '测试项执行成功',
        data: {
          id: testItem.id,
          execution_status: 'completed',
          result_status: passed ? 'passed' : 'failed',
          actual_value: response.value,
          expected_value: testItem.testItem.expected_values,
          mode: testItem.testItem.mode
        }
      });

    } catch (error) {
      await transaction.rollback();
      logger.error('执行测试项失败:', error);
      res.status(500).json({
        code: 500,
        message: '执行测试项失败',
        error: error.message
      });
    }
  }
}; 