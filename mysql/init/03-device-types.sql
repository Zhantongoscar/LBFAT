-- 添加预定义的设备类型
INSERT INTO device_types (type_name, point_count, description) VALUES
('EDB', 20, '增强测试模块 - EDB设备：20个点位配置（7DI + 3DO + 7DI + 3DI）'),
('EBD', 20, '增强测试模块 - EBD设备：20个点位配置（7DO + 3DI + 10DO）'),
('EA', 20, '通用模板 - EA设备：20个点位配置（14DO + 6DI）'),
('EC', 20, '通用模板 - EC设备：20个点位配置（14DO + 6DI）'),
('EF', 20, '通用模板 - EF设备：20个点位配置（20DI）'),
('EW', 20, '通用模板 - EW设备：20个点位配置（6DI + 2DO + 12DI）'),
('PDI', 16, 'PLC - PDI设备：16个数字输入点位'),
('PDO', 16, 'PLC - PDO设备：16个数字输出点位'),
('PAI', 16, 'PLC - PAI设备：16个模拟输入点位'),
('PAO', 16, 'PLC - PAO设备：16个模拟输出点位'),
('HI', 20, '人工测试 - HI设备：20个模拟输入点位'),
('HO', 20, '人工测试 - HO设备：20个模拟输出点位'),
('D', 6, '普通测试设备 - D设备：6个数字输入点位'),
('B', 6, '普通测试设备 - B设备：6个数字输出点位'),
('A', 6, '普通测试设备 - A设备：6个点位配置（4DO + 2DI）'),
('C', 6, '普通测试设备 - C设备：6个点位配置（4DO + 2DI）'),
('F', 6, '普通测试设备 - F设备：6个数字输入点位'),
('W', 6, '普通测试设备 - W设备：6个点位配置（2DI + 2DO + 2DI）');

