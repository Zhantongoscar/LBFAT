const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    const ProjectSubscription = sequelize.define('ProjectSubscription', {
        id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true
        },
        project_name: {
            type: DataTypes.STRING(32),
            allowNull: false,
            unique: true
        },
        is_subscribed: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true
        }
    }, {
        tableName: 'project_subscriptions',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at'
    });

    return ProjectSubscription;
}; 