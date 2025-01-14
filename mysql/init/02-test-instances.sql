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