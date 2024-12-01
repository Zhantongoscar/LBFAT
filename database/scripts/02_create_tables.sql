/**
 * @see ../docs/03-detailed-design/database/table-design.md - 数据库表设计
 */

-- 设备类型表
CREATE TABLE device_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    type_code VARCHAR(50) NOT NULL UNIQUE COMMENT '设备类型编码',
    type_name VARCHAR(100) NOT NULL COMMENT '设备类型名称',
    description TEXT COMMENT '设备类型描述',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_type_code (type_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备类型表';

-- 设备表
CREATE TABLE devices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    device_id BIGINT NOT NULL UNIQUE COMMENT '设备唯一标识，从1001开始的整数',
    user_project VARCHAR(50) NOT NULL COMMENT '所属用户项目',
    device_type VARCHAR(50) NOT NULL COMMENT '设备类型',
    status VARCHAR(20) NOT NULL DEFAULT 'offline' COMMENT '设备状态',
    rssi INT NULL COMMENT '信号强度',
    last_online_at TIMESTAMP NULL COMMENT '最后在线时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_device_id (device_id),
    INDEX idx_project_type (user_project, device_type),
    FOREIGN KEY fk_device_type (device_type) REFERENCES device_types(type_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备表';

-- 测试会话表
CREATE TABLE test_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    session_id VARCHAR(50) NOT NULL UNIQUE COMMENT '会话唯一标识',
    device_id BIGINT NOT NULL COMMENT '设备ID',
    user_project VARCHAR(50) NOT NULL COMMENT '所属用户项目',
    status VARCHAR(20) NOT NULL COMMENT '测试状态',
    total_steps INT NOT NULL COMMENT '总步骤数',
    start_time TIMESTAMP NOT NULL COMMENT '开始时间',
    end_time TIMESTAMP NULL COMMENT '结束时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_session_id (session_id),
    INDEX idx_device_time (device_id, start_time),
    FOREIGN KEY fk_test_device (device_id) REFERENCES devices(device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试会话表';

-- 测试结果表
CREATE TABLE test_results (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    session_id VARCHAR(50) NOT NULL COMMENT '测试会话ID',
    step_name VARCHAR(100) NOT NULL COMMENT '步骤名称',
    step INT NOT NULL COMMENT '测试步骤',
    status VARCHAR(20) NOT NULL COMMENT '步骤状态',
    success BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否成功',
    result_value DECIMAL(10,2) NULL COMMENT '测试结果值',
    result_unit VARCHAR(20) NULL COMMENT '结果单位',
    error_code VARCHAR(50) NULL COMMENT '错误代码',
    error_message TEXT NULL COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_session_step (session_id, step),
    FOREIGN KEY fk_test_session (session_id) REFERENCES test_sessions(session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试结果表'; 