CREATE DATABASE IF NOT EXISTS lbfat;
USE lbfat;

CREATE TABLE IF NOT EXISTS project_subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(50) NOT NULL UNIQUE COMMENT '项目名称',
    is_subscribed BOOLEAN DEFAULT false COMMENT '是否已订阅',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_project_name (project_name)
) COMMENT '项目订阅管理表';

-- 先插入项目数据
INSERT INTO project_subscriptions (project_name, is_subscribed) VALUES
('lb_test', true),
('lb_prod', false);

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

-- 再插入设备数据
INSERT INTO devices (project_name, module_type, serial_number, status, rssi) VALUES
('lb_test', 'EDB', '4', 'offline', 0);

-- 创建MQTT订阅表
CREATE TABLE IF NOT EXISTS mqtt_subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    topic VARCHAR(255) NOT NULL,
    qos INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 插入初始订阅
INSERT INTO mqtt_subscriptions (topic, qos, is_active) VALUES
    ('lb_test/+/+/status', 1, TRUE);