-- 创建测试实例主表
CREATE TABLE IF NOT EXISTS test_instances (
  id VARCHAR(36) PRIMARY KEY,        -- 实例唯一标识（UUID）
  truth_table_id INT NOT NULL,       -- 关联的真值表ID
  product_sn VARCHAR(50) NOT NULL,   -- 产品序列号
  operator VARCHAR(50) NOT NULL,     -- 操作员
  status ENUM('pending','running','completed','aborted') DEFAULT 'pending',  -- 测试状态
  result ENUM('unknown','pass','fail') DEFAULT 'unknown',  -- 测试结果
  start_time DATETIME,               -- 开始时间
  end_time DATETIME,                 -- 结束时间
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 创建时间
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 更新时间
  FOREIGN KEY (truth_table_id) REFERENCES truth_tables(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试实例主表';

-- 创建测试项实例表
CREATE TABLE IF NOT EXISTS test_item_instances (
  id INT AUTO_INCREMENT PRIMARY KEY,  -- 主键
  instance_id VARCHAR(36) NOT NULL,   -- 关联的测试实例ID
  test_item_id INT NOT NULL,         -- 关联的测试项ID
  execution_status ENUM('pending','running','completed','skipped','timeout') DEFAULT 'pending', -- 执行状态
  result_status ENUM('unknown','pass','fail','error') DEFAULT 'unknown',  -- 结果状态
  actual_value FLOAT,                -- 实际测试值
  error_message TEXT,                -- 错误信息
  start_time DATETIME,               -- 开始时间
  end_time DATETIME,                 -- 结束时间
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instance_id) REFERENCES test_instances(id),
  FOREIGN KEY (test_item_id) REFERENCES test_items(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试项实例表';

-- 创建索引
CREATE INDEX idx_test_instances_truth_table ON test_instances(truth_table_id);
CREATE INDEX idx_test_instances_status ON test_instances(status);
CREATE INDEX idx_test_instances_result ON test_instances(result);
CREATE INDEX idx_test_item_instances_instance ON test_item_instances(instance_id);
CREATE INDEX idx_test_item_instances_item ON test_item_instances(test_item_id);
CREATE INDEX idx_test_item_instances_status ON test_item_instances(execution_status);
CREATE INDEX idx_test_item_instances_result ON test_item_instances(result_status); 