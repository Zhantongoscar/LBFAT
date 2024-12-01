CREATE TABLE IF NOT EXISTS devices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_code VARCHAR(32) NOT NULL COMMENT '设备编码',
    device_name VARCHAR(64) NOT NULL COMMENT '设备名称',
    status TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-离线 1-在线',
    last_online_time DATETIME COMMENT '最后在线时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_device_code (device_code)
);

CREATE TABLE IF NOT EXISTS device_status_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    status TINYINT NOT NULL COMMENT '状态：0-离线 1-在线',
    rssi INT COMMENT '信号强度',
    connect_time DATETIME COMMENT '连接时间',
    disconnect_time DATETIME COMMENT '断开时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device_time (device_id, create_time)
);

CREATE TABLE IF NOT EXISTS device_heartbeats (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    heartbeat_time DATETIME NOT NULL COMMENT '心跳时间',
    rssi INT COMMENT '信号强度',
    latency INT COMMENT '延迟(ms)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device_time (device_id, heartbeat_time)
);

CREATE TABLE IF NOT EXISTS device_alerts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    alert_type VARCHAR(32) NOT NULL COMMENT '告警类型',
    alert_level TINYINT NOT NULL COMMENT '告警级别：1-提示 2-警告 3-错误 4-严重',
    alert_content TEXT NOT NULL COMMENT '告警内容',
    is_handled TINYINT NOT NULL DEFAULT 0 COMMENT '是否处理：0-未处理 1-已处理',
    handle_time DATETIME COMMENT '处理时间',
    handle_note TEXT COMMENT '处理说明',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device_time (device_id, create_time)
);

CREATE TABLE IF NOT EXISTS device_connection_quality (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL COMMENT '设备ID',
    check_time DATETIME NOT NULL COMMENT '检测时间',
    packet_loss_rate DECIMAL(5,2) COMMENT '丢包率(%)',
    network_delay INT COMMENT '网络延迟(ms)',
    signal_strength INT COMMENT '信号强度(dBm)',
    connection_score INT COMMENT '连接质量评分(0-100)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_device_check (device_id, check_time)
); 