const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class TestInstance extends Model {}

TestInstance.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  truth_table_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'truth_tables',
      key: 'id'
    }
  },
  product_sn: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  operator: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'running', 'completed', 'aborted'),
    defaultValue: 'pending'
  },
  result: {
    type: DataTypes.ENUM('unknown', 'pass', 'fail'),
    defaultValue: 'unknown'
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
  modelName: 'TestInstance',
  tableName: 'test_instances',
  timestamps: true,
  underscored: true
});

module.exports = TestInstance; 