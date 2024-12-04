const mysql = require("mysql2/promise");
const logger = require("./logger");

const pool = mysql.createPool({
    host: process.env.DB_HOST || "mysql",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "13701033228",
    database: process.env.DB_NAME || "lbfat",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// 测试连接
pool.getConnection()
    .then(connection => {
        logger.info("Database connected successfully");
        connection.release();
    })
    .catch(err => {
        logger.error("Database connection error:", err);
    });

// 导出查询函数
module.exports = {
    query: async (sql, params) => {
        try {
            const [rows] = await pool.execute(sql, params);
            return rows;
        } catch (error) {
            console.error('Database query error:', error);
            throw error;
        }
    }
};
