const express = require('express');
const cors = require('cors');
const http = require('http');
const projectRoutes = require('./routes/project-routes');
const deviceRoutes = require('./routes/device-routes');
const deviceTypeRoutes = require('./routes/device-type-routes');
const userRoutes = require('./routes/user-routes');
const drawingRoutes = require('./routes/drawing-routes');
const mqttService = require('./services/mqtt-service');
const WebSocketService = require('./services/websocket-service');
const db = require('./utils/db');

const app = express();
const server = http.createServer(app);

// CORS配置
const corsOptions = {
    origin: function(origin, callback) {
        // 允许的源列表
        const allowedOrigins = [
            'http://localhost:8080',
            'http://127.0.0.1:8080',
            `http://${process.env.HOST_IP}:8080`  // 服务器IP
        ];
        // null 源表示同源请求
        if (!origin || allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            callback(new Error('不允许的源'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
};

// 中间件
app.use(cors(corsOptions));
app.use(express.json());

// 添加请求日志
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    console.log('Request Headers:', req.headers);
    next();
});

// API路由
console.log('=== 开始注册路由 ===');

// 添加路由前缀
app.use('/api/projects', projectRoutes);
app.use('/api/devices', deviceRoutes);
app.use('/api/deviceTypes', deviceTypeRoutes);
app.use('/api/users', userRoutes);
app.use('/api/drawings', drawingRoutes);

console.log('=== 路由注册完成 ===');

// 根路径
app.get('/', (req, res) => {
    res.json({ message: 'Leybold Panel Test System API V1.0.0' });
});

// 健康检查
app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

// 错误处理
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        code: 500,
        message: 'Internal Server Error',
        error: err.message
    });
});

const PORT = process.env.PORT || 3000;

// 初始化所有服务
async function initializeServices() {
    try {
        // 测试数据库连接
        console.log('正在连接数据库...');
        await db.testConnection();
        console.log('数据库连接测试成功');

        // 连接MQTT服务
        console.log('正在连接MQTT服务...');
        await mqttService.connect();
        console.log('MQTT服务连接成功');

        // 初始化WebSocket服务
        console.log('正在初始化WebSocket服务...');
        WebSocketService.initialize(server);
        console.log('WebSocket服务初始化成功');

        // 启动HTTP服务器
        server.listen(PORT, '0.0.0.0', () => {
            console.log(`服务器正在运行: http://0.0.0.0:${PORT}`);
            console.log(`程ID: ${process.pid}`);
            console.log('所有服务初始化完成');
        });
    } catch (error) {
        console.error('服务初始化失败:', error);
        // 给系统一些时间来完成日志写入
        setTimeout(() => {
            process.exit(1);
        }, 1000);
    }
}

// 优雅关闭
process.on('SIGTERM', async () => {
    console.log('收到 SIGTERM 信号，开始优雅关闭...');
    server.close(() => {
        console.log('HTTP 服务器已关闭');
        process.exit(0);
    });
});

process.on('SIGINT', async () => {
    console.log('收到 SIGINT 信号，开始优雅关闭...');
    server.close(() => {
        console.log('HTTP 服务器已关闭');
        process.exit(0);
    });
});

// 启动服务
initializeServices(); 