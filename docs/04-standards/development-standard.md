/**
 * 开发规范
 * @description 定义项目开发规范和标准
 * @author -
 * @date 2024-01-21
 */

## 相关标准
- [数据格式标准](../03-detailed-design/00-common/data-format-standard.md)

## A. 代码规范
### A1. 命名规范
1. 通用规则
   - 禁止使用拼音和中文
   - 禁止使用无意义的字母
   - 名称要有明确的含义
   - 避免过长的名称

2. 特殊规则
   - ID字段统一使用id
   - 时间字段统一使用at后缀
   - 布尔字段使用is前缀
   - 枚举值使用大写下划线

3. 数据库命名
   - 表名：使用下划线命名，如 `device_types`
   - 字段名：使用下划线命名，如 `created_at`
   - 索引名：idx_字段名，如 `idx_device_code`
   - 外键名：fk_表名_字段名，如 `fk_device_types_id`
   - 存储过程：sp_动作_对象，如 `sp_update_device_status`
   - 视图：v_名词，如 `v_device_status`
   - 触发器：trg_表名_动作，如 `trg_devices_update`

4. 命名规范说明
   - 数据库层：使用下划线命名，符合数据库最佳实践
     ```sql
     SELECT * FROM device_types WHERE type_code = 'TC001';
     ```

   - API 层：使用连字符命名，符合 REST 规范
     ```
     GET /api/device-types
     GET /api/device-types/:id/status
     ```

   - 后端代码：使用驼峰命名，符合 Java/TypeScript 规范
     ```typescript
     interface DeviceType {
       deviceId: string;
       createdAt: Date;
     }
     ```

   - 前端代码：使用驼峰命名，符合 JavaScript/TypeScript 规范
     ```typescript
     const deviceStatus = {
       deviceId: string;
       isOnline: boolean;
     }
     ```

   - MQTT 主题：使用下划线命名，保持与数据库命名一致
     ```
     {project}/{device_type}/{device_id}/status
     {project}/{device_type}/{device_id}/{unit_id}/command
     {project}/{device_type}/{device_id}/{unit_id}/response
     ```

[继续其他章节...]