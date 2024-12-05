const mysql = require("mysql2/promise");

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
        console.log("数据库连接成功");
        console.log("连接信息:", {
            host: process.env.DB_HOST || "mysql",
            user: process.env.DB_USER || "root",
            database: process.env.DB_NAME || "lbfat"
        });
        connection.release();
    })
    .catch(err => {
        console.error("数据库连接错误:", err);
        console.error("连接配置:", {
            host: process.env.DB_HOST || "mysql",
            user: process.env.DB_USER || "root",
            database: process.env.DB_NAME || "lbfat"
        });
    });

// 导出数据库工具
module.exports = {
    // 获取数据库连接
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

    // 执行查询
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
