const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

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
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  sequence: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  input_values: {
    type: DataTypes.JSON,
    allowNull: false,
    defaultValue: {}
  },
  expected_values: {
    type: DataTypes.JSON,
    allowNull: false,
    defaultValue: {}
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

module.exports = TestItem; 