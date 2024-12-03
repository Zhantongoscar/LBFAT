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
const Device = require('./device')(sequelize);

module.exports = {
    sequelize,
    ProjectSubscription,
    Device
}; 