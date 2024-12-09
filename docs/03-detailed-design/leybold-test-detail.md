# 测试系统设计文档

## 1. 数据模型关系

### 1.1 核心实体关系
```
设备类型(DeviceType)
  ├── 真值表模板(TestTemplate)
  └── 具体设备(Device)
       └── 测试记录(TestRecord)
            └── 测试步骤结果(TestStepResult)
```

### 1.2 数据库设计
```sql
-- 真值表模板
CREATE TABLE test_templates (
    template_id VARCHAR(50) PRIMARY KEY,
    device_type_id VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    version VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- 测试步骤定义
CREATE TABLE template_steps (
    step_id INT,
    template_id VARCHAR(50),
    unit VARCHAR(50),
    operation VARCHAR(20),
    value FLOAT,
    expect_value FLOAT,
    timeout INT,
    PRIMARY KEY (template_id, step_id)
);

-- 测试记录
CREATE TABLE test_records (
    record_id VARCHAR(50) PRIMARY KEY,
    device_id VARCHAR(50),
    template_id VARCHAR(50),
    test_type VARCHAR(20),
    status VARCHAR(20),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    current_step INT
);

-- 测试步骤结果
CREATE TABLE step_results (
    record_id VARCHAR(50),
    step_id INT,
    status VARCHAR(20),
    actual_value FLOAT,
    execution_time TIMESTAMP,
    reason TEXT,
    PRIMARY KEY (record_id, step_id)
);
```

## 2. 数据结构定义

### 2.1 真值表模板
```json
{
  "templateId": "template001",
  "deviceTypeId": "type001",
  "name": "标准测试流程",
  "description": "设备出厂标准测试",
  "version": "1.0",
  "steps": [
    {
      "stepId": 1,
      "batchId": "batch001",
      "unit": {
        "name": "unit1",
        "type": "AI"
      },
      "operation": "read",
      "expectValue": 75,
      "tolerance": 5,
      "isEnabled": true,
      "matchStatus": null,
      "mismatchReason": ""
    }
  ]
}
```

### 2.2 测试记录
```json
{
  "recordId": "record001",
  "deviceId": "device001",
  "templateId": "template001",
  "testType": "ASSEMBLY_TEST",
  "status": "IN_PROGRESS",
  "startTime": "2024-01-20T10:00:00Z",
  "lastUpdateTime": "2024-01-20T10:30:00Z",
  "currentStep": 5,
  "results": [
    {
      "stepId": 1,
      "status": "SUCCESS",
      "executionTime": "2024-01-20T10:00:01Z",
      "value": 1
    }
  ]
}
```

## 3. Unit类型与操作定义

### 3.1 Unit类型映射
| Unit类型 | 默认操作 | 值范围  | 快捷选值   |
|----------|----------|---------|------------|
| DI       | read     | 0/1     | 0,1        |
| DO       | write    | 0/1     | 0,1        |
| AI       | read     | 0-100   | 0,50,100   |
| AO       | write    | 0-100   | 0,50,100   |

### 3.2 测试步骤示例
批次1：初始状态检查
1. AI1 读取  期望值：0±2     // 检查初始模拟量
2. DI1 读取  期望值：0       // 检查初始开关量

批次2：输出测试
1. AO1 写入  数值：50        // 设置模拟量输出
2. DO1 写入  数值：1         // 设置开关量输出
3. 等待 1秒
4. AI2 读取  期望值：50±5    // 检查模拟量响应
5. DI2 读取  期望值：1       // 检查开关量响应

## 4. 系统模块划分

### 4.1 前端模块
```
├── 真值表管理
│   ├── 模板创建/编辑
│   ├── 模板版本管理
│   └── 模板预览/导出
│
├── 测试执行
│   ├── 设备选择
│   ├── 测试类型选择
│   ├── 测试进度监控
│   └── 实时结果显示
│
└── 测试报告
    ├── 历史记录查询
    ├── 结果统计分析
    └── 报告导出
```

### 4.2 后端模块
```
├── 模板管理服务
│   ├── 模板CRUD
│   └── 版本控制
│
├── 测试执行服务
│   ├── 测试流程控制
│   ├── 设备通信
│   └── 结果记录
│
├── 数据存储服务
│   ├── 模板存储
│   ├── 测试记录
│   └── 统计数据
│
└── 报告服务
    ├── 数据聚合
    ├── 报告生成
    └── 导出功能
```

## 5. 关键功能实现

### 5.1 测试执行服务
```javascript
class TestExecutionService {
  // 开始新测试
  async startTest(deviceId, templateId, testType) {
    // 创建新测试记录
    // 初始化测试环境
    // 返回测试会话ID
  }

  // 继续未完成的测试
  async resumeTest(recordId) {
    // 加载测试记录
    // 验证设备状态
    // 从中断点继续执行
  }

  // 执行测试步骤
  async executeStep(recordId, stepId) {
    // 执行操作
    // 记录结果
    // 更新进度
  }

  // 中断测试
  async pauseTest(recordId) {
    // 保存当前状态
    // 记录中断点
  }
}
```

### 5.2 测试记录服务
```javascript
class TestRecordService {
  // 查询设备的测试历史
  async getDeviceTestHistory(deviceId) {
    // 返回所有测试记录
  }

  // 获取测试统计
  async getTestStatistics(deviceId) {
    // 返回测试通过率等统计数据
  }
}
```

## 6. 界面交互优化

### 6.1 步骤编辑优化
- 选择unit时自动设置操作类型
- 设置期望值时提供快捷按钮：
  * DI/DO：0/1按钮
  * AI/AO：0/50/100滑块或按钮
- 可以设置允许误差范围（特别是对AI值）
- 批次分组显示
- 显示每步骤的启用/禁用状态
- 清晰显示匹配状态和原因

### 6.2 测试执行优化
- 实时显示当前执行步骤
- 直观展示测试进度
- 突出显示异常结果
- 支持暂停/继续操作
- 提供详细的错误信息