-- 设置字符集和关闭外键检查
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建并使用数据库
DROP DATABASE IF EXISTS lbfat;
CREATE DATABASE IF NOT EXISTS lbfat;
USE lbfat;

-- =====================================================
-- 表结构定义
-- =====================================================

-- 设备类型表
CREATE TABLE IF NOT EXISTS device_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    point_count INT NOT NULL,
    description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT '设备类型定义表';
-- 设备点位表
CREATE TABLE IF NOT EXISTS device_type_points (
  id INT AUTO_INCREMENT PRIMARY KEY,
  device_type_id INT NOT NULL,
  point_index VARCHAR(60) NOT NULL COMMENT '点位索引，支持数字和特殊字符',
  point_type ENUM('DI','DO','AI','AO') NOT NULL,
  sim_type ENUM('A','B','C','D','F','U','W','DD','PDI','PDO','PAI','PAO','HI','HO') NOT NULL COMMENT '模拟类型',
  point_name VARCHAR(50) NOT NULL,
  mode ENUM('read','write') NOT NULL DEFAULT 'read',
  description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (device_type_id) REFERENCES device_types(id) ON DELETE CASCADE,
  UNIQUE KEY unique_point (device_type_id, point_index)
) COMMENT '设备点位配置表';

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码',
    display_name VARCHAR(100) COMMENT '显示名称',
    email VARCHAR(100) COMMENT '邮箱',
    role ENUM('admin', 'user') DEFAULT 'user' COMMENT '用户角色',
    status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '用户状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_status (status)
) COMMENT '用户管理表';

-- 项目订阅管理表
CREATE TABLE IF NOT EXISTS project_subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(50) NOT NULL UNIQUE COMMENT '项目名称',
    is_subscribed BOOLEAN DEFAULT false COMMENT '是否已订阅',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_project_name (project_name)
) COMMENT '项目订阅管理表';

-- 设备管理表
CREATE TABLE IF NOT EXISTS devices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(50) NOT NULL COMMENT '项目名称',
    module_type VARCHAR(20) NOT NULL COMMENT '模块类型',
    serial_number VARCHAR(20) NOT NULL COMMENT '序列号',
    type_id INT NOT NULL COMMENT '设备类型ID',
    status ENUM('online', 'offline') DEFAULT 'offline' COMMENT '设备状态',
    rssi INT DEFAULT 0 COMMENT '信号强度',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    Location VARCHAR(50) DEFAULT 'X20' COMMENT '设备位置',
    UNIQUE KEY uk_device (project_name, module_type, serial_number),
    INDEX idx_project_name (project_name),
    INDEX idx_status (status),
    INDEX idx_type_id (type_id),
    CONSTRAINT fk_project_name FOREIGN KEY (project_name) 
        REFERENCES project_subscriptions(project_name) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_type_id FOREIGN KEY (type_id)
        REFERENCES device_types(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) COMMENT '设备管理表';

-- MQTT订阅表
CREATE TABLE IF NOT EXISTS mqtt_subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    topic VARCHAR(255) NOT NULL,
    qos INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'MQTT订阅配置表';