-- EA设备点位配置
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
-- EA设备的14个DO点位
((SELECT id FROM device_types WHERE type_name = 'EA'), 0, 'DO', 'DO1', 'PIN:17'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 1, 'DO', 'DO2', 'PIN:18'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 2, 'DO', 'DO3', 'PIN:19'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 3, 'DO', 'DO4', 'PIN:21'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 4, 'DO', 'DO5', 'PIN:22'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 5, 'DO', 'DO6', 'PIN:23'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 6, 'DO', 'DO7', 'PIN:16'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 7, 'DO', 'DO8', 'PIN:4'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 8, 'DO', 'DO9', 'PIN:32'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 9, 'DO', 'DO10', 'PIN:33'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 10, 'DO', 'DO11', 'PIN:25'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 11, 'DO', 'DO12', 'PIN:26'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 12, 'DO', 'DO13', 'PIN:27'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 13, 'DO', 'DO14', 'PIN:14'),
-- EA设备的6个DI点位
((SELECT id FROM device_types WHERE type_name = 'EA'), 14, 'DI', 'DI1', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 15, 'DI', 'DI2', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 16, 'DI', 'DI3', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 17, 'DI', 'DI4', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 18, 'DI', 'DI5', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EA'), 19, 'DI', 'DI6', 'PIN:50');

-- EC设备点位配置（与EA相同的配置）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
-- EC设备的14个DO点位
((SELECT id FROM device_types WHERE type_name = 'EC'), 0, 'DO', 'DO1', 'PIN:17'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 1, 'DO', 'DO2', 'PIN:18'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 2, 'DO', 'DO3', 'PIN:19'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 3, 'DO', 'DO4', 'PIN:21'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 4, 'DO', 'DO5', 'PIN:22'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 5, 'DO', 'DO6', 'PIN:23'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 6, 'DO', 'DO7', 'PIN:16'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 7, 'DO', 'DO8', 'PIN:4'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 8, 'DO', 'DO9', 'PIN:32'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 9, 'DO', 'DO10', 'PIN:33'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 10, 'DO', 'DO11', 'PIN:25'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 11, 'DO', 'DO12', 'PIN:26'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 12, 'DO', 'DO13', 'PIN:27'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 13, 'DO', 'DO14', 'PIN:14'),
-- EC设备的6个DI点位
((SELECT id FROM device_types WHERE type_name = 'EC'), 14, 'DI', 'DI1', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 15, 'DI', 'DI2', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 16, 'DI', 'DI3', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 17, 'DI', 'DI4', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 18, 'DI', 'DI5', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EC'), 19, 'DI', 'DI6', 'PIN:50');

-- EF设备点位配置
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
-- EF设备的20个DI点位
((SELECT id FROM device_types WHERE type_name = 'EF'), 0, 'DI', 'DI1', 'PIN:16'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 1, 'DI', 'DI2', 'PIN:17'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 2, 'DI', 'DI3', 'PIN:18'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 3, 'DI', 'DI4', 'PIN:19'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 4, 'DI', 'DI5', 'PIN:21'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 5, 'DI', 'DI6', 'PIN:22'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 6, 'DI', 'DI7', 'PIN:23'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 7, 'DI', 'DI8', 'PIN:36'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 8, 'DI', 'DI9', 'PIN:39'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 9, 'DI', 'DI10', 'PIN:34'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 10, 'DI', 'DI11', 'PIN:35'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 11, 'DI', 'DI12', 'PIN:32'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 12, 'DI', 'DI13', 'PIN:33'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 13, 'DI', 'DI14', 'PIN:25'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 14, 'DI', 'DI15', 'PIN:26'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 15, 'DI', 'DI16', 'PIN:27'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 16, 'DI', 'DI17', 'PIN:14'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 17, 'DI', 'DI18', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 18, 'DI', 'DI19', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EF'), 19, 'DI', 'DI20', 'PIN:50');

-- EW设备点位配置
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
-- EW设备的6个DI点位
((SELECT id FROM device_types WHERE type_name = 'EW'), 0, 'DI', 'DI1', 'PIN:36'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 1, 'DI', 'DI2', 'PIN:39'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 2, 'DI', 'DI3', 'PIN:34'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 3, 'DI', 'DI4', 'PIN:35'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 4, 'DI', 'DI5', 'PIN:32'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 5, 'DI', 'DI6', 'PIN:33'),
-- EW设备的2个DO点位
((SELECT id FROM device_types WHERE type_name = 'EW'), 6, 'DO', 'DO1', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 7, 'DI', 'DI7', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 8, 'DI', 'DI8', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 9, 'DI', 'DI9', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 10, 'DI', 'DI10', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 11, 'DI', 'DI11', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 12, 'DO', 'DO2', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 13, 'DO', 'DO3', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 14, 'DI', 'DI12', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 15, 'DI', 'DI13', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 16, 'DI', 'DI14', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 17, 'DI', 'DI15', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 18, 'DI', 'DI16', 'PIN:50'),
((SELECT id FROM device_types WHERE type_name = 'EW'), 19, 'DI', 'DI17', 'PIN:50');

-- PDI设备点位配置（16个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PDI'), 0, 'DI', 'DI1', 'PDI数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 1, 'DI', 'DI2', 'PDI数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 2, 'DI', 'DI3', 'PDI数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 3, 'DI', 'DI4', 'PDI数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 4, 'DI', 'DI5', 'PDI数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 5, 'DI', 'DI6', 'PDI数字输入点6'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 6, 'DI', 'DI7', 'PDI数字输入点7'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 7, 'DI', 'DI8', 'PDI数字输入点8'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 8, 'DI', 'DI9', 'PDI数字输入点9'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 9, 'DI', 'DI10', 'PDI数字输入点10'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 10, 'DI', 'DI11', 'PDI数字输入点11'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 11, 'DI', 'DI12', 'PDI数字输入点12'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 12, 'DI', 'DI13', 'PDI数字输入点13'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 13, 'DI', 'DI14', 'PDI数字输入点14'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 14, 'DI', 'DI15', 'PDI数字输入点15'),
((SELECT id FROM device_types WHERE type_name = 'PDI'), 15, 'DI', 'DI16', 'PDI数字输入点16');

-- PDO设备点位配置（16个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PDO'), 0, 'DO', 'DO1', 'PDO数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 1, 'DO', 'DO2', 'PDO数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 2, 'DO', 'DO3', 'PDO数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 3, 'DO', 'DO4', 'PDO数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 4, 'DO', 'DO5', 'PDO数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 5, 'DO', 'DO6', 'PDO数字输出点6'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 6, 'DO', 'DO7', 'PDO数字输出点7'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 7, 'DO', 'DO8', 'PDO数字输出点8'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 8, 'DO', 'DO9', 'PDO数字输出点9'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 9, 'DO', 'DO10', 'PDO数字输出点10'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 10, 'DO', 'DO11', 'PDO数字输出点11'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 11, 'DO', 'DO12', 'PDO数字输出点12'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 12, 'DO', 'DO13', 'PDO数字输出点13'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 13, 'DO', 'DO14', 'PDO数字输出点14'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 14, 'DO', 'DO15', 'PDO数字输出点15'),
((SELECT id FROM device_types WHERE type_name = 'PDO'), 15, 'DO', 'DO16', 'PDO数字输出点16');

-- PAI设备点位配置（16个AI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PAI'), 0, 'AI', 'AI1', 'PAI模拟输入点1'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 1, 'AI', 'AI2', 'PAI模拟输入点2'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 2, 'AI', 'AI3', 'PAI模拟输入点3'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 3, 'AI', 'AI4', 'PAI模拟输入点4'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 4, 'AI', 'AI5', 'PAI模拟输入点5'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 5, 'AI', 'AI6', 'PAI模拟输入点6'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 6, 'AI', 'AI7', 'PAI模拟输入点7'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 7, 'AI', 'AI8', 'PAI模拟输入点8'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 8, 'AI', 'AI9', 'PAI模拟输入点9'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 9, 'AI', 'AI10', 'PAI模拟输入点10'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 10, 'AI', 'AI11', 'PAI模拟输入点11'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 11, 'AI', 'AI12', 'PAI模拟输入点12'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 12, 'AI', 'AI13', 'PAI模拟输入点13'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 13, 'AI', 'AI14', 'PAI模拟输入点14'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 14, 'AI', 'AI15', 'PAI模拟输入点15'),
((SELECT id FROM device_types WHERE type_name = 'PAI'), 15, 'AI', 'AI16', 'PAI模拟输入点16');

-- PAO设备点位配置（16个AO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'PAO'), 0, 'AO', 'AO1', 'PAO模拟输出点1'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 1, 'AO', 'AO2', 'PAO模拟输出点2'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 2, 'AO', 'AO3', 'PAO模拟输出点3'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 3, 'AO', 'AO4', 'PAO模拟输出点4'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 4, 'AO', 'AO5', 'PAO模拟输出点5'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 5, 'AO', 'AO6', 'PAO模拟输出点6'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 6, 'AO', 'AO7', 'PAO模拟输出点7'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 7, 'AO', 'AO8', 'PAO模拟输出点8'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 8, 'AO', 'AO9', 'PAO模拟输出点9'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 9, 'AO', 'AO10', 'PAO模拟输出点10'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 10, 'AO', 'AO11', 'PAO模拟输出点11'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 11, 'AO', 'AO12', 'PAO模拟输出点12'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 12, 'AO', 'AO13', 'PAO模拟输出点13'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 13, 'AO', 'AO14', 'PAO模拟输出点14'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 14, 'AO', 'AO15', 'PAO模拟输出点15'),
((SELECT id FROM device_types WHERE type_name = 'PAO'), 15, 'AO', 'AO16', 'PAO模拟输出点16');

