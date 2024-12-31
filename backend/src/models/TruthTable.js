const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const TruthTable = sequelize.define('TruthTable', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    drawing_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    version: {
      type: DataTypes.STRING(20),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    created_by: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    updated_by: {
      type: DataTypes.INTEGER,
      allowNull: true
    }
  }, {
    tableName: 'truth_tables',
    timestamps: true,
    underscored: true
  });

  TruthTable.associate = (models) => {
    TruthTable.belongsTo(models.Drawing, {
      foreignKey: 'drawing_id',
      as: 'drawing'
    });

    TruthTable.hasMany(models.TestInstance, {
      foreignKey: 'truth_table_id',
      as: 'testInstances'
    });
  };

  return TruthTable;
}; 