-- 图纸表
CREATE TABLE IF NOT EXISTS drawings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  drawing_number VARCHAR(50) NOT NULL COMMENT '图纸编号',
  version VARCHAR(20) NOT NULL COMMENT '版本号',
  description TEXT COMMENT '描述',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uk_drawing_version (drawing_number, version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图纸表';

-- 真值表主表
CREATE TABLE IF NOT EXISTS truth_tables (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL COMMENT '真值表名称',
  drawing_id INT NOT NULL COMMENT '关联图纸ID',
  version VARCHAR(20) NOT NULL COMMENT '版本号',
  description TEXT COMMENT '描述',
  created_by INT COMMENT '创建人ID',
  updated_by INT COMMENT '最后修改人ID',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (drawing_id) REFERENCES drawings(id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (updated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='真值表主表';

-- 测试组表
CREATE TABLE IF NOT EXISTS test_groups (
  id INT PRIMARY KEY AUTO_INCREMENT,
  truth_table_id INT NOT NULL COMMENT '所属真值表ID',
  level TINYINT NOT NULL DEFAULT 0 COMMENT '测试级别：0-普通类，1-安全类',
  description TEXT COMMENT '描述',
  sequence INT NOT NULL DEFAULT 0 COMMENT '显示顺序',
  enable BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用测试组',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (truth_table_id) REFERENCES truth_tables(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试组表';

-- 测试项表
CREATE TABLE IF NOT EXISTS test_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  test_group_id INT NOT NULL COMMENT '所属测试组ID',
  device_id INT NOT NULL COMMENT '关联设备ID',
  point_index INT NOT NULL COMMENT '设备点位索引',
  name VARCHAR(100) COMMENT '测试项名称',
  description TEXT COMMENT '测试项描述',
  mode ENUM('read', 'write') NOT NULL DEFAULT 'read' COMMENT '测试模式',
  sequence INT NOT NULL DEFAULT 0 COMMENT '显示顺序',
  input_values FLOAT NOT NULL DEFAULT 0 COMMENT '输入值',
  expected_values FLOAT NOT NULL DEFAULT 0 COMMENT '预期结果',
  timeout INT NOT NULL DEFAULT 5000 COMMENT '超时时间(毫秒)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (test_group_id) REFERENCES test_groups(id) ON DELETE CASCADE,
  FOREIGN KEY (device_id) REFERENCES devices(id),
  INDEX idx_device (device_id),
  INDEX idx_point_index (point_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试项表';

-- 测试实例表
CREATE TABLE IF NOT EXISTS test_instances (
  id INT PRIMARY KEY AUTO_INCREMENT,
  truth_table_id INT NOT NULL COMMENT '关联真值表ID',
  product_sn VARCHAR(100) NOT NULL COMMENT '产品序列号',
  operator VARCHAR(50) NOT NULL COMMENT '操作员',
  status ENUM('pending', 'running', 'completed', 'aborted') DEFAULT 'pending' COMMENT '执行状态',
  result ENUM('unknown', 'pass', 'fail') DEFAULT 'unknown' COMMENT '测试结果',
  start_time TIMESTAMP NULL COMMENT '开始时间',
  end_time TIMESTAMP NULL COMMENT '结束时间',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (truth_table_id) REFERENCES truth_tables(id),
  INDEX idx_product_sn (product_sn),
  INDEX idx_status (status),
  INDEX idx_result (result)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试实例表';

-- 测试项实例表
CREATE TABLE IF NOT EXISTS test_item_instances (
  id INT PRIMARY KEY AUTO_INCREMENT,
  instance_id INT NOT NULL COMMENT '所属测试实例ID',
  test_item_id INT NOT NULL COMMENT '关联测试项ID',
  test_group_id INT NOT NULL COMMENT '所属测试组ID',
  name VARCHAR(100) NOT NULL COMMENT '测试项名称',
  description TEXT COMMENT '测试项描述',
  device_id INT NOT NULL COMMENT '关联设备ID',
  point_index INT NOT NULL COMMENT '设备点位索引',
  input_values FLOAT NOT NULL DEFAULT 0 COMMENT '输入值',
  expected_values FLOAT NOT NULL DEFAULT 0 COMMENT '预期结果',
  timeout INT NOT NULL DEFAULT 5000 COMMENT '超时时间(毫秒)',
  sequence INT NOT NULL DEFAULT 0 COMMENT '显示顺序',
  mode ENUM('read', 'write') NOT NULL DEFAULT 'read' COMMENT '测试模式',
  execution_status ENUM('pending', 'running', 'completed', 'skipped', 'timeout') DEFAULT 'pending' COMMENT '执行状态',
  result_status ENUM('unknown', 'pass', 'fail', 'error') DEFAULT 'unknown' COMMENT '测试结果',
  actual_value FLOAT NULL COMMENT '实际值',
  error_message TEXT COMMENT '错误信息',
  start_time TIMESTAMP NULL COMMENT '开始时间',
  end_time TIMESTAMP NULL COMMENT '结束时间',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (instance_id) REFERENCES test_instances(id) ON DELETE CASCADE,
  FOREIGN KEY (test_item_id) REFERENCES test_items(id),
  FOREIGN KEY (test_group_id) REFERENCES test_groups(id),
  FOREIGN KEY (device_id) REFERENCES devices(id),
  INDEX idx_instance (instance_id),
  INDEX idx_test_item (test_item_id),
  INDEX idx_test_group (test_group_id),
  INDEX idx_device (device_id),
  INDEX idx_execution_status (execution_status),
  INDEX idx_result_status (result_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试项实例表';

-- =====================================================
-- 初始数据插入
-- =====================================================

-- 插入默认管理员账户 (root/root)
INSERT INTO users (username, password, display_name, role, status) 
VALUES ('root', 'root', '系统管理员', 'admin', 'active')
ON DUPLICATE KEY UPDATE password = VALUES(password);

-- 插入默认普通用户账户 (user/user)
INSERT INTO users (username, password, display_name, role, status)
VALUES ('user', 'user', '普通用户', 'user', 'active')
ON DUPLICATE KEY UPDATE password = VALUES(password);

-- 插入项目数据
INSERT INTO project_subscriptions (project_name, is_subscribed) VALUES
('lb_test', true),
('lb_prod', false);

-- 插入设备数据
INSERT INTO devices (project_name, module_type, serial_number, type_id, status, rssi, Location) VALUES
-- EBD设备 1-20 (Location: X20-X25, 每个5个)
('lb_test', 'EBD', '1', 2, 'offline', 0, 'X20'),
('lb_test', 'EBD', '2', 2, 'offline', 0, 'X20'),
('lb_test', 'EBD', '3', 2, 'offline', 0, 'X20'),
('lb_test', 'EBD', '4', 2, 'offline', 0, 'X20'),
('lb_test', 'EBD', '5', 2, 'offline', 0, 'X20'),
('lb_test', 'EBD', '6', 2, 'offline', 0, 'X21'),
('lb_test', 'EBD', '7', 2, 'offline', 0, 'X21'),
('lb_test', 'EBD', '8', 2, 'offline', 0, 'X21'),
('lb_test', 'EBD', '9', 2, 'offline', 0, 'X21'),
('lb_test', 'EBD', '10', 2, 'offline', 0, 'X21'),
('lb_test', 'EBD', '11', 2, 'offline', 0, 'X22'),
('lb_test', 'EBD', '12', 2, 'offline', 0, 'X22'),
('lb_test', 'EBD', '13', 2, 'offline', 0, 'X22'),
('lb_test', 'EBD', '14', 2, 'offline', 0, 'X22'),
('lb_test', 'EBD', '15', 2, 'offline', 0, 'X22'),
('lb_test', 'EBD', '16', 2, 'offline', 0, 'X23'),
('lb_test', 'EBD', '17', 2, 'offline', 0, 'X23'),
('lb_test', 'EBD', '18', 2, 'offline', 0, 'X23'),
('lb_test', 'EBD', '19', 2, 'offline', 0, 'X23'),
('lb_test', 'EBD', '20', 2, 'offline', 0, 'X23'),
('lb_test', 'EBD', '21', 2, 'offline', 0, 'X24'),
('lb_test', 'EBD', '22', 2, 'offline', 0, 'X24'),
('lb_test', 'EBD', '23', 2, 'offline', 0, 'X24'),
('lb_test', 'EBD', '24', 2, 'offline', 0, 'X24'),
('lb_test', 'EBD', '25', 2, 'offline', 0, 'X24'),
('lb_test', 'EBD', '26', 2, 'offline', 0, 'X25'),
('lb_test', 'EBD', '27', 2, 'offline', 0, 'X25'),
('lb_test', 'EBD', '28', 2, 'offline', 0, 'X25'),
('lb_test', 'EBD', '29', 2, 'offline', 0, 'X25'),
('lb_test', 'EBD', '30', 2, 'offline', 0, 'X25'),

-- EDB设备 1-30
('lb_test', 'EDB', '1', 1, 'offline', 0, 'X20'),
('lb_test', 'EDB', '2', 1, 'offline', 0, 'X20'),
('lb_test', 'EDB', '3', 1, 'offline', 0, 'X20'), 
('lb_test', 'EDB', '4', 1, 'offline', 0, 'X20'),
('lb_test', 'EDB', '5', 1, 'offline', 0, 'X20'),
('lb_test', 'EDB', '6', 1, 'offline', 0, 'X21'),
('lb_test', 'EDB', '7', 1, 'offline', 0, 'X21'),
('lb_test', 'EDB', '8', 1, 'offline', 0, 'X21'),
('lb_test', 'EDB', '9', 1, 'offline', 0, 'X21'),
('lb_test', 'EDB', '10', 1, 'offline', 0, 'X21'),
('lb_test', 'EDB', '11', 1, 'offline', 0, 'X22'),
('lb_test', 'EDB', '12', 1, 'offline', 0, 'X22'),
('lb_test', 'EDB', '13', 1, 'offline', 0, 'X22'),
('lb_test', 'EDB', '14', 1, 'offline', 0, 'X22'),
('lb_test', 'EDB', '15', 1, 'offline', 0, 'X22'),
('lb_test', 'EDB', '16', 1, 'offline', 0, 'X23'),
('lb_test', 'EDB', '17', 1, 'offline', 0, 'X23'),
('lb_test', 'EDB', '18', 1, 'offline', 0, 'X23'),
('lb_test', 'EDB', '19', 1, 'offline', 0, 'X23'),
('lb_test', 'EDB', '20', 1, 'offline', 0, 'X23'),
('lb_test', 'EDB', '21', 1, 'offline', 0, 'X24'),
('lb_test', 'EDB', '22', 1, 'offline', 0, 'X24'),
('lb_test', 'EDB', '23', 1, 'offline', 0, 'X24'),
('lb_test', 'EDB', '24', 1, 'offline', 0, 'X24'),
('lb_test', 'EDB', '25', 1, 'offline', 0, 'X24'),
('lb_test', 'EDB', '26', 1, 'offline', 0, 'X25'),
('lb_test', 'EDB', '27', 1, 'offline', 0, 'X25'),
('lb_test', 'EDB', '28', 1, 'offline', 0, 'X25'),
('lb_test', 'EDB', '29', 1, 'offline', 0, 'X25'),
('lb_test', 'EDB', '30', 1, 'offline', 0, 'X25')
ON DUPLICATE KEY UPDATE status = 'offline';

-- 插入MQTT订阅
INSERT INTO mqtt_subscriptions (topic, qos, is_active) VALUES
('lb_test/+/+/status', 1, TRUE);

-- 插入设备类型数据
INSERT INTO device_types (type_name, point_count, description) VALUES
('EDB', 20, '增强模块 EDB：20点（7DI + 3DO + 10DI）'),
('EBD', 20, '增强模块 EBD：20点（8DO + 4DI + 8DO）'),
('EA', 20, '增强模块 EA：20点（14DO + 6DI）'),
('EC', 20, '增强模块 EC：20点（14DO + 6DI）'),
('EF', 20, '增强模块 EF：20点（20DI）'),
('EW', 20, '增强模块 EW：20点（6DI + 2DO + 12DI）'),
('PDI', 16, 'PLC模块 PDI：16点（16DI）'),
('PDO', 16, 'PLC模块 PDO：16点（16DO）'),
('PAI', 16, 'PLC模块 PAI：16点（16AI）'),
('PAO', 16, 'PLC模块 PAO：16点（16AO）'),
('HI', 20, '人工模块 HI：20点（20AI）'),
('HO', 20, '人工模块 HO：20点（20AO）'),
('D', 6, '普通模块 D：6点（6DI）'),
('B', 6, '普通模块 B：6点（6DO）'),
('A', 6, '普通模块 A：6点（6DO）'),
('C', 6, '普通模块 C：6点（6DO）'),
('F', 6, '普通模块 F：6点（6DI）'),
('W', 6, '普通模块 W：6点（6DI）'),
('EL2809', 16, '16DO'),
('EL1809', 16, '16DI'),
('EL3204', 4, '4AI'),
('EL1859', 8, '8DI 8DO'),
('EL3064', 4, '4AI'),
('EL4132', 2, '2AO'),
('EL8601-8411', 6, '机器人模块 1 2 3di  4 5 do 910di 14ao'),
('EL4004', 4, '4AO'),
('EL3162', 2, '2AI'),
('EL1004', 4, '4DI'),
('EL3314', 4, '4XTC 8pin'),
('EL3403', 8, '8PIN 3U,N 3I,N'),
('EL5151', 8, '8PIN 编码器接口'),
('EK1101', 6, 'EtherCAT耦合器'),
('EK1005', 3, 'EtherCAT扩展模块'),
('EK1122', 4, 'EtherCAT分支模块'),
('FLK-D25', 16, 'D-sub接口模块'),
('EL9100', 3, '电源馈电模块'),
('EL6731', 2, 'PROFIBUS主站模块'),
('GV204-X1', 4, '屏蔽和电源接口'),
('GV204-X2', 8, '编码器输入接口'),
('GV204-X3', 4, '输出接口1'),
('GV204-X4', 8, '输出接口2');

-- 插入EDB设备点位配置
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
-- EDB设备点位（device_type_id = 1）
-- 前7个DI (D类型)
(1, 0, 'DI', 'D', 'DI1', 'read', 'EDB数字输入点1 - 前段'),
(1, 1, 'DI', 'D', 'DI2', 'read', 'EDB数字输入点2 - 前段'),
(1, 2, 'DI', 'D', 'DI3', 'read', 'EDB数字输入点3 - 前段'),
(1, 3, 'DI', 'D', 'DI4', 'read', 'EDB数字输入点4 - 前段'),
(1, 4, 'DI', 'D', 'DI5', 'read', 'EDB数字输入点5 - 前段'),
(1, 5, 'DI', 'D', 'DI6', 'read', 'EDB数字输入点6 - 前段'),
(1, 6, 'DI', 'D', 'DI7', 'read', 'EDB数字输入点7 - 前段'),
-- 3个DO (B类型)
(1, 7, 'DO', 'B', 'DO1', 'write', 'EDB数字输出点1'),
(1, 8, 'DO', 'B', 'DO2', 'write', 'EDB数字输出点2'),
(1, 9, 'DO', 'B', 'DO3', 'write', 'EDB数字输出点3'),
-- 后10个DI (D类型)
(1, 10, 'DI', 'D', 'DI8', 'read', 'EDB数字输入点8 - 中段'),
(1, 11, 'DI', 'D', 'DI9', 'read', 'EDB数字输入点9 - 中段'),
(1, 12, 'DI', 'D', 'DI10', 'read', 'EDB数字输入点10 - 中段'),
(1, 13, 'DI', 'D', 'DI11', 'read', 'EDB数字输入点11 - 中段'),
(1, 14, 'DI', 'D', 'DI12', 'read', 'EDB数字输入点12 - 中段'),
(1, 15, 'DI', 'D', 'DI13', 'read', 'EDB数字输入点13 - 中段'),
(1, 16, 'DI', 'D', 'DI14', 'read', 'EDB数字输入点14 - 中段'),
(1, 17, 'DI', 'D', 'DI15', 'read', 'EDB数字输入点15 - 后段'),
(1, 18, 'DI', 'D', 'DI16', 'read', 'EDB数字输入点16 - 后段'),
(1, 19, 'DI', 'D', 'DI17', 'read', 'EDB数字输入点17 - 后段');

-- EBD设备点位（device_type_id = 2）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
-- 前8个DO (B类型)
(2, 0, 'DO', 'B', 'DO1', 'write', 'EBD数字输出点1'),
(2, 1, 'DO', 'B', 'DO2', 'write', 'EBD数字输出点2'),
(2, 2, 'DO', 'B', 'DO3', 'write', 'EBD数字输出点3'),
(2, 3, 'DO', 'B', 'DO4', 'write', 'EBD数字输出点4'),
(2, 4, 'DO', 'B', 'DO5', 'write', 'EBD数字输出点5'),
(2, 5, 'DO', 'B', 'DO6', 'write', 'EBD数字输出点6'),
(2, 6, 'DO', 'B', 'DO7', 'write', 'EBD数字输出点7'),
(2, 7, 'DO', 'B', 'DO8', 'write', 'EBD数字输出点8'),
-- 中间4个DI (D类型)
(2, 8, 'DI', 'D', 'DI1', 'read', 'EBD数字输入点1'),
(2, 9, 'DI', 'D', 'DI2', 'read', 'EBD数字输入点2'),
(2, 10, 'DI', 'D', 'DI3', 'read', 'EBD数字输入点3'),
(2, 11, 'DI', 'D', 'DI4', 'read', 'EBD数字输入点4'),
-- 后8个DO (B类型)
(2, 12, 'DO', 'B', 'DO9', 'write', 'EBD数字输出点9'),
(2, 13, 'DO', 'B', 'DO10', 'write', 'EBD数字输出点10'),
(2, 14, 'DO', 'B', 'DO11', 'write', 'EBD数字输出点11'),
(2, 15, 'DO', 'B', 'DO12', 'write', 'EBD数字输出点12'),
(2, 16, 'DO', 'B', 'DO13', 'write', 'EBD数字输出点13'),
(2, 17, 'DO', 'B', 'DO14', 'write', 'EBD数字输出点14'),
(2, 18, 'DO', 'B', 'DO15', 'write', 'EBD数字输出点15'),
(2, 19, 'DO', 'B', 'DO16', 'write', 'EBD数字输出点16');

-- 插入图纸数据
INSERT INTO drawings (id, drawing_number, version, description) VALUES
(1, ' LOOD-16331-001', '01', 'EOS1350'),
(2, ' LOOD-14233-001', '01', 'EOS1350'),
(3, 'DWG-001', '1.0', '安全开关测试图纸'),
(4, 'DWG-002', '1.0', '电机控制测试图纸');

-- 插入测试真值表数据
INSERT INTO truth_tables (id, name, drawing_id, version, description) VALUES
(1, '默认真值表测试_16331', 1, '01', '16331-001'),
(2, '电机控制测试', 4, '1.0', '电机控制功能测试真值表');

-- 插入测试组数据
INSERT INTO test_groups (id, truth_table_id, level, description, sequence) VALUES
(1, 1, 1, '双DO测试 0H1L', 1),  -- 第一组：通道0高电平，通道1低电平
(2, 1, 1, '双DO测试 0L1H', 2);  -- 第二组：通道0低电平，通道1高电平

-- 插入测试项数据
INSERT INTO test_items (test_group_id, device_id, point_index, name, description, sequence, input_values, expected_values, timeout, mode) VALUES
-- 第一组：0H1L
(1, 1, 0, 'DO1测试', '通道0输出', 0, 100, 100, 5000, 'write'),  -- 通道0设为高电平(100)
(1, 1, 1, 'DO2测试', '通道1输出', 1, 0, 0, 5000, 'write'),    -- 通道1设为低电平(0)
(1, 1, 8, 'DI1测试', '通道8输入', 2, 0, 0, 5000, 'read'),     -- 读取通道8
(1, 1, 11, 'DI2测试', '通道11输入', 3, 0, 100, 5000, 'read'),   -- 读取通道11

-- 第二组：0L1H
(2, 1, 0, 'DO1测试', '通道0输出', 0, 0, 0, 5000, 'write'),    -- 通道0设为低电平(0)
(2, 1, 1, 'DO2测试', '通道1输出', 1, 100, 100, 5000, 'write'),  -- 通道1设为高电平(100)
(2, 1, 8, 'DI1测试', '通道8输入', 2, 0, 100, 5000, 'read'),     -- 读取通道8
(2, 1, 11, 'DI2测试', '通道11输入', 3, 0, 0, 5000, 'read');   -- 读取通道11

-- 插入D设备点位配置（6个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'D'), 0, 'DI', 'D', 'DI1', 'D数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'D'), 1, 'DI', 'D', 'DI2', 'D数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'D'), 2, 'DI', 'D', 'DI3', 'D数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'D'), 3, 'DI', 'D', 'DI4', 'D数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'D'), 4, 'DI', 'D', 'DI5', 'D数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'D'), 5, 'DI', 'D', 'DI6', 'D数字输入点6');

-- 插入B设备点位配置（6个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'B'), 0, 'DO', 'B', 'DO1', 'write', 'B数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'B'), 1, 'DO', 'B', 'DO2', 'write', 'B数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'B'), 2, 'DO', 'B', 'DO3', 'write', 'B数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'B'), 3, 'DO', 'B', 'DO4', 'write', 'B数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'B'), 4, 'DO', 'B', 'DO5', 'write', 'B数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'B'), 5, 'DO', 'B', 'DO6', 'write', 'B数字输出点6');

-- 插入A设备点位配置（6个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'A'), 0, 'DO', 'A', 'DO1', 'write', 'A数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'A'), 1, 'DO', 'A', 'DO2', 'write', 'A数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'A'), 2, 'DO', 'A', 'DO3', 'write', 'A数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'A'), 3, 'DO', 'A', 'DO4', 'write', 'A数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'A'), 4, 'DO', 'A', 'DO5', 'write', 'A数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'A'), 5, 'DO', 'A', 'DO6', 'write', 'A数字输出点6');

