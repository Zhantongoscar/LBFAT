const { TestInstance, TestItemInstance } = require('../models');
const { TestStatus, TestResult } = require('../constants/test-status');

// 获取测试实例列表
exports.getTestInstances = async (req, res) => {
  try {
    const instances = await TestInstance.findAll({
      include: [{
        model: TestItemInstance,
        as: 'items'
      }],
      order: [['createdAt', 'DESC']]
    });
    res.json(instances);
  } catch (error) {
    console.error('Error getting test instances:', error);
    res.status(500).json({ message: '获取测试实例列表失败' });
  }
};

// 创建测试实例
exports.createTestInstance = async (req, res) => {
  try {
    const { name } = req.body;
    const instance = await TestInstance.create({
      name: name || `测试实例_${Date.now()}`,
      status: TestStatus.PENDING,
      result: TestResult.UNKNOWN
    });
    res.status(201).json(instance);
  } catch (error) {
    console.error('Error creating test instance:', error);
    res.status(500).json({ message: '创建测试实例失败' });
  }
};

// 获取单个测试实例详情
exports.getTestInstance = async (req, res) => {
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
};

// 开始测试
exports.startTest = async (req, res) => {
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
      startTime: new Date()
    });

    res.json(instance);
  } catch (error) {
    console.error('Error starting test:', error);
    res.status(500).json({ message: '开始测试失败' });
  }
};

// 完成/中止测试
exports.completeTest = async (req, res) => {
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
      endTime: new Date()
    });

    res.json(instance);
  } catch (error) {
    console.error('Error completing test:', error);
    res.status(500).json({ message: '完成测试失败' });
  }
};

// 更新测试项状态
exports.updateTestItemStatus = async (req, res) => {
  try {
    const { id, itemId } = req.params;
    const { status, result } = req.body;

    const testItem = await TestItemInstance.findOne({
      where: {
        testInstanceId: id,
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
}; 