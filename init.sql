CREATE DATABASE IF NOT EXISTS lbfat DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE lbfat;

CREATE TABLE IF NOT EXISTS project_subscriptions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(32) NOT NULL COMMENT '项目名称',
    is_subscribed TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否订阅',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_project_name (project_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS devices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(32) NOT NULL COMMENT '项目名称',
    module_type VARCHAR(32) NOT NULL COMMENT '模块类型',
    serial_number VARCHAR(32) NOT NULL COMMENT '序列号',
    status VARCHAR(16) NOT NULL DEFAULT 'offline' COMMENT '当前状态',
    rssi INT COMMENT '信号强度',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_device (project_name, module_type, serial_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO project_subscriptions (project_name, is_subscribed) VALUES 
('lb_test', 1);

INSERT INTO devices (project_name, module_type, serial_number, status, rssi) VALUES 
('lb_test', 'EDB', '4', 'offline', 0);