-- 插入C设备点位配置（6个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'C'), 0, 'DO', 'C', 'DO1', 'write', 'C数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'C'), 1, 'DO', 'C', 'DO2', 'write', 'C数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'C'), 2, 'DO', 'C', 'DO3', 'write', 'C数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'C'), 3, 'DO', 'C', 'DO4', 'write', 'C数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'C'), 4, 'DO', 'C', 'DO5', 'write', 'C数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'C'), 5, 'DO', 'C', 'DO6', 'write', 'C数字输出点6');

-- 插入F设备点位配置（6个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'F'), 0, 'DI', 'F', 'DI1', 'F数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'F'), 1, 'DI', 'F', 'DI2', 'F数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'F'), 2, 'DI', 'F', 'DI3', 'F数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'F'), 3, 'DI', 'F', 'DI4', 'F数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'F'), 4, 'DI', 'F', 'DI5', 'F数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'F'), 5, 'DI', 'F', 'DI6', 'F数字输入点6');

-- 插入W设备点位配置（6DI + 2DO + 12DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
-- 前6个DI
((SELECT id FROM device_types WHERE type_name = 'EW'), 0, 'DI', 'W', 'DI1', 'read', 'EW数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 1, 'DI', 'W', 'DI2', 'read', 'EW数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 2, 'DI', 'W', 'DI3', 'read', 'EW数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 3, 'DI', 'W', 'DI4', 'read', 'EW数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 4, 'DI', 'W', 'DI5', 'read', 'EW数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 5, 'DI', 'W', 'DI6', 'read', 'EW数字输入点6'),
-- 中间2个DO
((SELECT id FROM device_types WHERE type_name = 'EW'), 6, 'DO', 'B', 'DO1', 'write', 'EW数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 7, 'DO', 'B', 'DO2', 'write', 'EW数字输出点2'),
-- 后12个DI
((SELECT id FROM device_types WHERE type_name = 'EW'), 8, 'DI', 'W', 'DI7', 'read', 'EW数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 9, 'DI', 'W', 'DI8', 'read', 'EW数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 10, 'DI', 'W', 'DI9', 'read', 'EW数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 11, 'DI', 'W', 'DI10', 'read', 'EW数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 12, 'DI', 'W', 'DI11', 'read', 'EW数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 13, 'DI', 'W', 'DI12', 'read', 'EW数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 14, 'DI', 'W', 'DI13', 'read', 'EW数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 15, 'DI', 'W', 'DI14', 'read', 'EW数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 16, 'DI', 'W', 'DI15', 'read', 'EW数字输入点15'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 17, 'DI', 'W', 'DI16', 'read', 'EW数字输入点16'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 18, 'DI', 'W', 'DI17', 'read', 'EW数字输入点17'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 19, 'DI', 'W', 'DI18', 'read', 'EW数字输入点18');

-- PDI设备点位配置（16个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PDI'), 0, 'DI', 'PDI', 'DI0', 'read', 'PDI数字输入点0'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 1, 'DI', 'PDI', 'DI1', 'read', 'PDI数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 2, 'DI', 'PDI', 'DI2', 'read', 'PDI数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 3, 'DI', 'PDI', 'DI3', 'read', 'PDI数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 4, 'DI', 'PDI', 'DI4', 'read', 'PDI数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 5, 'DI', 'PDI', 'DI5', 'read', 'PDI数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 6, 'DI', 'PDI', 'DI6', 'read', 'PDI数字输入点6'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 7, 'DI', 'PDI', 'DI7', 'read', 'PDI数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 8, 'DI', 'PDI', 'DI8', 'read', 'PDI数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 9, 'DI', 'PDI', 'DI9', 'read', 'PDI数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 10, 'DI', 'PDI', 'DI10', 'read', 'PDI数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 11, 'DI', 'PDI', 'DI11', 'read', 'PDI数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 12, 'DI', 'PDI', 'DI12', 'read', 'PDI数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 13, 'DI', 'PDI', 'DI13', 'read', 'PDI数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 14, 'DI', 'PDI', 'DI14', 'read', 'PDI数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 15, 'DI', 'PDI', 'DI15', 'read', 'PDI数字输入点15');

-- PDO设备点位配置（16个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PDO'), 0, 'DO', 'PDO', 'DO0', 'write', 'PDO数字输出点0'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 1, 'DO', 'PDO', 'DO1', 'write', 'PDO数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 2, 'DO', 'PDO', 'DO2', 'write', 'PDO数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 3, 'DO', 'PDO', 'DO3', 'write', 'PDO数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 4, 'DO', 'PDO', 'DO4', 'write', 'PDO数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 5, 'DO', 'PDO', 'DO5', 'write', 'PDO数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 6, 'DO', 'PDO', 'DO6', 'write', 'PDO数字输出点6'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 7, 'DO', 'PDO', 'DO7', 'write', 'PDO数字输出点7'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 8, 'DO', 'PDO', 'DO8', 'write', 'PDO数字输出点8'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 9, 'DO', 'PDO', 'DO9', 'write', 'PDO数字输出点9'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 10, 'DO', 'PDO', 'DO10', 'write', 'PDO数字输出点10'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 11, 'DO', 'PDO', 'DO11', 'write', 'PDO数字输出点11'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 12, 'DO', 'PDO', 'DO12', 'write', 'PDO数字输出点12'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 13, 'DO', 'PDO', 'DO13', 'write', 'PDO数字输出点13'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 14, 'DO', 'PDO', 'DO14', 'write', 'PDO数字输出点14'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 15, 'DO', 'PDO', 'DO15', 'write', 'PDO数字输出点15');

