const { Sequelize } = require('sequelize');

const sequelize = new Sequelize({
  dialect: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  username: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '13701033228',
  database: process.env.DB_NAME || 'lbfat',
  timezone: '+08:00',
  define: {
    timestamps: true,
    underscored: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    deletedAt: 'deleted_at'
  },
  dialectOptions: {
    dateStrings: true,
    typeCast: true
  },
  logging: console.log
});

module.exports = sequelize; 