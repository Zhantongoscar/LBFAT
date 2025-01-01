import request from '@/utils/api'

// 测试实例状态枚举
export const TestStatus = {
  PENDING: 'pending',
  RUNNING: 'running',
  COMPLETED: 'completed',
  ABORTED: 'aborted'
}

// 测试结果枚举
export const TestResult = {
  UNKNOWN: 'unknown',
  PASS: 'pass',
  FAIL: 'fail'
}

// 执行状态枚举
export const ExecutionStatus = {
  PENDING: 'pending',
  RUNNING: 'running',
  COMPLETED: 'completed',
  SKIPPED: 'skipped',
  TIMEOUT: 'timeout'
}

// 结果状态枚举
export const ResultStatus = {
  UNKNOWN: 'unknown',
  PASS: 'pass',
  FAIL: 'fail',
  ERROR: 'error'
}

// 获取测试实例列表
export function getTestInstances() {
  return request({
    url: '/test-instances',
    method: 'get'
  })
}

// 创建测试实例
export function createTestInstance(data) {
  return request({
    url: '/test-instances',
    method: 'post',
    data
  })
}

// 更新测试实例
export function updateTestInstance(id, data) {
  return request({
    url: `/test-instances/${id}`,
    method: 'put',
    data
  })
}

// 删除测试实例
export function deleteTestInstance(id) {
  return request({
    url: `/test-instances/${id}`,
    method: 'delete'
  })
}

// 获取测试实例详情
export function getTestInstanceDetail(id) {
  return request({
    url: `/test-instances/${id}`,
    method: 'get'
  })
}

// 开始测试
export function startTest(id) {
  return request({
    url: `/test-instances/${id}/start`,
    method: 'post'
  })
}

// 完成测试
export function completeTest(id, result) {
  return request({
    url: `/test-instances/${id}/complete`,
    method: 'post',
    data: { result }
  })
}

// 获取测试项列表
export function getTestItems(instanceId) {
  return request({
    url: `/test-instances/${instanceId}/items`,
    method: 'get'
  })
}

// 执行测试项
export function executeTestItem(instanceId, itemId) {
  return request({
    url: `/test-instances/${instanceId}/items/${itemId}/execute`,
    method: 'post'
  })
}

// 跳过测试项
export function skipTestItem(instanceId, itemId) {
  return request({
    url: `/test-instances/${instanceId}/items/${itemId}/skip`,
    method: 'post'
  })
}

// 获取测试项详情
export function getTestItemDetail(instanceId, itemId) {
  return request({
    url: `/test-instances/${instanceId}/items/${itemId}`,
    method: 'get'
  })
} 