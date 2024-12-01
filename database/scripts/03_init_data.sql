/**
 * @see ../docs/03-detailed-design/database/database-design.md - 数据库设计
 * @see ../docs/03-detailed-design/00-common/data-format-standard.md - 数据格式标准
 */

-- 初始化设备类型数据
INSERT INTO device_types 
    (type_code, type_name, description) 
VALUES 
    ('EDB', 'EDB测试盒', 'EDB设备测试专用测试盒'),
    ('NA', '网络分析仪', '网络信号分析设备');

-- 初始化测试步骤模板
INSERT INTO test_sessions 
    (session_id, device_id, user_project, status, total_steps, start_time) 
VALUES 
    ('TEMPLATE_EDB', 1001, 'system', 'completed', 5, NOW());

INSERT INTO test_results 
    (session_id, step_name, step, status, success, result_value, result_unit) 
VALUES 
    ('TEMPLATE_EDB', '设备连接检查', 1, 'success', true, null, null),
    ('TEMPLATE_EDB', '信号强度测试', 2, 'success', true, -45, 'dBm'),
    ('TEMPLATE_EDB', '通信延迟测试', 3, 'success', true, 20, 'ms'),
    ('TEMPLATE_EDB', '数据吞吐量测试', 4, 'success', true, 100, 'Mbps'),
    ('TEMPLATE_EDB', '稳定性测试', 5, 'success', true, 99.9, '%'); 

-- 设备类型说明：
-- EDB: EDB测试盒，用于设备基础功能测试
-- NA: 网络分析仪，用于网络性能测试

-- 测试步骤说明：
-- 1. 设备连接检查：验证设备是否正常连接
-- 2. 信号强度测试：测量设备信号强度
-- 3. 通信延迟测试：测量通信延迟
-- 4. 数据吞吐量测试：测量数据传输速率
-- 5. 稳定性测试：测试长期稳定性 

-- 说明：
-- device_id 编号规则：
-- 1. 从1001开始的整数
-- 2. 每个设备唯一分配一个编号
-- 3. 系统预留1001-1100用于模板和测试 