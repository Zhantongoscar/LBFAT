-- 真值表模板主表
CREATE TABLE IF NOT EXISTS test_templates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '模板名称',
    drawing_no VARCHAR(50) NOT NULL COMMENT '图纸编号',
    version VARCHAR(20) NOT NULL COMMENT '版本号',
    description TEXT COMMENT '描述',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_drawing_version` (`drawing_no`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试模板主表';

-- 测试组表
CREATE TABLE IF NOT EXISTS test_groups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    template_id INT NOT NULL COMMENT '所属模板ID',
    test_id INT NOT NULL COMMENT '测试ID',
    level TINYINT NOT NULL DEFAULT 2 COMMENT '测试级别：1-安全类，2-普通类',
    description TEXT COMMENT '测试组描述',
    FOREIGN KEY (template_id) REFERENCES test_templates(id) ON DELETE CASCADE,
    UNIQUE KEY `uk_template_testid` (`template_id`, `test_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试组表';

-- 测试项表
CREATE TABLE IF NOT EXISTS test_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    group_id INT NOT NULL COMMENT '所属测试组ID',
    device_id VARCHAR(50) NOT NULL COMMENT '设备ID',
    unit_id VARCHAR(50) NOT NULL COMMENT '单元ID',
    unit_type VARCHAR(20) NOT NULL COMMENT '单元类型(DI/AI/DO/AO)',
    set_value DECIMAL(10,2) NULL COMMENT '设定值（输出类型时使用）',
    expected_value DECIMAL(10,2) NULL COMMENT '期待值（输入类型时使用）',
    enabled BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用',
    description TEXT COMMENT '测试项描述',
    FOREIGN KEY (group_id) REFERENCES test_groups(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试项表';

-- 测试执行记录表
CREATE TABLE IF NOT EXISTS test_executions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    template_id INT NOT NULL COMMENT '模板ID',
    test_id INT NOT NULL COMMENT '测试ID',
    device_id VARCHAR(50) NOT NULL COMMENT '设备ID',
    unit_id VARCHAR(50) NOT NULL COMMENT '单元ID',
    return_value DECIMAL(10,2) NULL COMMENT '返回值',
    test_result ENUM('pending', 'pass', 'fail') NOT NULL DEFAULT 'pending' COMMENT '测试结果',
    error_message TEXT COMMENT '错误信息',
    execution_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
    FOREIGN KEY (template_id) REFERENCES test_templates(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试执行记录表'; 