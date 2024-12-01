-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS lbfat;
USE lbfat;

-- 设备表
CREATE TABLE IF NOT EXISTS devices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_code VARCHAR(50) NOT NULL UNIQUE,
    device_name VARCHAR(100),
    device_type VARCHAR(50),
    status TINYINT DEFAULT 0,
    last_online_time DATETIME,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 设备状态日志表
CREATE TABLE IF NOT EXISTS device_status_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT,
    status TINYINT,
    rssi INT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(id)
);

-- 设备心跳表
CREATE TABLE IF NOT EXISTS device_heartbeats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT,
    rssi INT,
    network_delay INT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(id)
);

-- 设备连接质量表
CREATE TABLE IF NOT EXISTS device_connection_quality (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_id INT,
    packet_loss_rate FLOAT,
    network_delay INT,
    signal_strength INT,
    connection_score INT,
    check_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(id)
); 