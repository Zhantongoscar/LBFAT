-- 创建测试实例主表
CREATE TABLE IF NOT EXISTS test_instances (
  id INT AUTO_INCREMENT PRIMARY KEY,  -- 修改为自增整型
  truth_table_id INT NOT NULL,       -- 关联的真值表ID
  product_sn VARCHAR(50) NOT NULL,   -- 产品序列号
  operator VARCHAR(50) NOT NULL,     -- 操作员
  status ENUM('pending','running','completed','aborted') DEFAULT 'pending',  -- 测试状态
  result ENUM('unknown','pass','fail') DEFAULT 'unknown',  -- 测试结果
  start_time DATETIME,               -- 开始时间
  end_time DATETIME,                 -- 结束时间
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 创建时间
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 更新时间
  FOREIGN KEY (truth_table_id) REFERENCES truth_tables(id),
  INDEX idx_truth_table (truth_table_id),
  INDEX idx_status (status),
  INDEX idx_result (result)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试实例主表';

-- 创建测试组表
CREATE TABLE IF NOT EXISTS test_groups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  truth_table_id INT NOT NULL,
  level TINYINT NOT NULL DEFAULT 0 COMMENT '测试级别：0-普通类，1-安全类',
  description TEXT,
  sequence INT NOT NULL DEFAULT 0,
  enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
  execution_mode ENUM('sequential','parallel') DEFAULT 'sequential' COMMENT '执行模式：顺序/并行',
  failure_strategy ENUM('continue','stop') DEFAULT 'stop' COMMENT '失败策略：继续/停止',
  max_retries INT DEFAULT 0 COMMENT '最大重试次数',
  group_status ENUM('disabled','ready','running','paused','completed') DEFAULT 'ready' COMMENT '组状态',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (truth_table_id) REFERENCES truth_tables(id),
  INDEX idx_group_status (group_status),
  INDEX idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试组表';

-- 创建测试项实例表
CREATE TABLE IF NOT EXISTS test_item_instances (
  id INT AUTO_INCREMENT PRIMARY KEY,
  instance_id INT NOT NULL,
  test_item_id INT NOT NULL,
  test_group_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  device_id INT NOT NULL,
  point_index INT NOT NULL,
  input_values FLOAT NOT NULL DEFAULT 0,
  expected_values FLOAT NOT NULL DEFAULT 0,
  timeout INT NOT NULL DEFAULT 5000,
  sequence INT NOT NULL DEFAULT 0,
  mode ENUM('read', 'write') NOT NULL DEFAULT 'read',
  enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
  execution_status ENUM('disabled','pending','running','completed','skipped','timeout','error') DEFAULT 'pending',
  result_status ENUM('unknown','pass','fail','error') DEFAULT 'unknown',
  actual_value FLOAT,
  failure_reason TEXT COMMENT '失败原因',
  retry_count INT DEFAULT 0 COMMENT '当前重试次数',
  error_message TEXT,
  start_time DATETIME,
  end_time DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instance_id) REFERENCES test_instances(id) ON DELETE CASCADE,
  FOREIGN KEY (test_item_id) REFERENCES test_items(id),
  FOREIGN KEY (test_group_id) REFERENCES test_groups(id),
  FOREIGN KEY (device_id) REFERENCES devices(id),
  INDEX idx_instance (instance_id),
  INDEX idx_test_item (test_item_id),
  INDEX idx_test_group (test_group_id),
  INDEX idx_device (device_id),
  INDEX idx_execution_status (execution_status),
  INDEX idx_result_status (result_status),
  INDEX idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试项实例表';

-- 插入演示测试实例
INSERT INTO `test_instances` (`truth_table_id`, `product_sn`, `operator`, `status`, `result`, `created_at`, `updated_at`)
SELECT 
  id as truth_table_id,
  'demo_project1' as product_sn,
  'root' as operator,
  'pending' as status,
  NULL as result,
  NOW() as created_at,
  NOW() as updated_at
FROM `truth_tables`
WHERE `name` = '安全开关测试'
LIMIT 1; 

-- 创建测试计划表
CREATE TABLE IF NOT EXISTS test_plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '计划名称',
    description TEXT COMMENT '计划描述',
    truth_table_id INT NOT NULL COMMENT '关联真值表ID',
    execution_mode ENUM('sequential','parallel') DEFAULT 'sequential' COMMENT '执行模式',
    failure_strategy ENUM('continue','stop') DEFAULT 'stop' COMMENT '失败策略',
    created_by INT COMMENT '创建人ID',
    updated_by INT COMMENT '最后修改人ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (truth_table_id) REFERENCES truth_tables(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id),
    UNIQUE KEY uk_name_truth_table (name, truth_table_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试计划表';

-- 创建测试计划-组关联表
CREATE TABLE IF NOT EXISTS test_plan_groups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT NOT NULL COMMENT '测试计划ID',
    group_id INT NOT NULL COMMENT '测试组ID',
    sequence INT NOT NULL DEFAULT 0 COMMENT '执行顺序',
    dependencies JSON COMMENT '依赖的其他组ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (plan_id) REFERENCES test_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES test_groups(id) ON DELETE CASCADE,
    UNIQUE KEY uk_plan_group (plan_id, group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试计划-组关联表';

-- 创建测试实例-组执行表
CREATE TABLE IF NOT EXISTS test_instance_groups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    instance_id INT NOT NULL COMMENT '测试实例ID',
    group_id INT NOT NULL COMMENT '测试组ID',
    status ENUM('pending','running','completed','skipped') DEFAULT 'pending' COMMENT '执行状态',
    result ENUM('unknown','pass','fail') DEFAULT 'unknown' COMMENT '测试结果',
    start_time TIMESTAMP NULL COMMENT '开始时间',
    end_time TIMESTAMP NULL COMMENT '结束时间',
    error_message TEXT COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (instance_id) REFERENCES test_instances(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES test_groups(id) ON DELETE CASCADE,
    UNIQUE KEY uk_instance_group (instance_id, group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试实例-组执行表';

-- 修改现有的test_groups表，添加新字段
ALTER TABLE test_groups
ADD COLUMN state_retention BOOLEAN DEFAULT FALSE COMMENT '是否保持状态',
ADD COLUMN dependencies JSON COMMENT '依赖的其他测试组',
ADD COLUMN completion_requirements JSON COMMENT '完成要求';

-- 为每个测试计划添加其关联的测试组
/*
INSERT INTO test_plan_groups (plan_id, group_id, sequence)
SELECT 
    tp.id as plan_id,
    tg.id as group_id,
    tg.sequence as sequence
FROM test_plans tp
JOIN test_groups tg ON tp.truth_table_id = tg.truth_table_id
ON DUPLICATE KEY UPDATE sequence = tg.sequence;
*/

-- 添加测试计划示例数据
/*
INSERT INTO test_plans (name, description, truth_table_id, execution_mode, failure_strategy, created_by)
SELECT 
    CONCAT('默认测试计划-', tt.name) as name,
    CONCAT('针对真值表"', tt.name, '"的默认测试计划') as description,
    tt.id as truth_table_id,
    'sequential' as execution_mode,
    'stop' as failure_strategy,
    (SELECT id FROM users WHERE username = 'root') as created_by
FROM truth_tables tt
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;
*/

-- 创建测试组实例表
CREATE TABLE IF NOT EXISTS test_group_instances (
  id INT PRIMARY KEY AUTO_INCREMENT,
  plan_id INT NOT NULL,
  group_id INT NOT NULL,
  enabled BOOLEAN DEFAULT true,
  config JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (plan_id) REFERENCES test_plans(id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES test_groups(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; 