-- PAI设备点位配置（16个AI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PAI'), 0, 'AI', 'PAI', 'AI0', 'read', 'PAI模拟输入点0'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 1, 'AI', 'PAI', 'AI1', 'read', 'PAI模拟输入点1'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 2, 'AI', 'PAI', 'AI2', 'read', 'PAI模拟输入点2'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 3, 'AI', 'PAI', 'AI3', 'read', 'PAI模拟输入点3'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 4, 'AI', 'PAI', 'AI4', 'read', 'PAI模拟输入点4'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 5, 'AI', 'PAI', 'AI5', 'read', 'PAI模拟输入点5'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 6, 'AI', 'PAI', 'AI6', 'read', 'PAI模拟输入点6'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 7, 'AI', 'PAI', 'AI7', 'read', 'PAI模拟输入点7'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 8, 'AI', 'PAI', 'AI8', 'read', 'PAI模拟输入点8'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 9, 'AI', 'PAI', 'AI9', 'read', 'PAI模拟输入点9'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 10, 'AI', 'PAI', 'AI10', 'read', 'PAI模拟输入点10'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 11, 'AI', 'PAI', 'AI11', 'read', 'PAI模拟输入点11'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 12, 'AI', 'PAI', 'AI12', 'read', 'PAI模拟输入点12'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 13, 'AI', 'PAI', 'AI13', 'read', 'PAI模拟输入点13'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 14, 'AI', 'PAI', 'AI14', 'read', 'PAI模拟输入点14'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 15, 'AI', 'PAI', 'AI15', 'read', 'PAI模拟输入点15');

