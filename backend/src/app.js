const express = require('express');
const cors = require('cors');
const projectRoutes = require('./routes/project-routes');
const deviceRoutes = require('./routes/device-routes');
const deviceTypeRoutes = require('./routes/device-type-routes');

const app = express();

// CORS配置
const corsOptions = {
    origin: process.env.CORS_ORIGIN || 'http://localhost:8080',
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
app.use('/api/projects', projectRoutes);
app.use('/api/devices', deviceRoutes);
app.use('/api/deviceTypes', deviceTypeRoutes);

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
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running at http://0.0.0.0:${PORT}`);
    console.log(`Process ID: ${process.pid}`);
}); 