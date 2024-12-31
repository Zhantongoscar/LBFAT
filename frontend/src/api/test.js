import api from '../utils/api'

// 获取测试实例列表
export const getTestInstances = () => {
  return api({
    url: '/test-instances',
    method: 'get'
  })
}

// 创建新的测试实例
export const createTestInstance = (data) => {
  return api({
    url: '/test-instances',
    method: 'post',
    data
  })
}

// 更新测试实例
export const updateTestInstance = (id, data) => {
  return api({
    url: `/test-instances/${id}`,
    method: 'put',
    data
  })
}

// 删除测试实例
export const deleteTestInstance = (id) => {
  return api({
    url: `/test-instances/${id}`,
    method: 'delete'
  })
}

// 开始测试
export const startTest = (id) => {
  return api({
    url: `/test-instances/${id}/start`,
    method: 'post'
  })
}

// 完成测试
export const completeTest = (id, result) => {
  return api({
    url: `/test-instances/${id}/complete`,
    method: 'post',
    data: { result }
  })
}

// 测试状态枚举
export const TestStatus = {
  PENDING: 'pending',
  RUNNING: 'running',
  COMPLETED: 'completed',
  ABORTED: 'aborted'
}

// 测试结果枚举
export const TestResult = {
  PASS: 'pass',
  FAIL: 'fail',
  ERROR: 'error',
  UNKNOWN: 'unknown'
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
  PASS: 'pass',
  FAIL: 'fail',
  ERROR: 'error',
  UNKNOWN: 'unknown'
} 