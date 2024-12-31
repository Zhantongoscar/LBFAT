// 测试实例状态
exports.TestStatus = {
  PENDING: 'pending',    // 待执行
  RUNNING: 'running',    // 执行中
  COMPLETED: 'completed',// 已完成
  ABORTED: 'aborted'     // 已中止
};

// 测试结果
exports.TestResult = {
  UNKNOWN: 'unknown',    // 未知
  PASS: 'pass',         // 通过
  FAIL: 'fail',         // 失败
  ERROR: 'error'        // 错误
};

// 执行状态
exports.ExecutionStatus = {
  PENDING: 'pending',    // 待执行
  RUNNING: 'running',    // 执行中
  COMPLETED: 'completed',// 已完成
  SKIPPED: 'skipped',   // 已跳过
  TIMEOUT: 'timeout'    // 超时
}; 