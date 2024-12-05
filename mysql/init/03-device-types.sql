-- 选择数据库
USE lbfat;

-- 创建设备类型表
CREATE TABLE IF NOT EXISTS device_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    point_count INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建设备点位表
CREATE TABLE IF NOT EXISTS device_type_points (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_type_id INT NOT NULL,
    point_index INT NOT NULL,
    point_type ENUM('DI','DO','AI','AO') NOT NULL,
    point_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_type_id) REFERENCES device_types(id) ON DELETE CASCADE,
    UNIQUE KEY unique_point (device_type_id, point_index)
);

-- 插入EDB设备类型数据
INSERT INTO device_types (type_name, point_count, description) VALUES
('EDB', 20, 'EDB设备：17个点位配置');

-- 插入EDB设备的点位配置（按照EDBTYPE数组配置）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
-- 前7个DI
(1, 1, 'DI', 'DI1', 'EDB数字输入点1'),
(1, 2, 'DI', 'DI2', 'EDB数字输入点2'),
(1, 3, 'DI', 'DI3', 'EDB数字输入点3'),
(1, 4, 'DI', 'DI4', 'EDB数字输入点4'),
(1, 5, 'DI', 'DI5', 'EDB数字输入点5'),
(1, 6, 'DI', 'DI6', 'EDB数字输入点6'),
(1, 7, 'DI', 'DI7', 'EDB数字输入点7'),
-- 3个DO
(1, 8, 'DO', 'DO1', 'EDB数字输出点1'),
(1, 9, 'DO', 'DO2', 'EDB数字输出点2'),
(1, 10, 'DO', 'DO3', 'EDB数字输出点3'),
-- 后7个DI
(1, 11, 'DI', 'DI8', 'EDB数字输入点8'),
(1, 12, 'DI', 'DI9', 'EDB数字输入点9'),
(1, 13, 'DI', 'DI10', 'EDB数字输入点10'),
(1, 14, 'DI', 'DI11', 'EDB数字输入点11'),
(1, 15, 'DI', 'DI12', 'EDB数字输入点12'),
(1, 16, 'DI', 'DI13', 'EDB数字输入点13'),
(1, 17, 'DI', 'DI14', 'EDB数字输入点14'),
-- 剩余3个点位（按照默认DI配置）
(1, 18, 'DI', 'DI15', 'EDB数字输入点15'),
(1, 19, 'DI', 'DI16', 'EDB数字输入点16'),
(1, 20, 'DI', 'DI17', 'EDB数字输入点17');