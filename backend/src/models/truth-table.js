const { Model, DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

class TruthTable extends Model {}

TruthTable.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true
  },
  description: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  version: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('draft', 'published', 'deprecated'),
    defaultValue: 'draft'
  }
}, {
  sequelize,
  modelName: 'TruthTable',
  tableName: 'truth_tables',
  timestamps: true,
  underscored: true
});

module.exports = TruthTable; 