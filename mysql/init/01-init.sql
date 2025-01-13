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
    point_index INT NOT NULL,
    point_type ENUM('DI','DO','AI','AO') NOT NULL,
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
(1, 'lb_test', 'EBD', '1', 'offline', 0),
(2, 'lb_test', 'EDB', '4', 'offline', 0),
(3, 'lb_test', 'EDB', '5', 'offline', 0)
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
('W', 6, '普通模块 W：6点（6DI）');

-- 插入EDB设备点位配置
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
-- EDB设备点位（device_type_id = 1）
-- 前7个DI
(1, 0, 'DI', 'DI1', 'read', 'EDB数字输入点1 - 前段'),
(1, 1, 'DI', 'DI2', 'read', 'EDB数字输入点2 - 前段'),
(1, 2, 'DI', 'DI3', 'read', 'EDB数字输入点3 - 前段'),
(1, 3, 'DI', 'DI4', 'read', 'EDB数字输入点4 - 前段'),
(1, 4, 'DI', 'DI5', 'read', 'EDB数字输入点5 - 前段'),
(1, 5, 'DI', 'DI6', 'read', 'EDB数字输入点6 - 前段'),
(1, 6, 'DI', 'DI7', 'read', 'EDB数字输入点7 - 前段'),
-- 3个DO
(1, 7, 'DO', 'DO1', 'write', 'EDB数字输出点1'),
(1, 8, 'DO', 'DO2', 'write', 'EDB数字输出点2'),
(1, 9, 'DO', 'DO3', 'write', 'EDB数字输出点3'),
-- 后7个DI
(1, 10, 'DI', 'DI8', 'read', 'EDB数字输入点8 - 中段'),
(1, 11, 'DI', 'DI9', 'read', 'EDB数字输入点9 - 中段'),
(1, 12, 'DI', 'DI10', 'read', 'EDB数字输入点10 - 中段'),
(1, 13, 'DI', 'DI11', 'read', 'EDB数字输入点11 - 中段'),
(1, 14, 'DI', 'DI12', 'read', 'EDB数字输入点12 - 中段'),
(1, 15, 'DI', 'DI13', 'read', 'EDB数字输入点13 - 中段'),
(1, 16, 'DI', 'DI14', 'read', 'EDB数字输入点14 - 中段'),
-- 剩余3个点位
(1, 17, 'DI', 'DI15', 'read', 'EDB数字输入点15 - 后段'),
(1, 18, 'DI', 'DI16', 'read', 'EDB数字输入点16 - 后段'),
(1, 19, 'DI', 'DI17', 'read', 'EDB数字输入点17 - 后段');

-- EBD设备点位（device_type_id = 2）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
-- 前8个DO
(2, 0, 'DO', 'DO1', 'write', 'EBD数字输出点1'),
(2, 1, 'DO', 'DO2', 'write', 'EBD数字输出点2'),
(2, 2, 'DO', 'DO3', 'write', 'EBD数字输出点3'),
(2, 3, 'DO', 'DO4', 'write', 'EBD数字输出点4'),
(2, 4, 'DO', 'DO5', 'write', 'EBD数字输出点5'),
(2, 5, 'DO', 'DO6', 'write', 'EBD数字输出点6'),
(2, 6, 'DO', 'DO7', 'write', 'EBD数字输出点7'),
(2, 7, 'DO', 'DO8', 'write', 'EBD数字输出点8'),
-- 中间4个DI
(2, 8, 'DI', 'DI1', 'read', 'EBD数字输入点1'),
(2, 9, 'DI', 'DI2', 'read', 'EBD数字输入点2'),
(2, 10, 'DI', 'DI3', 'read', 'EBD数字输入点3'),
(2, 11, 'DI', 'DI4', 'read', 'EBD数字输入点4'),
-- 后8个DO
(2, 12, 'DO', 'DO9', 'write', 'EBD数字输出点9'),
(2, 13, 'DO', 'DO10', 'write', 'EBD数字输出点10'),
(2, 14, 'DO', 'DO11', 'write', 'EBD数字输出点11'),
(2, 15, 'DO', 'DO12', 'write', 'EBD数字输出点12'),
(2, 16, 'DO', 'DO13', 'write', 'EBD数字输出点13'),
(2, 17, 'DO', 'DO14', 'write', 'EBD数字输出点14'),
(2, 18, 'DO', 'DO15', 'write', 'EBD数字输出点15'),
(2, 19, 'DO', 'DO16', 'write', 'EBD数字输出点16');

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
INSERT INTO test_items (test_group_id, device_id, point_index, name, description, sequence, input_values, expected_values, timeout) VALUES
-- 第一组：0H1L
(1, 1, 0, 'DO1测试', '通道0输出', 0, 100, 100, 5000),  -- 通道0设为高电平(100)
(1, 1, 1, 'DO2测试', '通道1输出', 1, 0, 100, 5000),    -- 通道1设为低电平(0)
(1, 1, 8, 'DI1测试', '通道8输入', 2, 0, 100, 5000),    -- 读取通道8
(1, 1, 11, 'DI2测试', '通道11输入', 3, 0, 100, 5000),  -- 读取通道11

