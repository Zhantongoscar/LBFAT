const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Device = require('./device');

class TestItem extends Model {}

TestItem.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  test_group_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'test_groups',
      key: 'id'
    }
  },
  device_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  point_index: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  name: {
    type: DataTypes.STRING,
    allowNull: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  mode: {
    type: DataTypes.ENUM('read', 'write'),
    allowNull: false,
    defaultValue: 'read'
  },
  sequence: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  input_values: {
    type: DataTypes.FLOAT,
    allowNull: false,
    defaultValue: 0
  },
  expected_values: {
    type: DataTypes.FLOAT,
    allowNull: false,
    defaultValue: 0
  },
  timeout: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 5000 // 默认5秒
  }
}, {
  sequelize,
  modelName: 'TestItem',
  tableName: 'test_items',
  timestamps: true,
  underscored: true
});

// 定义关联关系
TestItem.belongsTo(Device, {
  foreignKey: 'device_id',
  as: 'device'
});

module.exports = TestItem; 