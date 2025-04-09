# LBFAT项目结构


zt 2025 0409
projectroot/
├── frontend/                # 前端项目
│   ├── src/                # 源代码
│   │   ├── assets/        # 静态资源
│   │   ├── components/    # 组件
│   │   ├── views/         # 页面
│   │   ├── store/         # 状态管理
│   │   ├── utils/         # 工具函数
│   │   └── api/           # API接口
│   ├── public/            # 公共资源
│   ├── tests/             # 测试文件
│   ├── package.json       # 依赖配置
│   └── vue.config.js      # Vue配置
│
├── backend/                # 后端项目
│   ├── src/               # 源代码
│   │   ├── controllers/   # 控制器
│   │   ├── services/      # 服务层
│   │   ├── models/        # 数据模型
│   │   └── utils/         # 工具函数
│   ├── config/            # 配置文件
│   ├── tests/             # 测试文件
│   └── package.json       # 依赖配置
│
├── docker/                 # Docker配置
│   ├── frontend/          # 前端Docker配置
│   │   ├── Dockerfile
│   │   └── nginx.conf
│   ├── backend/           # 后端Docker配置
│   │   ├── Dockerfile
│   │   └── .env.example
│   ├── mysql/             # MySQL配置
│   │   ├── Dockerfile
│   │   ├── init.sql
│   │   └── my.cnf
│   └── emqx/              # EMQX配置
│       ├── Dockerfile
│       └── emqx.conf
│
├── scripts/               # 部署和维护脚本
│   ├── deploy.sh         # 部署脚本
│   ├── backup.sh         # 备份脚本
│   └── init-dev.sh       # 开发环境初始化
│
└── docker-compose.yml     # 容器编排配置

## 开发和部署说明

### 1. 开发环境设置
- 初始化开发环境: ./scripts/init-dev.sh
- 启动开发环境: docker-compose -f docker-compose.dev.yml up

### 2. 生产环境部署
- 部署应用: ./scripts/deploy.sh
- 备份数据: ./scripts/backup.sh

### 3. 容器说明
- frontend: Vue.js前端应用
- backend: Node.js后端服务
- mysql: 数据库服务
- emqx: MQTT消息服务