-- HI设备点位配置（20个AI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'HI'), 0, 'AI', 'AI1', 'HI模拟输入点1'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 1, 'AI', 'AI2', 'HI模拟输入点2'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 2, 'AI', 'AI3', 'HI模拟输入点3'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 3, 'AI', 'AI4', 'HI模拟输入点4'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 4, 'AI', 'AI5', 'HI模拟输入点5'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 5, 'AI', 'AI6', 'HI模拟输入点6'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 6, 'AI', 'AI7', 'HI模拟输入点7'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 7, 'AI', 'AI8', 'HI模拟输入点8'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 8, 'AI', 'AI9', 'HI模拟输入点9'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 9, 'AI', 'AI10', 'HI模拟输入点10'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 10, 'AI', 'AI11', 'HI模拟输入点11'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 11, 'AI', 'AI12', 'HI模拟输入点12'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 12, 'AI', 'AI13', 'HI模拟输入点13'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 13, 'AI', 'AI14', 'HI模拟输入点14'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 14, 'AI', 'AI15', 'HI模拟输入点15'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 15, 'AI', 'AI16', 'HI模拟输入点16'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 16, 'AI', 'AI17', 'HI模拟输入点17'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 17, 'AI', 'AI18', 'HI模拟输入点18'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 18, 'AI', 'AI19', 'HI模拟输入点19'),
((SELECT id FROM device_types WHERE type_name = 'HI'), 19, 'AI', 'AI20', 'HI模拟输入点20');