-- 第二组：0L1H
(2, 1, 0, 'DO1测试', '通道0输出', 0, 0, 100, 5000),    -- 通道0设为低电平(0)
(2, 1, 1, 'DO2测试', '通道1输出', 1, 100, 100, 5000),  -- 通道1设为高电平(100)
(2, 1, 8, 'DI1测试', '通道8输入', 2, 0, 100, 5000),    -- 读取通道8
(2, 1, 11, 'DI2测试', '通道11输入', 3, 0, 100, 5000);  -- 读取通道11

-- 插入D设备点位配置（6个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'D'), 0, 'DI', 'DI1', 'D数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'D'), 1, 'DI', 'DI2', 'D数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'D'), 2, 'DI', 'DI3', 'D数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'D'), 3, 'DI', 'DI4', 'D数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'D'), 4, 'DI', 'DI5', 'D数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'D'), 5, 'DI', 'DI6', 'D数字输入点6');

-- 插入B设备点位配置（6个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'B'), 0, 'DO', 'DO1', 'write', 'B数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'B'), 1, 'DO', 'DO2', 'write', 'B数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'B'), 2, 'DO', 'DO3', 'write', 'B数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'B'), 3, 'DO', 'DO4', 'write', 'B数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'B'), 4, 'DO', 'DO5', 'write', 'B数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'B'), 5, 'DO', 'DO6', 'write', 'B数字输出点6');

-- 插入A设备点位配置（6个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'A'), 0, 'DO', 'DO1', 'write', 'A数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'A'), 1, 'DO', 'DO2', 'write', 'A数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'A'), 2, 'DO', 'DO3', 'write', 'A数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'A'), 3, 'DO', 'DO4', 'write', 'A数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'A'), 4, 'DO', 'DO5', 'write', 'A数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'A'), 5, 'DO', 'DO6', 'write', 'A数字输出点6');

-- 插入C设备点位配置（6个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'C'), 0, 'DO', 'DO1', 'write', 'C数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'C'), 1, 'DO', 'DO2', 'write', 'C数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'C'), 2, 'DO', 'DO3', 'write', 'C数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'C'), 3, 'DO', 'DO4', 'write', 'C数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'C'), 4, 'DO', 'DO5', 'write', 'C数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'C'), 5, 'DO', 'DO6', 'write', 'C数字输出点6');

-- 插入F设备点位配置（6个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'F'), 0, 'DI', 'DI1', 'F数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'F'), 1, 'DI', 'DI2', 'F数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'F'), 2, 'DI', 'DI3', 'F数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'F'), 3, 'DI', 'DI4', 'F数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'F'), 4, 'DI', 'DI5', 'F数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'F'), 5, 'DI', 'DI6', 'F数字输入点6');

-- 插入W设备点位配置（6个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'W'), 0, 'DI', 'DI1', 'W数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'W'), 1, 'DI', 'DI2', 'W数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'W'), 2, 'DI', 'DI3', 'W数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'W'), 3, 'DI', 'DI4', 'W数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'W'), 4, 'DI', 'DI5', 'W数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'W'), 5, 'DI', 'DI6', 'W数字输入点6');

