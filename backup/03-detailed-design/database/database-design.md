/**
 * 数据库设计文档
 * @description 定义数据库结构、关系和索引设计
 * @author -
 * @date 2024-01-21
 */

## 1. 数据库环境
### 1.1 基本配置
- 数据库版本: MySQL 5.7+
- 字符集: utf8mb4
- 排序规则: utf8mb4_unicode_ci
- 时区设置: UTC (+00:00)

### 1.2 连接配置
```yaml
host: localhost
port: 3306
database: lb_fat
username: ${DB_USERNAME}
password: ${DB_PASSWORD}
```

## 2. 表结构设计
### 2.1 设备类型表 (device_types)
| 字段名      | 类型          | 约束                | 说明         |
|------------|--------------|-------------------|-------------|
| id         | BIGINT       | PK, AUTO_INCREMENT| 主键ID       |
| type_code  | VARCHAR(50)  | NOT NULL, UNIQUE  | 设备类型编码   |
| type_name  | VARCHAR(100) | NOT NULL          | 设备类型名称   |
| description| TEXT         | NULL              | 设备类型描述   |
| created_at | TIMESTAMP    | DEFAULT CURRENT   | 创建时间      |
| updated_at | TIMESTAMP    | ON UPDATE CURRENT | 更新时间      |

索引：
- PRIMARY KEY (id)
- UNIQUE INDEX idx_type_code (type_code)

### 2.2 设备表 (devices)
| 字段名         | 类型         | 约束               | 说明         |
|--------------|-------------|-------------------|-------------|
| id           | BIGINT      | PK, AUTO_INCREMENT| 主键ID       |
| device_id    | BIGINT      | NOT NULL, UNIQUE  | 设备唯一标识，从1001开始  |
| user_project | VARCHAR(50) | NOT NULL          | 所属用户项目   |
| device_type  | VARCHAR(50) | NOT NULL, FK      | 设备类型      |
| status       | VARCHAR(20) | NOT NULL          | 设备状态      |
| rssi         | INT         | NULL              | 信号强度      |
| last_online_at| TIMESTAMP  | NULL              | 最后在线时间   |
| created_at   | TIMESTAMP   | DEFAULT CURRENT   | 创建时间      |
| updated_at   | TIMESTAMP   | ON UPDATE CURRENT | 更新时间      |

索引：
- PRIMARY KEY (id)
- UNIQUE INDEX idx_device_id (device_id)
- INDEX idx_project_type (user_project, device_type)
- FOREIGN KEY fk_device_type (device_type) REFERENCES device_types(type_code)

### 2.3 测试会话表 (test_sessions)
| 字段名         | 类型         | 约束               | 说明         |
|--------------|-------------|-------------------|-------------|
| id           | BIGINT      | PK, AUTO_INCREMENT| 主键ID       |
| session_id   | VARCHAR(50) | NOT NULL, UNIQUE  | 会话唯一标识   |
| device_id    | VARCHAR(50) | NOT NULL, FK      | 设备ID       |
| user_project | VARCHAR(50) | NOT NULL          | 所属用户项目   |
| status       | VARCHAR(20) | NOT NULL          | 测试状态      |
| total_steps  | INT         | NOT NULL          | 总步骤数      |
| start_time   | TIMESTAMP   | NOT NULL          | 开始时间      |
| end_time     | TIMESTAMP   | NULL              | 结束时间      |
| created_at   | TIMESTAMP   | DEFAULT CURRENT   | 创建时间      |
| updated_at   | TIMESTAMP   | ON UPDATE CURRENT | 更新时间      |

索引：
- PRIMARY KEY (id)
- UNIQUE INDEX idx_session_id (session_id)
- INDEX idx_device_time (device_id, start_time)
- FOREIGN KEY fk_test_device (device_id) REFERENCES devices(device_id)

### 2.4 测试结果表 (test_results)
| 字段名         | 类型         | 约束               | 说明         |
|--------------|-------------|-------------------|-------------|
| id           | BIGINT      | PK, AUTO_INCREMENT| 主键ID       |
| session_id   | VARCHAR(50) | NOT NULL, FK      | 测试会话ID    |
| step_name    | VARCHAR(100)| NOT NULL          | 步骤名称      |
| step         | INT         | NOT NULL          | 测试步骤      |
| status       | VARCHAR(20) | NOT NULL          | 步骤状态      |
| success      | BOOLEAN     | NOT NULL          | 是否成功      |
| result_value | DECIMAL(10,2)| NULL             | 测试结果值    |
| result_unit  | VARCHAR(20) | NULL              | 结果单位      |
| error_code   | VARCHAR(50) | NULL              | 错误代码      |
| error_message| TEXT        | NULL              | 错误信息      |
| created_at   | TIMESTAMP   | DEFAULT CURRENT   | 创建时间      |

索引：
- PRIMARY KEY (id)
- INDEX idx_session_step (session_id, step)
- FOREIGN KEY fk_test_session (session_id) REFERENCES test_sessions(session_id)

## 3. 枚举值定义
### 3.1 测试状态 (test_sessions.status)
- pending: 待执行
- running: 执行中
- paused: 已暂停
- completed: 已完成
- failed: 执行失败

### 3.2 测试步骤状态 (test_results.status)
- pending: 待执行
- running: 执行中
- success: 执行成功
- failed: 执行失败

### 3.3 设备状态 (devices.status)
- online: 在线
- offline: 离线