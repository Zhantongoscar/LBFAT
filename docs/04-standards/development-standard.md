# 开发规范

## 1. 项目结构
```
LBFAT/
├── backend/           # 后端服务
│   ├── src/          # 源代码
│   │   ├── config/   # 配置文件
│   │   ├── controllers/  # 控制器
│   │   ├── models/   # 数据模型
│   │   ├── routes/   # 路由定义
│   │   ├── services/ # 业务服务
│   │   └── utils/    # 工具函数
│   ├── tests/        # 测试文件
│   ├── Dockerfile    # 后端Docker配置
│   └── package.json  # 依赖配置
├── frontend/         # 前端服务
│   ├── src/         # 源代码
│   │   ├── api/     # API调用
│   │   ├── components/  # 组件
│   │   ├── views/   # 页面
│   │   ├── store/   # 状态管理
│   │   └── utils/   # 工具函数
│   ├── tests/       # 测试文件
│   ├── Dockerfile   # 前端Docker配置
│   └── package.json # 依赖配置
├── docker/          # Docker相关配置
│   ├── mysql/       # MySQL配置
│   │   ├── init.sql # 数据库初始化脚本
│   │   └── conf.d/  # MySQL配置文件
│   └── emqx/        # EMQX配置
│       └── etc/     # EMQX配置文件
├── docs/            # 项目文档
│   ├── 01-requirements/     # 需求文档
│   ├── 02-architecture/     # 架构设计
│   ├── 03-detailed-design/  # 详细设计
│   └── 04-standards/        # 开发规范
├── tests/           # 集成测试
├── .env.example     # 环境变量示例
├── .gitignore      # Git忽略文件
└── docker-compose.yml # Docker编排配置
```

## 2. 代码规范

### 2.1 命名规范
- 文件名：小写字母，单词间用连字符（-）分隔
- 变量名：驼峰命名法
- 常量：大写字母，单词间用下划线（_）分隔
- 类名：首字母大写的驼峰命名法
- 数据库表名：小写字母，单词间用下划线分隔
- 环境变量：大写字母，单词间用下划线分隔

### 2.2 代码风格
- 缩进：使用2个空格
- 最大行长：80个字符
- 字符串：优先使用单引号
- 分号：必须使用
- 括号：同一行放置左括号

### 2.3 注释规范
- 文件头部必须包含文件说明、作者、日期
- 函数注释必须包含：
  * 功能说明
  * 参数说明
  * 返回值说明
  * 错误处理说明
- 复杂逻辑必须添加行内注释

### 2.4 Git提交规范
- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 重构
- test: 测试相关
- chore: 构建过程或辅助工具的变动

### 2.5 错误处理规范
- 统一使用自定义错误类
- 错误信息必须包含错误码
- 所有异步操作必须使用 try-catch
- 记录详细的错误堆栈

### 2.6 测试规范
- 单元测试覆盖率要求：80%以上
- 必须包含正向和反向测试用例
- 使用模拟数据进行测试
- 测试代码必须有注释

## 3. 数据库规范

### 3.1 命名规范
- 表名：小写字母，单词间用下划线分隔
- 字段名：小写字母，单词间用下划线分隔
- 主键：id
- 外键：关联表名_id

### 3.2 字段规范
- 必须包含 created_at 和 updated_at
- 使用 COMMENT 说明字段用途
- 适当使用索引提高查询效率
- 字段类型选择原则：
  * 定长字符串：CHAR
  * 变长字符串：VARCHAR
  * 大文本：TEXT
  * 整数：INT/BIGINT
  * 小数：DECIMAL
  * 时间：DATETIME
  * 布尔：TINYINT(1)

## 4. API规范

### 4.1 RESTful API
- GET：查询
- POST：创建
- PUT：更新
- DELETE：删除
- PATCH：部分更新

### 4.2 请求格式
```json
{
    "data": {},
    "meta": {
        "page": 1,
        "limit": 10,
        "total": 100
    }
}
```

### 4.3 响应格式
```json
{
    "code": 200,
    "message": "success",
    "data": {},
    "meta": {
        "timestamp": "2023-12-03T10:00:00Z"
    }
}
```

### 4.4 状态码
- 200：成功
- 201：创建成功
- 400：请求错误
- 401：未授权
- 403：禁止访问
- 404：资源不存在
- 500：服务器错误

## 5. 日志规范

### 5.1 日志级别
- ERROR：错误信息
- WARN：警告信息
- INFO：一般信息
- DEBUG：调试信息

### 5.2 日志格式
```
[时间] [级别] [模块] 消息
```

### 5.3 基本监控指标
- API响应时间
- 错误率统计
- 在线设备数
- MQTT消息量