-- 设置字符集和关闭外键检查
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建并使用数据库
CREATE DATABASE IF NOT EXISTS lbfat;
USE lbfat;

-- =====================================================
-- 表结构定义
-- =====================================================

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
    status ENUM('online', 'offline') DEFAULT 'offline' COMMENT '设备状态',
    rssi INT DEFAULT 0 COMMENT '信号强度',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_device (project_name, module_type, serial_number),
    INDEX idx_project_name (project_name),
    INDEX idx_status (status),
    CONSTRAINT fk_project_name FOREIGN KEY (project_name) 
        REFERENCES project_subscriptions(project_name) 
        ON DELETE CASCADE 
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
    point_index INT NOT NULL,
    point_type ENUM('DI','DO','AI','AO') NOT NULL,
    point_name VARCHAR(50) NOT NULL,
    description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_type_id) REFERENCES device_types(id) ON DELETE CASCADE,
    UNIQUE KEY unique_point (device_type_id, point_index)
) COMMENT '设备点位配置表';

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
  sequence INT NOT NULL DEFAULT 0 COMMENT '显示顺序',
  input_values FLOAT NOT NULL COMMENT '输入值',
  expected_values FLOAT NOT NULL COMMENT '预期结果',
  timeout INT NOT NULL DEFAULT 5000 COMMENT '超时时间(毫秒)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FOREIGN KEY (test_group_id) REFERENCES test_groups(id) ON DELETE CASCADE,
  FOREIGN KEY (device_id) REFERENCES devices(id),
  INDEX idx_device (device_id),
  INDEX idx_point_index (point_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='测试项表';

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
INSERT INTO devices (id, project_name, module_type, serial_number, status, rssi) VALUES
(1, 'lb_test', 'EDB', '4', 'offline', 0),
(2, 'lb_test', 'EDB', '5', 'offline', 0)
ON DUPLICATE KEY UPDATE status = 'offline';

-- 插入MQTT订阅
INSERT INTO mqtt_subscriptions (topic, qos, is_active) VALUES
('lb_test/+/+/status', 1, TRUE);

-- 插入设备类型
INSERT INTO device_types (id, type_name, point_count, description) VALUES
(1, 'EDB', 20, 'EDB设备：20个点位配置（7DI + 3DO + 7DI + 3DI）'),
(2, 'EBD', 20, 'EBD设备：20个点位配置（7DO + 3DI + 10DO）');

-- 插入EDB设备点位配置
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
-- EDB设备点位（device_type_id = 1）
-- 前7个DI
(1, 1, 'DI', 'DI1', 'EDB数字输入点1 - 前段'),
(1, 2, 'DI', 'DI2', 'EDB数字输入点2 - 前段'),
(1, 3, 'DI', 'DI3', 'EDB数字输入点3 - 前段'),
(1, 4, 'DI', 'DI4', 'EDB数字输入点4 - 前段'),
(1, 5, 'DI', 'DI5', 'EDB数字输入点5 - 前段'),
(1, 6, 'DI', 'DI6', 'EDB数字输入点6 - 前段'),
(1, 7, 'DI', 'DI7', 'EDB数字输入点7 - 前段'),
-- 3个DO
(1, 8, 'DO', 'DO1', 'EDB数字输出点1'),
(1, 9, 'DO', 'DO2', 'EDB数字输出点2'),
(1, 10, 'DO', 'DO3', 'EDB数字输出点3'),
-- 后7个DI
(1, 11, 'DI', 'DI8', 'EDB数字输入点8 - 中段'),
(1, 12, 'DI', 'DI9', 'EDB数字输入点9 - 中段'),
(1, 13, 'DI', 'DI10', 'EDB数字输入点10 - 中段'),
(1, 14, 'DI', 'DI11', 'EDB数字输入点11 - 中段'),
(1, 15, 'DI', 'DI12', 'EDB数字输入点12 - 中段'),
(1, 16, 'DI', 'DI13', 'EDB数字输入点13 - 中段'),
(1, 17, 'DI', 'DI14', 'EDB数字输入点14 - 中段'),
-- 剩余3个点位
(1, 18, 'DI', 'DI15', 'EDB数字输入点15 - 后段'),
(1, 19, 'DI', 'DI16', 'EDB数字输入点16 - 后段'),
(1, 20, 'DI', 'DI17', 'EDB数字输入点17 - 后段'),

-- EBD设备点位（device_type_id = 2）
-- 前7个DI
(2, 1, 'DI', 'DI1', 'EBD数字输入点1 - 前段'),
(2, 2, 'DI', 'DI2', 'EBD数字输入点2 - 前段'),
(2, 3, 'DI', 'DI3', 'EBD数字输入点3 - 前段'),
(2, 4, 'DI', 'DI4', 'EBD数字输入点4 - 前段'),
(2, 5, 'DI', 'DI5', 'EBD数字输入点5 - 前段'),
(2, 6, 'DI', 'DI6', 'EBD数字输入点6 - 前段'),
(2, 7, 'DI', 'DI7', 'EBD数字输入点7 - 前段'),
-- 3个DO
(2, 8, 'DO', 'DO1', 'EBD数字输出点1'),
(2, 9, 'DO', 'DO2', 'EBD数字输出点2'),
(2, 10, 'DO', 'DO3', 'EBD数字输出点3'),
-- 后7个DI
(2, 11, 'DI', 'DI8', 'EBD数字输入点8 - 中段'),
(2, 12, 'DI', 'DI9', 'EBD数字输入点9 - 中段'),
(2, 13, 'DI', 'DI10', 'EBD数字输入点10 - 中段'),
(2, 14, 'DI', 'DI11', 'EBD数字输入点11 - 中段'),
(2, 15, 'DI', 'DI12', 'EBD数字输入点12 - 中段'),
(2, 16, 'DI', 'DI13', 'EBD数字输入点13 - 中段'),
(2, 17, 'DI', 'DI14', 'EBD数字输入点14 - 中段'),
-- 剩余3个点位
(2, 18, 'DI', 'DI15', 'EBD数字输入点15 - 后段'),
(2, 19, 'DI', 'DI16', 'EBD数字输入点16 - 后段'),
(2, 20, 'DI', 'DI17', 'EBD数字输入点17 - 后段');

-- 插入图纸数据
INSERT INTO drawings (id, drawing_number, version, description) VALUES
(1, ' LOOD-16331-001', '3018598347', 'EOS1350'),
(2, ' LOOD-14233-001', '3018571155', 'EOS1350'),
(3, 'DWG-001', '1.0', '安全开关测试图纸'),
(4, 'DWG-002', '1.0', '电机控制测试图纸');

-- 插入测试真值表数据
INSERT INTO truth_tables (id, name, drawing_id, version, description) VALUES
(1, '默认真值表测试_16331', 1, '1.0', '16331-001'),
(2, '电机控制测试', 4, '1.0', '电机控制功能测试真值表');

-- 插入测试组数据
INSERT INTO test_groups (id, truth_table_id, level, description, sequence) VALUES
(1, 1, 1, '安全开关检查组', 0),
(2, 1, 0, '安全联锁测试组', 1),
(3, 2, 1, '电机启动测试组', 0),
(4, 2, 0, '电机运行测试组', 1);

-- 插入测试项数据
INSERT INTO test_items (test_group_id, device_id, point_index, name, description, sequence, input_values, expected_values, timeout) VALUES
(1, 1, 1, '安全开关合闸测试', '检查安全开关合闸状态下的', 0, 0, 1, 5000),
(1, 1, 1, '安全开关打开测试', '检查安全开关打开状态下的', 1, 1, 0, 5000),
(2, 2, 2, '安全锁锁闭测试', '验证安全锁锁闭功能是否正常', 0, 1, 0, 5000),
(3, 3, 1, '电机启动测试', '验证电机启动控制功能', 0, 1, 1, 5000),
(3, 2, 2, '电机运行测试', '验证电机运行状态检测', 1, 1, 0, 5000),
(4, 3, 1, '电机停止测试', '验证电机停止控制功能', 0, 0, 1, 5000);

-- 开启外键检查
SET FOREIGN_KEY_CHECKS = 1;