-- HO设备点位配置（20个AO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'HO'), 0, 'AO', 'AO1', 'HO模拟输出点1'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 1, 'AO', 'AO2', 'HO模拟输出点2'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 2, 'AO', 'AO3', 'HO模拟输出点3'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 3, 'AO', 'AO4', 'HO模拟输出点4'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 4, 'AO', 'AO5', 'HO模拟输出点5'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 5, 'AO', 'AO6', 'HO模拟输出点6'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 6, 'AO', 'AO7', 'HO模拟输出点7'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 7, 'AO', 'AO8', 'HO模拟输出点8'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 8, 'AO', 'AO9', 'HO模拟输出点9'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 9, 'AO', 'AO10', 'HO模拟输出点10'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 10, 'AO', 'AO11', 'HO模拟输出点11'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 11, 'AO', 'AO12', 'HO模拟输出点12'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 12, 'AO', 'AO13', 'HO模拟输出点13'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 13, 'AO', 'AO14', 'HO模拟输出点14'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 14, 'AO', 'AO15', 'HO模拟输出点15'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 15, 'AO', 'AO16', 'HO模拟输出点16'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 16, 'AO', 'AO17', 'HO模拟输出点17'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 17, 'AO', 'AO18', 'HO模拟输出点18'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 18, 'AO', 'AO19', 'HO模拟输出点19'),
((SELECT id FROM device_types WHERE type_name = 'HO'), 19, 'AO', 'AO20', 'HO模拟输出点20');

-- D设备点位配置（6个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'D'), 0, 'DI', 'DI1', 'D数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'D'), 1, 'DI', 'DI2', 'D数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'D'), 2, 'DI', 'DI3', 'D数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'D'), 3, 'DI', 'DI4', 'D数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'D'), 4, 'DI', 'DI5', 'D数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'D'), 5, 'DI', 'DI6', 'D数字输入点6');

-- B设备点位配置（6个DO点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'B'), 0, 'DO', 'DO1', 'B数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'B'), 1, 'DO', 'DO2', 'B数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'B'), 2, 'DO', 'DO3', 'B数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'B'), 3, 'DO', 'DO4', 'B数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'B'), 4, 'DO', 'DO5', 'B数字输出点5'),
((SELECT id FROM device_types WHERE type_name = 'B'), 5, 'DO', 'DO6', 'B数字输出点6');

-- A设备点位配置（4DO + 2DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'A'), 0, 'DO', 'DO1', 'A数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'A'), 1, 'DO', 'DO2', 'A数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'A'), 2, 'DO', 'DO3', 'A数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'A'), 3, 'DO', 'DO4', 'A数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'A'), 4, 'DI', 'DI1', 'A数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'A'), 5, 'DI', 'DI2', 'A数字输入点2');

-- C设备点位配置（4DO + 2DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'C'), 0, 'DO', 'DO1', 'C数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'C'), 1, 'DO', 'DO2', 'C数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'C'), 2, 'DO', 'DO3', 'C数字输出点3'),
((SELECT id FROM device_types WHERE type_name = 'C'), 3, 'DO', 'DO4', 'C数字输出点4'),
((SELECT id FROM device_types WHERE type_name = 'C'), 4, 'DI', 'DI1', 'C数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'C'), 5, 'DI', 'DI2', 'C数字输入点2');

-- F设备点位配置（6个DI点位）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'F'), 0, 'DI', 'DI1', 'F数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'F'), 1, 'DI', 'DI2', 'F数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'F'), 2, 'DI', 'DI3', 'F数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'F'), 3, 'DI', 'DI4', 'F数字输入点4'),
((SELECT id FROM device_types WHERE type_name = 'F'), 4, 'DI', 'DI5', 'F数字输入点5'),
((SELECT id FROM device_types WHERE type_name = 'F'), 5, 'DI', 'DI6', 'F数字输入点6');

-- W设备点位配置（2DI + 2DO + 2DI）
INSERT INTO device_type_points (device_type_id, point_index, point_type, point_name, description) VALUES
((SELECT id FROM device_types WHERE type_name = 'W'), 0, 'DI', 'DI1', 'W数字输入点1'),
((SELECT id FROM device_types WHERE type_name = 'W'), 1, 'DI', 'DI2', 'W数字输入点2'),
((SELECT id FROM device_types WHERE type_name = 'W'), 2, 'DO', 'DO1', 'W数字输出点1'),
((SELECT id FROM device_types WHERE type_name = 'W'), 3, 'DO', 'DO2', 'W数字输出点2'),
((SELECT id FROM device_types WHERE type_name = 'W'), 4, 'DI', 'DI3', 'W数字输入点3'),
((SELECT id FROM device_types WHERE type_name = 'W'), 5, 'DI', 'DI4', 'W数字输入点4'); 