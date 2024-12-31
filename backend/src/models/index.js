const { Sequelize } = require('sequelize');
const config = require('../config/config');

const sequelize = new Sequelize(
    config.database.database,
    config.database.username,
    config.database.password,
    {
        host: config.database.host,
        port: config.database.port,
        dialect: 'mysql',
        logging: false
    }
);

const ProjectSubscription = require('./projectSubscription')(sequelize);
const Device = require('./device');
const TestInstance = require('./test-instance');
const TestItemInstance = require('./test-item-instance');
const TestItem = require('./test-item');
const TestGroup = require('./test-group');
const TruthTable = require('./TruthTable')(sequelize);

// 设置模型关联关系
TestInstance.hasMany(TestItemInstance, {
    foreignKey: 'instance_id',
    as: 'items'
});

TestItemInstance.belongsTo(TestInstance, {
    foreignKey: 'instance_id',
    as: 'instance'
});

TestItemInstance.belongsTo(TestItem, {
    foreignKey: 'test_item_id',
    as: 'testItem'
});

TestInstance.belongsTo(TruthTable, {
    foreignKey: 'truth_table_id',
    as: 'truthTable'
});

module.exports = {
    sequelize,
    ProjectSubscription,
    Device,
    TestInstance,
    TestItemInstance,
    TestItem,
    TestGroup,
    TruthTable
}; 