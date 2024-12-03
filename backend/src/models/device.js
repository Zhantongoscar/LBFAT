const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    const Device = sequelize.define('Device', {
        id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true
        },
        project_name: {
            type: DataTypes.STRING(32),
            allowNull: false
        },
        module_type: {
            type: DataTypes.STRING(32),
            allowNull: false
        },
        serial_number: {
            type: DataTypes.STRING(32),
            allowNull: false
        },
        status: {
            type: DataTypes.STRING(16),
            allowNull: false,
            defaultValue: 'offline'
        },
        rssi: {
            type: DataTypes.INTEGER,
            allowNull: true
        }
    }, {
        tableName: 'devices',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
        indexes: [
            {
                unique: true,
                fields: ['project_name', 'module_type', 'serial_number']
            }
        ]
    });

    return Device;
}; 