-- PAO设备点位配置（16个AO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PAO'), 0, 'AO', 'PAO', 'AO0', 'write', 'PAO模拟输出点0'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 1, 'AO', 'PAO', 'AO1', 'write', 'PAO模拟输出点1'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 2, 'AO', 'PAO', 'AO2', 'write', 'PAO模拟输出点2'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 3, 'AO', 'PAO', 'AO3', 'write', 'PAO模拟输出点3'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 4, 'AO', 'PAO', 'AO4', 'write', 'PAO模拟输出点4'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 5, 'AO', 'PAO', 'AO5', 'write', 'PAO模拟输出点5'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 6, 'AO', 'PAO', 'AO6', 'write', 'PAO模拟输出点6'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 7, 'AO', 'PAO', 'AO7', 'write', 'PAO模拟输出点7'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 8, 'AO', 'PAO', 'AO8', 'write', 'PAO模拟输出点8'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 9, 'AO', 'PAO', 'AO9', 'write', 'PAO模拟输出点9'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 10, 'AO', 'PAO', 'AO10', 'write', 'PAO模拟输出点10'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 11, 'AO', 'PAO', 'AO11', 'write', 'PAO模拟输出点11'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 12, 'AO', 'PAO', 'AO12', 'write', 'PAO模拟输出点12'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 13, 'AO', 'PAO', 'AO13', 'write', 'PAO模拟输出点13'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 14, 'AO', 'PAO', 'AO14', 'write', 'PAO模拟输出点14'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 15, 'AO', 'PAO', 'AO15', 'write', 'PAO模拟输出点15');

-- HI设备点位配置（20个AI点位）- 修改使用PAI替代HI
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'HI'), 0, 'AI', 'PAI', 'AI0', 'read', 'HI模拟输入点0'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 1, 'AI', 'PAI', 'AI1', 'read', 'HI模拟输入点1'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 2, 'AI', 'PAI', 'AI2', 'read', 'HI模拟输入点2'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 3, 'AI', 'PAI', 'AI3', 'read', 'HI模拟输入点3'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 4, 'AI', 'PAI', 'AI4', 'read', 'HI模拟输入点4'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 5, 'AI', 'PAI', 'AI5', 'read', 'HI模拟输入点5'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 6, 'AI', 'PAI', 'AI6', 'read', 'HI模拟输入点6'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 7, 'AI', 'PAI', 'AI7', 'read', 'HI模拟输入点7'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 8, 'AI', 'PAI', 'AI8', 'read', 'HI模拟输入点8'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 9, 'AI', 'PAI', 'AI9', 'read', 'HI模拟输入点9'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 10, 'AI', 'PAI', 'AI10', 'read', 'HI模拟输入点10'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 11, 'AI', 'PAI', 'AI11', 'read', 'HI模拟输入点11'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 12, 'AI', 'PAI', 'AI12', 'read', 'HI模拟输入点12'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 13, 'AI', 'PAI', 'AI13', 'read', 'HI模拟输入点13'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 14, 'AI', 'PAI', 'AI14', 'read', 'HI模拟输入点14'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 15, 'AI', 'PAI', 'AI15', 'read', 'HI模拟输入点15'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 16, 'AI', 'PAI', 'AI16', 'read', 'HI模拟输入点16'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 17, 'AI', 'PAI', 'AI17', 'read', 'HI模拟输入点17'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 18, 'AI', 'PAI', 'AI18', 'read', 'HI模拟输入点18'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 19, 'AI', 'PAI', 'AI19', 'read', 'HI模拟输入点19');

