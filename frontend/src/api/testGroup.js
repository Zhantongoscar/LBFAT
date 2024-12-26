import request from '@/utils/request'

// 获取指定真值表下的所有测试组
export function getTestGroups(truthTableId) {
  return request({
    url: `/truth-tables/${truthTableId}/groups`,
    method: 'get'
  })
}

// 创建测试组
export function createTestGroup(truthTableId, data) {
  return request({
    url: `/truth-tables/${truthTableId}/groups`,
    method: 'post',
    data
  })
}

// 更新测试组
export function updateTestGroup(truthTableId, id, data) {
  return request({
    url: `/truth-tables/${truthTableId}/groups/${id}`,
    method: 'put',
    data
  })
}

// 删除测试组
export function deleteTestGroup(truthTableId, id) {
  return request({
    url: `/truth-tables/${truthTableId}/groups/${id}`,
    method: 'delete'
  })
} 