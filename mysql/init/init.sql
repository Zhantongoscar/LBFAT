-- 设置字符集和关闭外键检查
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建并使用数据库
CREATE DATABASE IF NOT EXISTS lbfat;
USE lbfat;

-- =====================================================
-- 基础表结构
-- =====================================================

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

-- =====================================================
-- 设备类型和点位配置
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
    description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_type_id) REFERENCES device_types(id) ON DELETE CASCADE,
    UNIQUE KEY unique_point (device_type_id, point_index)
) COMMENT '设备点位配置表';

-- =====================================================
-- 测试相关表结构
-- =====================================================

-- 测试模板表
CREATE TABLE IF NOT EXISTS test_templates (
    template_id VARCHAR(50) PRIMARY KEY,
    device_type_id VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    version VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT '测试模板表';

-- 测试批次表
CREATE TABLE IF NOT EXISTS test_batches (
    batch_id VARCHAR(50) PRIMARY KEY,
    template_id VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    sequence INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES test_templates(template_id)
) COMMENT '测试批次管理表';

-- 批次步骤关联表
CREATE TABLE IF NOT EXISTS batch_steps (
    batch_id VARCHAR(50),
    step_id INT,
    sequence INT,
    PRIMARY KEY (batch_id, step_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (batch_id) REFERENCES test_batches(batch_id)
) COMMENT '批次步骤关联表';

-- 测试步骤表
CREATE TABLE IF NOT EXISTS template_steps (
    step_id INT,
    template_id VARCHAR(50),
    unit VARCHAR(50),
    operation VARCHAR(20),
    value FLOAT,
    expect_value FLOAT,
    timeout INT,
    batch_id VARCHAR(50) COMMENT '关联批次ID',
    tolerance FLOAT COMMENT '允许误差范围',
    is_enabled BOOLEAN DEFAULT true COMMENT '步骤启用状态',
    PRIMARY KEY (template_id, step_id)
) COMMENT '测试步骤表';

-- =====================================================
-- 初始数据
-- =====================================================

-- 插入项目数据
INSERT INTO project_subscriptions (project_name, is_subscribed) VALUES
('lb_test', true),
('lb_prod', false);

-- 插入设备数据
INSERT INTO devices (project_name, module_type, serial_number, status, rssi) VALUES
('lb_test', 'EDB', '4', 'offline', 0);

-- 插入MQTT订阅
INSERT INTO mqtt_subscriptions (topic, qos, is_active) VALUES
('lb_test/+/+/status', 1, TRUE);

-- 插入EDB设备类型
INSERT INTO device_types (type_name, point_count, description) VALUES
('EDB', 20, 'EDB设备：20个点位配置（7DI + 3DO + 7DI + 3DI）');

-- 插入EDB设备点位配置
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
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
(1, 20, 'DI', 'DI17', 'EDB数字输入点17 - 后段');

-- 开启外键检查
SET FOREIGN_KEY_CHECKS = 1;