-- HO设备点位配置（20个AO点位）- 修改使用PAO替代HO
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'HO'), 0, 'AO', 'PAO', 'AO0', 'write', 'HO模拟输出点0'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 1, 'AO', 'PAO', 'AO1', 'write', 'HO模拟输出点1'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 2, 'AO', 'PAO', 'AO2', 'write', 'HO模拟输出点2'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 3, 'AO', 'PAO', 'AO3', 'write', 'HO模拟输出点3'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 4, 'AO', 'PAO', 'AO4', 'write', 'HO模拟输出点4'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 5, 'AO', 'PAO', 'AO5', 'write', 'HO模拟输出点5'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 6, 'AO', 'PAO', 'AO6', 'write', 'HO模拟输出点6'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 7, 'AO', 'PAO', 'AO7', 'write', 'HO模拟输出点7'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 8, 'AO', 'PAO', 'AO8', 'write', 'HO模拟输出点8'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 9, 'AO', 'PAO', 'AO9', 'write', 'HO模拟输出点9'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 10, 'AO', 'PAO', 'AO10', 'write', 'HO模拟输出点10'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 11, 'AO', 'PAO', 'AO11', 'write', 'HO模拟输出点11'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 12, 'AO', 'PAO', 'AO12', 'write', 'HO模拟输出点12'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 13, 'AO', 'PAO', 'AO13', 'write', 'HO模拟输出点13'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 14, 'AO', 'PAO', 'AO14', 'write', 'HO模拟输出点14'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 15, 'AO', 'PAO', 'AO15', 'write', 'HO模拟输出点15'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 16, 'AO', 'PAO', 'AO16', 'write', 'HO模拟输出点16'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 17, 'AO', 'PAO', 'AO17', 'write', 'HO模拟输出点17'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 18, 'AO', 'PAO', 'AO18', 'write', 'HO模拟输出点18'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 19, 'AO', 'PAO', 'AO19', 'write', 'HO模拟输出点19');

-- EL2809设备点位（16DO）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 0, 'DO', 'PDO', 'DO1', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 1, 'DO', 'PDO', 'DO2', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 2, 'DO', 'PDO', 'DO3', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 3, 'DO', 'PDO', 'DO4', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 4, 'DO', 'PDO', 'DO5', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 5, 'DO', 'PDO', 'DO6', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 6, 'DO', 'PDO', 'DO7', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 7, 'DO', 'PDO', 'DO8', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 8, 'DO', 'PDO', 'DO9', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 9, 'DO', 'PDO', 'DO10', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 10, 'DO', 'PDO', 'DO11', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 11, 'DO', 'PDO', 'DO12', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 12, 'DO', 'PDO', 'DO13', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 13, 'DO', 'PDO', 'DO14', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 14, 'DO', 'PDO', 'DO15', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL2809'), 15, 'DO', 'PDO', 'DO16', 'write');

-- EL1809设备点位（16DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 0, 'DI', 'PDI', 'DI1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 1, 'DI', 'PDI', 'DI2', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 2, 'DI', 'PDI', 'DI3', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 3, 'DI', 'PDI', 'DI4', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 4, 'DI', 'PDI', 'DI5', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 5, 'DI', 'PDI', 'DI6', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 6, 'DI', 'PDI', 'DI7', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 7, 'DI', 'PDI', 'DI8', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 8, 'DI', 'PDI', 'DI9', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 9, 'DI', 'PDI', 'DI10', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 10, 'DI', 'PDI', 'DI11', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 11, 'DI', 'PDI', 'DI12', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 12, 'DI', 'PDI', 'DI13', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 13, 'DI', 'PDI', 'DI14', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 14, 'DI', 'PDI', 'DI15', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1809'), 15, 'DI', 'PDI', 'DI16', 'read');

-- EL3204设备点位（4AI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL3204'), 0, 'AI', 'PAI', 'AI1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3204'), 1, 'AI', 'PAI', 'AI2', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3204'), 2, 'AI', 'PAI', 'AI3', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3204'), 3, 'AI', 'PAI', 'AI4', 'read');

-- EL8601-8411机器人模块点位（3DI + 2DO + 2DI + 1AO）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 0, 'DI', 'PDI', 'DI1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 1, 'DI', 'PDI', 'DI2', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 2, 'DI', 'PDI', 'DI3', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 3, 'DO', 'PDO', 'DO4', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 4, 'DO', 'PDO', 'DO5', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 5, 'DI', 'PDI', 'DI9', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 6, 'DI', 'PDI', 'DI10', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL8601-8411'), 7, 'AO', 'PAO', 'AO14', 'write');

-- EL1859设备点位（8DI + 8DO）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
-- 前8个DI
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 0, 'DI', 'PDI', 'DI1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 1, 'DI', 'PDI', 'DI2', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 2, 'DI', 'PDI', 'DI3', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 3, 'DI', 'PDI', 'DI4', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 4, 'DI', 'PDI', 'DI5', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 5, 'DI', 'PDI', 'DI6', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 6, 'DI', 'PDI', 'DI7', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 7, 'DI', 'PDI', 'DI8', 'read'),
-- 后8个DO
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 8, 'DO', 'PDO', 'DO1', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 9, 'DO', 'PDO', 'DO2', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 10, 'DO', 'PDO', 'DO3', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 11, 'DO', 'PDO', 'DO4', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 12, 'DO', 'PDO', 'DO5', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 13, 'DO', 'PDO', 'DO6', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 14, 'DO', 'PDO', 'DO7', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL1859'), 15, 'DO', 'PDO', 'DO8', 'write');

-- EL3064设备点位（4AI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL3064'), 0, 'AI', 'PAI', 'AI1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3064'), 1, 'AI', 'PAI', 'AI2', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3064'), 2, 'AI', 'PAI', 'AI3', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3064'), 3, 'AI', 'PAI', 'AI4', 'read');

-- EL4132设备点位（2AO）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL4132'), 0, 'AO', 'PAO', 'AO1', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL4132'), 1, 'AO', 'PAO', 'AO2', 'write');

