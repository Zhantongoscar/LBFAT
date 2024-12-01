# 详细设计文档结构

## 目录结构
docs/03-detailed-design/
├── 00-common/                    # 通用定义
│   ├── interfaces/              # 接口定义
│   ├── types/                  # 类型定义
│   └── constants/              # 常量定义
├── 01-core/                     # 核心模块设计
│   ├── mqtt-service.md         # MQTT服务设计
│   ├── database-service.md     # 数据库服务设计
│   └── cache-service.md        # 缓存服务设计
├── 02-modules/                  # 业务模块设计
│   ├── device/                # 设备管理模块
│   ├── test/                 # 测试执行模块
│   └── user/                 # 用户管理模块
└── 03-utils/                    # 工具类设计
    ├── retry.md              # 重试机制
    └── logger.md             # 日志工具
