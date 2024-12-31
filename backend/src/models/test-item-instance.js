const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class TestItemInstance extends Model {}

TestItemInstance.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  instance_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'test_instances',
      key: 'id'
    }
  },
  test_item_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'test_items',
      key: 'id'
    }
  },
  execution_status: {
    type: DataTypes.ENUM('pending', 'running', 'completed', 'skipped', 'timeout'),
    defaultValue: 'pending'
  },
  result_status: {
    type: DataTypes.ENUM('unknown', 'pass', 'fail', 'error'),
    defaultValue: 'unknown'
  },
  actual_value: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  error_message: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  start_time: {
    type: DataTypes.DATE,
    allowNull: true
  },
  end_time: {
    type: DataTypes.DATE,
    allowNull: true
  }
}, {
  sequelize,
  modelName: 'TestItemInstance',
  tableName: 'test_item_instances',
  timestamps: true,
  underscored: true
});

module.exports = TestItemInstance; 