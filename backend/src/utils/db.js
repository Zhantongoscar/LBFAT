const mysql = require("mysql2/promise");

const pool = mysql.createPool({
    host: process.env.DB_HOST || "mysql",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "13701033228",
    database: process.env.DB_NAME || "lbfat",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    connectTimeout: 60000,
    acquireTimeout: 60000,
    timeout: 60000,
    enableKeepAlive: true,
    keepAliveInitialDelay: 10000
});

pool.on('error', (err) => {
    console.error('数据库池错误:', err);
});

const testConnection = async (retries = 5, delay = 5000) => {
    for (let i = 0; i < retries; i++) {
        try {
            const connection = await pool.getConnection();
            console.log("数据库连接成功");
            console.log("连接信息:", {
                host: process.env.DB_HOST || "mysql",
                user: process.env.DB_USER || "root",
                database: process.env.DB_NAME || "lbfat"
            });
            connection.release();
            return true;
        } catch (err) {
            console.error(`数据库连接尝试 ${i + 1}/${retries} 失败:`, err);
            if (i < retries - 1) {
                console.log(`等待 ${delay/1000} 秒后重试...`);
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }
    }
    throw new Error('数据库连接失败，已达到最大重试次数');
};

module.exports = {
    testConnection,
    getConnection: async () => {
        try {
            const connection = await pool.getConnection();
            console.log('获取数据库连接成功');
            return connection;
        } catch (error) {
            console.error('获取数据库连接失败:', error);
            throw error;
        }
    },

    query: async (sql, params) => {
        let connection;
        try {
            connection = await pool.getConnection();
            console.log('执行SQL查询:', {
                sql,
                params: params || []
            });
            const [rows] = await connection.execute(sql, params || []);
            console.log('查询结果行数:', rows.length);
            return rows;
        } catch (error) {
            console.error('数据库查询错误:', error);
            console.error('查询参数:', {
                sql,
                params: params || []
            });
            throw error;
        } finally {
            if (connection) {
                connection.release();
                console.log('数据库连接已释放');
            }
        }
    }
};