-- EL4004设备点位（4AO）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL4004'), 0, 'AO', 'PAO', 'AO1', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL4004'), 1, 'AO', 'PAO', 'AO2', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL4004'), 2, 'AO', 'PAO', 'AO3', 'write'),
((SELECT id FROM device_types WHERE type_name = 'EL4004'), 3, 'AO', 'PAO', 'AO4', 'write');

-- EL3162设备点位（2AI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL3162'), 0, 'AI', 'PAI', 'AI1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3162'), 1, 'AI', 'PAI', 'AI2', 'read');

-- EL1004设备点位（4DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL1004'), 0, 'DI', 'PDI', 'DI1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1004'), 1, 'DI', 'PDI', 'DI2', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1004'), 2, 'DI', 'PDI', 'DI3', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL1004'), 3, 'DI', 'PDI', 'DI4', 'read');

-- EL3314设备点位（4AI - TC温度传感器）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL3314'), 0, 'AI', 'PAI', 'TC1', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3314'), 1, 'AI', 'PAI', 'TC2', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3314'), 2, 'AI', 'PAI', 'TC3', 'read'),
((SELECT id FROM device_types WHERE type_name = 'EL3314'), 3, 'AI', 'PAI', 'TC4', 'read');

-- EL3403设备点位（8PIN 3U,N 3I,N）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 0, 'AI', 'PAI', 'U1', 'read', '电压测量点1'),
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 1, 'AI', 'PAI', 'U2', 'read', '电压测量点2'),
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 2, 'AI', 'PAI', 'U3', 'read', '电压测量点3'),
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 3, 'AI', 'PAI', 'N1', 'read', '电压中性点'),
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 4, 'AI', 'PAI', 'I1', 'read', '电流测量点1'),
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 5, 'AI', 'PAI', 'I2', 'read', '电流测量点2'),
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 6, 'AI', 'PAI', 'I3', 'read', '电流测量点3'),
((SELECT id FROM device_types WHERE type_name = 'EL3403'), 7, 'AI', 'PAI', 'N2', 'read', '电流中性点');

-- EL5151设备点位（8PIN 编码器接口）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 0, 'DI', 'PDI', 'CLK', 'read', '时钟信号(引脚1)'),
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 1, 'DI', 'PDI', 'DATA', 'read', '数据信号(引脚4)'),
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 2, 'DI', 'PDI', 'LATCH', 'read', '锁存信号(引脚5)'),
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 3, 'DO', 'PDO', 'EN', 'write', '使能信号(引脚8)'),
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 4, 'AI', 'PAI', 'A', 'read', 'A相编码器信号'),
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 5, 'AI', 'PAI', 'B', 'read', 'B相编码器信号'),
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 6, 'AI', 'PAI', 'Z', 'read', 'Z相编码器信号'),
((SELECT id FROM device_types WHERE type_name = 'EL5151'), 7, 'DO', 'PDO', 'GATE', 'write', '门控信号');

-- EK1101设备点位（6点 电源和通信接口）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'EK1101'), 0, 'DI', 'PDI', 'P24V', 'read', '24V电源引脚(引脚2)'),
((SELECT id FROM device_types WHERE type_name = 'EK1101'), 1, 'DI', 'PDI', 'P5V', 'read', '5V电源引脚(引脚6)'),
((SELECT id FROM device_types WHERE type_name = 'EK1101'), 2, 'DI', 'PDI', 'GND1', 'read', '接地1(引脚3)'),
((SELECT id FROM device_types WHERE type_name = 'EK1101'), 3, 'DI', 'PDI', 'GND2', 'read', '接地2(引脚5)'),
((SELECT id FROM device_types WHERE type_name = 'EK1101'), 4, 'DI', 'PDI', 'GND3', 'read', '接地3(引脚7)'),
((SELECT id FROM device_types WHERE type_name = 'EK1101'), 5, 'DI', 'PDI', 'PE', 'read', '保护地(引脚4,8)');

-- EK1005设备点位（3点 电源接口）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'EK1005'), 0, 'DI', 'PDI', 'P31', 'read', '正极电源(引脚N3-1)'),
((SELECT id FROM device_types WHERE type_name = 'EK1005'), 1, 'DI', 'PDI', 'N2', 'read', '负极电源(引脚2)'),
((SELECT id FROM device_types WHERE type_name = 'EK1005'), 2, 'DI', 'PDI', 'PE', 'read', '保护地(引脚3)');

-- EK1122设备点位（4点 网络接口）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'EK1122'), 0, 'DI', 'PDI', 'TX1', 'read', '发送数据1'),
((SELECT id FROM device_types WHERE type_name = 'EK1122'), 1, 'DI', 'PDI', 'RX1', 'read', '接收数据1'),
((SELECT id FROM device_types WHERE type_name = 'EK1122'), 2, 'DI', 'PDI', 'TX2', 'read', '发送数据2'),
((SELECT id FROM device_types WHERE type_name = 'EK1122'), 3, 'DI', 'PDI', 'RX2', 'read', '接收数据2');

-- FLK-D25设备点位（16点 D-sub接口）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
-- X1:1 到X23
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:1", 'DI', 'PDI', 'DI1', 'read', 'X1:41数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:2", 'DI', 'PDI', 'DI2', 'read', 'X1:2数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:3", 'DI', 'PDI', 'DI3', 'read', 'X1:3数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:4", 'DI', 'PDI', 'DI4', 'read', 'X1:4数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:5", 'DI', 'PDI', 'DI5', 'read', 'X1:5数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:6", 'DI', 'PDI', 'DI6', 'read', 'X1:6数字输入点6'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:7", 'DI', 'PDI', 'DI7', 'read', 'X1:7数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:8", 'DI', 'PDI', 'DI8', 'read', 'X1:8数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:9", 'DI', 'PDI', 'DI9', 'read', 'X1:9数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:10", 'DI', 'PDI', 'DI10', 'read', 'X1:10数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:11", 'DI', 'PDI', 'DI11', 'read', 'X1:11数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:12", 'DI', 'PDI', 'DI12', 'read', 'X1:12数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:13", 'DI', 'PDI', 'DI13', 'read', 'X1:13数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:14", 'DI', 'PDI', 'DI14', 'read', 'X1:14数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:15", 'DI', 'PDI', 'DI15', 'read', 'X1:15数字输入点15'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:16", 'DI', 'PDI', 'DI16', 'read', 'X1:16数字输入点16'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:17", 'DI', 'PDI', 'DI17', 'read', 'X1:17数字输入点17'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:18", 'DI', 'PDI', 'DI18', 'read', 'X1:18数字输入点18'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:19", 'DI', 'PDI', 'DI19', 'read', 'X1:19数字输入点19'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:20", 'DI', 'PDI', 'DI20', 'read', 'X1:20数字输入点20'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:21", 'DI', 'PDI', 'DI21', 'read', 'X1:21数字输入点21'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:22", 'DI', 'PDI', 'DI22', 'read', 'X1:22数字输入点22'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X1:23", 'DI', 'PDI', 'DI23', 'read', 'X1:23数字输入点23'),

