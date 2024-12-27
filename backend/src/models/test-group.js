const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class TestGroup extends Model {}

TestGroup.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  level: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: {
      min: 1,
      max: 3
    }
  },
  sequence: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  truth_table_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'truth_tables',
      key: 'id'
    }
  }
}, {
  sequelize,
  modelName: 'TestGroup',
  tableName: 'test_groups',
  timestamps: true,
  underscored: true
});

module.exports = TestGroup; 