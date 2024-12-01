/**
 * @see ../docs/03-detailed-design/database/table-design.md - 数据库表设计
 * @see ../docs/03-detailed-design/00-common/data-format-standard.md - 数据格式标准
 */

-- 创建数据库
CREATE DATABASE IF NOT EXISTS lb_fat
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- 使用数据库
USE lb_fat;

-- 设置时区
SET time_zone = '+00:00'; 