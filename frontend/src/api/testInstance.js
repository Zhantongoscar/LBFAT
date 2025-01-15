import api from '@/utils/api'

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
  return api.get('/test-instances')
}

// 创建测试实例
export function createTestInstance(data) {
  return api.post('/test-instances', data)
}

// 更新测试实例
export function updateTestInstance(id, data) {
  return api.put(`/test-instances/${id}`, data)
}

// 删除测试实例
export function deleteTestInstance(id) {
  return api.delete(`/test-instances/${id}`)
}

// 获取测试实例详情
export function getTestInstanceDetail(id) {
  return api({
    url: `/test-instances/${id}`,
    method: 'get'
  })
}

// 开始测试
export function startTest(id) {
  return api({
    url: `/test-instances/${id}/start`,
    method: 'post'
  })
}

// 完成测试
export function completeTest(id, result) {
  return api({
    url: `/test-instances/${id}/complete`,
    method: 'post',
    data: { result }
  })
}

// 获取测试项列表
export function getTestItems(instanceId) {
  return api.get(`/test-instances/${instanceId}/items`)
}

// 执行测试项
export function executeTestItem(instanceId, itemId) {
  return api({
    url: `/test-instances/${instanceId}/items/${itemId}/execute`,
    method: 'post'
  })
}

// 跳过测试项
export function skipTestItem(instanceId, itemId) {
  return api({
    url: `/test-instances/${instanceId}/items/${itemId}/skip`,
    method: 'post'
  })
}

// 获取测试项详情
export function getTestItemDetail(instanceId, itemId) {
  return api({
    url: `/test-instances/${instanceId}/items/${itemId}`,
    method: 'get'
  })
}

// 获取/创建测试项
export function getOrCreateTestItems(instanceId) {
  return api.get(`/test-instances/${instanceId}/items`)
}

// 创建测试项
export function createInstanceItems(instanceId) {
  return api({
    url: `/test-instances/${instanceId}/items/create`,
    method: 'post'
  })
}

// 重置测试组
export const resetGroupItems = (instanceId, groupId) => {
  return api({
    url: `/test-instances/${instanceId}/groups/${groupId}/reset`,
    method: 'post'
  })
}