-- EA设备点位配置（14DO + 6DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
-- 前14个DO
((SELECT id FROM device_types WHERE type_name = 'EA'), 0, 'DO', 'DO1', 'write', 'EA数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 1, 'DO', 'DO2', 'write', 'EA数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 2, 'DO', 'DO3', 'write', 'EA数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 3, 'DO', 'DO4', 'write', 'EA数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 4, 'DO', 'DO5', 'write', 'EA数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 5, 'DO', 'DO6', 'write', 'EA数字输出点6'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 6, 'DO', 'DO7', 'write', 'EA数字输出点7'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 7, 'DO', 'DO8', 'write', 'EA数字输出点8'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 8, 'DO', 'DO9', 'write', 'EA数字输出点9'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 9, 'DO', 'DO10', 'write', 'EA数字输出点10'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 10, 'DO', 'DO11', 'write', 'EA数字输出点11'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 11, 'DO', 'DO12', 'write', 'EA数字输出点12'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 12, 'DO', 'DO13', 'write', 'EA数字输出点13'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 13, 'DO', 'DO14', 'write', 'EA数字输出点14'),
-- 后6个DI
((SELECT id FROM device_types WHERE type_name = 'EA'), 14, 'DI', 'DI1', 'read', 'EA数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 15, 'DI', 'DI2', 'read', 'EA数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 16, 'DI', 'DI3', 'read', 'EA数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 17, 'DI', 'DI4', 'read', 'EA数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 18, 'DI', 'DI5', 'read', 'EA数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 19, 'DI', 'DI6', 'read', 'EA数字输入点6');

-- EC设备点位配置（14DO + 6DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
-- 前14个DO
((SELECT id FROM device_types WHERE type_name = 'EC'), 0, 'DO', 'DO1', 'write', 'EC数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 1, 'DO', 'DO2', 'write', 'EC数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 2, 'DO', 'DO3', 'write', 'EC数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 3, 'DO', 'DO4', 'write', 'EC数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 4, 'DO', 'DO5', 'write', 'EC数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 5, 'DO', 'DO6', 'write', 'EC数字输出点6'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 6, 'DO', 'DO7', 'write', 'EC数字输出点7'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 7, 'DO', 'DO8', 'write', 'EC数字输出点8'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 8, 'DO', 'DO9', 'write', 'EC数字输出点9'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 9, 'DO', 'DO10', 'write', 'EC数字输出点10'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 10, 'DO', 'DO11', 'write', 'EC数字输出点11'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 11, 'DO', 'DO12', 'write', 'EC数字输出点12'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 12, 'DO', 'DO13', 'write', 'EC数字输出点13'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 13, 'DO', 'DO14', 'write', 'EC数字输出点14'),
-- 后6个DI
((SELECT id FROM device_types WHERE type_name = 'EC'), 14, 'DI', 'DI1', 'read', 'EC数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 15, 'DI', 'DI2', 'read', 'EC数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 16, 'DI', 'DI3', 'read', 'EC数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 17, 'DI', 'DI4', 'read', 'EC数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 18, 'DI', 'DI5', 'read', 'EC数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 19, 'DI', 'DI6', 'read', 'EC数字输入点6');

-- EF设备点位配置（20DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
-- 20个DI
((SELECT id FROM device_types WHERE type_name = 'EF'), 0, 'DI', 'DI1', 'EF数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 1, 'DI', 'DI2', 'EF数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 2, 'DI', 'DI3', 'EF数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 3, 'DI', 'DI4', 'EF数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 4, 'DI', 'DI5', 'EF数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 5, 'DI', 'DI6', 'EF数字输入点6'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 6, 'DI', 'DI7', 'EF数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 7, 'DI', 'DI8', 'EF数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 8, 'DI', 'DI9', 'EF数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 9, 'DI', 'DI10', 'EF数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 10, 'DI', 'DI11', 'EF数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 11, 'DI', 'DI12', 'EF数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 12, 'DI', 'DI13', 'EF数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 13, 'DI', 'DI14', 'EF数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 14, 'DI', 'DI15', 'EF数字输入点15'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 15, 'DI', 'DI16', 'EF数字输入点16'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 16, 'DI', 'DI17', 'EF数字输入点17'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 17, 'DI', 'DI18', 'EF数字输入点18'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 18, 'DI', 'DI19', 'EF数字输入点19'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 19, 'DI', 'DI20', 'EF数字输入点20');

-- EW设备点位配置（6DI + 2DO + 12DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
-- 前6个DI
((SELECT id FROM device_types WHERE type_name = 'EW'), 0, 'DI', 'DI1', 'read', 'EW数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 1, 'DI', 'DI2', 'read', 'EW数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 2, 'DI', 'DI3', 'read', 'EW数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 3, 'DI', 'DI4', 'read', 'EW数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 4, 'DI', 'DI5', 'read', 'EW数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 5, 'DI', 'DI6', 'read', 'EW数字输入点6'),
-- 中间2个DO
((SELECT id FROM device_types WHERE type_name = 'EW'), 6, 'DO', 'DO1', 'write', 'EW数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 7, 'DO', 'DO2', 'write', 'EW数字输出点2'),
-- 后12个DI
((SELECT id FROM device_types WHERE type_name = 'EW'), 8, 'DI', 'DI7', 'read', 'EW数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 9, 'DI', 'DI8', 'read', 'EW数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 10, 'DI', 'DI9', 'read', 'EW数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 11, 'DI', 'DI10', 'read', 'EW数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 12, 'DI', 'DI11', 'read', 'EW数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 13, 'DI', 'DI12', 'read', 'EW数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 14, 'DI', 'DI13', 'read', 'EW数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 15, 'DI', 'DI14', 'read', 'EW数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 16, 'DI', 'DI15', 'read', 'EW数字输入点15'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 17, 'DI', 'DI16', 'read', 'EW数字输入点16'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 18, 'DI', 'DI17', 'read', 'EW数字输入点17'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 19, 'DI', 'DI18', 'read', 'EW数字输入点18');

-- PDI设备点位配置（16个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PDI'), 0, 'DI', 'DI0', 'PDI数字输入点0'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 1, 'DI', 'DI1', 'PDI数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 2, 'DI', 'DI2', 'PDI数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 3, 'DI', 'DI3', 'PDI数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 4, 'DI', 'DI4', 'PDI数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 5, 'DI', 'DI5', 'PDI数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 6, 'DI', 'DI6', 'PDI数字输入点6'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 7, 'DI', 'DI7', 'PDI数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 8, 'DI', 'DI8', 'PDI数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 9, 'DI', 'DI9', 'PDI数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 10, 'DI', 'DI10', 'PDI数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 11, 'DI', 'DI11', 'PDI数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 12, 'DI', 'DI12', 'PDI数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 13, 'DI', 'DI13', 'PDI数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 14, 'DI', 'DI14', 'PDI数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 15, 'DI', 'DI15', 'PDI数字输入点15');

-- PDO设备点位配置（16个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PDO'), 0, 'DO', 'DO0', 'write', 'PDO数字输出点0'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 1, 'DO', 'DO1', 'write', 'PDO数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 2, 'DO', 'DO2', 'write', 'PDO数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 3, 'DO', 'DO3', 'write', 'PDO数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 4, 'DO', 'DO4', 'write', 'PDO数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 5, 'DO', 'DO5', 'write', 'PDO数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 6, 'DO', 'DO6', 'write', 'PDO数字输出点6'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 7, 'DO', 'DO7', 'write', 'PDO数字输出点7'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 8, 'DO', 'DO8', 'write', 'PDO数字输出点8'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 9, 'DO', 'DO9', 'write', 'PDO数字输出点9'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 10, 'DO', 'DO10', 'write', 'PDO数字输出点10'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 11, 'DO', 'DO11', 'write', 'PDO数字输出点11'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 12, 'DO', 'DO12', 'write', 'PDO数字输出点12'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 13, 'DO', 'DO13', 'write', 'PDO数字输出点13'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 14, 'DO', 'DO14', 'write', 'PDO数字输出点14'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 15, 'DO', 'DO15', 'write', 'PDO数字输出点15');

-- PAI设备点位配置（16个AI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PAI'), 0, 'AI', 'AI0', 'read', 'PAI模拟输入点0'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 1, 'AI', 'AI1', 'read', 'PAI模拟输入点1'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 2, 'AI', 'AI2', 'read', 'PAI模拟输入点2'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 3, 'AI', 'AI3', 'read', 'PAI模拟输入点3'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 4, 'AI', 'AI4', 'read', 'PAI模拟输入点4'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 5, 'AI', 'AI5', 'read', 'PAI模拟输入点5'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 6, 'AI', 'AI6', 'read', 'PAI模拟输入点6'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 7, 'AI', 'AI7', 'read', 'PAI模拟输入点7'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 8, 'AI', 'AI8', 'read', 'PAI模拟输入点8'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 9, 'AI', 'AI9', 'read', 'PAI模拟输入点9'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 10, 'AI', 'AI10', 'read', 'PAI模拟输入点10'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 11, 'AI', 'AI11', 'read', 'PAI模拟输入点11'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 12, 'AI', 'AI12', 'read', 'PAI模拟输入点12'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 13, 'AI', 'AI13', 'read', 'PAI模拟输入点13'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 14, 'AI', 'AI14', 'read', 'PAI模拟输入点14'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 15, 'AI', 'AI15', 'read', 'PAI模拟输入点15');

-- PAO设备点位配置（16个AO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PAO'), 0, 'AO', 'AO0', 'write', 'PAO模拟输出点0'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 1, 'AO', 'AO1', 'write', 'PAO模拟输出点1'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 2, 'AO', 'AO2', 'write', 'PAO模拟输出点2'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 3, 'AO', 'AO3', 'write', 'PAO模拟输出点3'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 4, 'AO', 'AO4', 'write', 'PAO模拟输出点4'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 5, 'AO', 'AO5', 'write', 'PAO模拟输出点5'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 6, 'AO', 'AO6', 'write', 'PAO模拟输出点6'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 7, 'AO', 'AO7', 'write', 'PAO模拟输出点7'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 8, 'AO', 'AO8', 'write', 'PAO模拟输出点8'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 9, 'AO', 'AO9', 'write', 'PAO模拟输出点9'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 10, 'AO', 'AO10', 'write', 'PAO模拟输出点10'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 11, 'AO', 'AO11', 'write', 'PAO模拟输出点11'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 12, 'AO', 'AO12', 'write', 'PAO模拟输出点12'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 13, 'AO', 'AO13', 'write', 'PAO模拟输出点13'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 14, 'AO', 'AO14', 'write', 'PAO模拟输出点14'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 15, 'AO', 'AO15', 'write', 'PAO模拟输出点15');

-- HI设备点位配置（20个AI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'HI'), 0, 'AI', 'AI0', 'read', 'HI模拟输入点0'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 1, 'AI', 'AI1', 'read', 'HI模拟输入点1'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 2, 'AI', 'AI2', 'read', 'HI模拟输入点2'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 3, 'AI', 'AI3', 'read', 'HI模拟输入点3'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 4, 'AI', 'AI4', 'read', 'HI模拟输入点4'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 5, 'AI', 'AI5', 'read', 'HI模拟输入点5'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 6, 'AI', 'AI6', 'read', 'HI模拟输入点6'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 7, 'AI', 'AI7', 'read', 'HI模拟输入点7'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 8, 'AI', 'AI8', 'read', 'HI模拟输入点8'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 9, 'AI', 'AI9', 'read', 'HI模拟输入点9'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 10, 'AI', 'AI10', 'read', 'HI模拟输入点10'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 11, 'AI', 'AI11', 'read', 'HI模拟输入点11'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 12, 'AI', 'AI12', 'read', 'HI模拟输入点12'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 13, 'AI', 'AI13', 'read', 'HI模拟输入点13'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 14, 'AI', 'AI14', 'read', 'HI模拟输入点14'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 15, 'AI', 'AI15', 'read', 'HI模拟输入点15'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 16, 'AI', 'AI16', 'read', 'HI模拟输入点16'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 17, 'AI', 'AI17', 'read', 'HI模拟输入点17'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 18, 'AI', 'AI18', 'read', 'HI模拟输入点18'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 19, 'AI', 'AI19', 'read', 'HI模拟输入点19');

-- HO设备点位配置（20个AO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, mode, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'HO'), 0, 'AO', 'AO0', 'write', 'HO模拟输出点0'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 1, 'AO', 'AO1', 'write', 'HO模拟输出点1'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 2, 'AO', 'AO2', 'write', 'HO模拟输出点2'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 3, 'AO', 'AO3', 'write', 'HO模拟输出点3'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 4, 'AO', 'AO4', 'write', 'HO模拟输出点4'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 5, 'AO', 'AO5', 'write', 'HO模拟输出点5'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 6, 'AO', 'AO6', 'write', 'HO模拟输出点6'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 7, 'AO', 'AO7', 'write', 'HO模拟输出点7'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 8, 'AO', 'AO8', 'write', 'HO模拟输出点8'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 9, 'AO', 'AO9', 'write', 'HO模拟输出点9'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 10, 'AO', 'AO10', 'write', 'HO模拟输出点10'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 11, 'AO', 'AO11', 'write', 'HO模拟输出点11'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 12, 'AO', 'AO12', 'write', 'HO模拟输出点12'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 13, 'AO', 'AO13', 'write', 'HO模拟输出点13'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 14, 'AO', 'AO14', 'write', 'HO模拟输出点14'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 15, 'AO', 'AO15', 'write', 'HO模拟输出点15'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 16, 'AO', 'AO16', 'write', 'HO模拟输出点16'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 17, 'AO', 'AO17', 'write', 'HO模拟输出点17'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 18, 'AO', 'AO18', 'write', 'HO模拟输出点18'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 19, 'AO', 'AO19', 'write', 'HO模拟输出点19');

-- 开启外键检查
SET FOREIGN_KEY_CHECKS = 1;