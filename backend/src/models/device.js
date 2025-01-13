const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

class Device extends Model {}

Device.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  project_name: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  module_type: {
    type: DataTypes.STRING(20),
    allowNull: false
  },
  serial_number: {
    type: DataTypes.STRING(20),
    allowNull: false
  },
  type_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'device_types',
      key: 'id'
    }
  },
  status: {
    type: DataTypes.ENUM('online', 'offline'),
    defaultValue: 'offline'
  },
  rssi: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  sequelize,
  modelName: 'Device',
  tableName: 'devices',
  timestamps: true,
  underscored: true
});

module.exports = Device; 