((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:1", 'DI', 'PDI', 'DI1', 'read', 'X2:1数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:2", 'DI', 'PDI', 'DI2', 'read', 'X2:2数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:3", 'DI', 'PDI', 'DI3', 'read', 'X2:3数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:4", 'DI', 'PDI', 'DI4', 'read', 'X2:4数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:5", 'DI', 'PDI', 'DI5', 'read', 'X2:5数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:6", 'DI', 'PDI', 'DI6', 'read', 'X2:6数字输入点6'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:7", 'DI', 'PDI', 'DI7', 'read', 'X2:7数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:8", 'DI', 'PDI', 'DI8', 'read', 'X2:8数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:9", 'DI', 'PDI', 'DI9', 'read', 'X2:9数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:10", 'DI', 'PDI', 'DI10', 'read', 'X2:10数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:11", 'DI', 'PDI', 'DI11', 'read', 'X2:11数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:12", 'DI', 'PDI', 'DI12', 'read', 'X2:12数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:13", 'DI', 'PDI', 'DI13', 'read', 'X2:13数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:14", 'DI', 'PDI', 'DI14', 'read', 'X2:14数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:15", 'DI', 'PDI', 'DI15', 'read', 'X2:15数字输入点15'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:16", 'DI', 'PDI', 'DI16', 'read', 'X2:16数字输入点16'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:17", 'DI', 'PDI', 'DI17', 'read', 'X2:17数字输入点17'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:18", 'DI', 'PDI', 'DI18', 'read', 'X2:18数字输入点18'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:19", 'DI', 'PDI', 'DI19', 'read', 'X2:19数字输入点19'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:20", 'DI', 'PDI', 'DI20', 'read', 'X2:20数字输入点20'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:21", 'DI', 'PDI', 'DI21', 'read', 'X2:21数字输入点21'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:22", 'DI', 'PDI', 'DI22', 'read', 'X2:22数字输入点22'),
((SELECT id FROM device_types WHERE type_name = 'FLK-D25'), "X2:23", 'DI', 'PDI', 'DI23', 'read', 'X2:23数字输入点23');

-- EL9100设备点位（3点 电源馈电模块）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL9100'), 0, 'DI', 'PDI', 'POWER', 'read', '电源状态'),
((SELECT id FROM device_types WHERE type_name = 'EL9100'), 1, 'DI', 'PDI', 'DIAG', 'read', '诊断状态'),
((SELECT id FROM device_types WHERE type_name = 'EL9100'), 2, 'DI', 'PDI', 'FUSE', 'read', '保险丝状态');

-- EL6731设备点位（2点 PROFIBUS主站模块）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'EL6731'), 0, 'DI', 'PDI', 'STATUS', 'read', 'PROFIBUS通信状态'),
((SELECT id FROM device_types WHERE type_name = 'EL6731'), 1, 'DI', 'PDI', 'ERROR', 'read', '错误状态');

-- GV204-X1设备点位（4点 屏蔽和电源接口）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'GV204-X1'), 0, 'DI', 'PDI', 'SHIELD', 'read', '屏蔽接地'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X1'), 1, 'DI', 'PDI', 'GND', 'read', '信号地'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X1'), 2, 'DI', 'PDI', 'VCC', 'read', '供电电源'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X1'), 3, 'DI', 'PDI', 'PE', 'read', '保护地');

-- GV204-X2设备点位（8点 编码器输入接口）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 0, 'AI', 'PAI', 'ENC1A', 'read', '编码器1 A相'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 1, 'AI', 'PAI', 'ENC1B', 'read', '编码器1 B相'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 2, 'AI', 'PAI', 'ENC1Z', 'read', '编码器1 Z相'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 3, 'AI', 'PAI', 'ENC1COM', 'read', '编码器1 公共端'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 4, 'AI', 'PAI', 'ENC2A', 'read', '编码器2 A相'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 5, 'AI', 'PAI', 'ENC2B', 'read', '编码器2 B相'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 6, 'AI', 'PAI', 'ENC2Z', 'read', '编码器2 Z相'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X2'), 7, 'AI', 'PAI', 'ENC2COM', 'read', '编码器2 公共端');

-- GV204-X3设备点位（4点 输出接口1）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'GV204-X3'), 0, 'AO', 'PAO', 'OUT1', 'write', '模拟输出1'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X3'), 1, 'AO', 'PAO', 'OUT2', 'write', '模拟输出2'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X3'), 2, 'AO', 'PAO', 'OUT3', 'write', '模拟输出3'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X3'), 3, 'AO', 'PAO', 'OUT4', 'write', '模拟输出4');

-- GV204-X4设备点位（8点 输出接口2）
INSERT INTO device_type_points (device_type_id, point_index, point_type, sim_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 0, 'AO', 'PAO', 'OUT5', 'write', '模拟输出5'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 1, 'AO', 'PAO', 'OUT6', 'write', '模拟输出6'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 2, 'AO', 'PAO', 'OUT7', 'write', '模拟输出7'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 3, 'AO', 'PAO', 'OUT8', 'write', '模拟输出8'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 4, 'AO', 'PAO', 'OUT9', 'write', '模拟输出9'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 5, 'AO', 'PAO', 'OUT10', 'write', '模拟输出10'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 6, 'AO', 'PAO', 'OUT11', 'write', '模拟输出11'),
((SELECT id FROM device_types WHERE type_name = 'GV204-X4'), 7, 'AO', 'PAO', 'OUT12', 'write', '模拟输出12');

-- 开启外键检查
-- 设置当前数据库
USE lbfat;

-- 清空并重新创建simpoint表
DROP TABLE IF EXISTS simpoint;
CREATE TABLE IF NOT EXISTS simpoint (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ftid VARCHAR(50) NOT NULL,
  target_ftid VARCHAR(50),
  project_name VARCHAR(50) NOT NULL,
  moduler VARCHAR(50) NOT NULL,
  device_name VARCHAR(50) NOT NULL,
  point_type VARCHAR(10) NOT NULL,
  point_index VARCHAR(60) NOT NULL,
  sim_type VARCHAR(10) NOT NULL,
  mode VARCHAR(10) NOT NULL,
  description VARCHAR(255),
  hartingbox VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 从devices和device_type_points表中插入数据到simpoint表
INSERT INTO simpoint (
  ftid,
  target_ftid,
  project_name,
  moduler,
  device_name,
  point_type,
  point_index,
  sim_type,
  mode,
  description,
  hartingbox
)
SELECT 
  CONCAT("=",d.project_name,'+',d.Location,'-', d.module_type, d.serial_number, ':', dtp.point_index) as ftid,  
  NULL as target_ftid,
  d.project_name,
  CONCAT(d.module_type,d.serial_number) AS moduler,
  d.serial_number AS device_name,
  dtp.point_type,
  dtp.point_index,
  dtp.sim_type,
  dtp.mode,
  dtp.description,
  NULL as hartingbox
FROM devices d
JOIN device_type_points dtp ON d.type_id = dtp.device_type_id
ORDER BY d.project_name, d.module_type, d.serial_number, dtp.point_index;




SET FOREIGN_KEY_CHECKS = 1;
-- 插入数据到simpoint表
