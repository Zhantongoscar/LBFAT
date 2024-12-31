import api from '../utils/api'

// 创建测试实例
export function createTestInstance(data) {
  return api.post('/test-instances', data)
}

// 开始测试
export function startTest(instanceId) {
  return api.post(`/test-instances/${instanceId}/start`)
}

// 更新测试项状态
export function updateTestItemStatus(instanceId, itemId, data) {
  return api.put(`/test-instances/${instanceId}/items/${itemId}`, data)
}

// 完成测试
export function completeTest(instanceId, result) {
  return api.post(`/test-instances/${instanceId}/complete`, { result })
}

// 获取测试实例详情
export function getTestInstance(instanceId) {
  return api.get(`/test-instances/${instanceId}`)
}

// 获取测试实例列表
export function getTestInstances(params) {
  return api.get('/test-instances', { params })
}

// 删除测试实例
export function deleteTestInstance(instanceId) {
  return api.delete(`/test-instances/${instanceId}`)
}

// 测试状态常量
export const TestStatus = {
  PENDING: 'pending',
  RUNNING: 'running',
  COMPLETED: 'completed',
  ABORTED: 'aborted'
}

// 测试结果常量
export const TestResult = {
  UNKNOWN: 'unknown',
  PASS: 'pass',
  FAIL: 'fail'
}

// 执行状态常量
export const ExecutionStatus = {
  PENDING: 'pending',
  RUNNING: 'running',
  COMPLETED: 'completed',
  SKIPPED: 'skipped',
  TIMEOUT: 'timeout'
}

// 结果状态常量
export const ResultStatus = {
  UNKNOWN: 'unknown',
  PASS: 'pass',
  FAIL: 'fail',
  ERROR: 'error'
} 