const express = require('express');
const cors = require('cors');
const { sequelize } = require('./models');
const mqttService = require('./services/mqttService');
const config = require('./config/config');
const projectRoutes = require('./routes/projectRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// API文档
app.get('/', (req, res) => {
    res.json({
        name: 'LBFAT Backend API',
        version: '1.0.0',
        endpoints: {
            health: {
                method: 'GET',
                path: '/health',
                description: '健康检查'
            },
            projects: {
                list: {
                    method: 'GET',
                    path: '/api/projects',
                    description: '获取所有项目列表'
                },
                create: {
                    method: 'POST',
                    path: '/api/projects',
                    description: '创建新项目',
                    body: {
                        project_name: 'string',
                        is_subscribed: 'boolean'
                    }
                },
                updateSubscription: {
                    method: 'PUT',
                    path: '/api/projects/:project_name/subscription',
                    description: '更新项目订阅状态',
                    body: {
                        is_subscribed: 'boolean'
                    }
                },
                delete: {
                    method: 'DELETE',
                    path: '/api/projects/:project_name',
                    description: '删除项目'
                }
            }
        }
    });
});

// 基础健康检查
app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

// 项目管理路由
app.use('/api/projects', projectRoutes);

// 启动服务器
async function startServer() {
    try {
        // 连接数据库
        await sequelize.authenticate();
        console.log('Database connected.');

        // 连接MQTT
        await mqttService.connect();
        console.log('MQTT service started.');

        // 启动HTTP服务器
        app.listen(config.server.port, () => {
            console.log(`Server running on port ${config.server.port}`);
        });
    } catch (error) {
        console.error('Error starting server:', error);
        process.exit(1);
    }
}

startServer(); 