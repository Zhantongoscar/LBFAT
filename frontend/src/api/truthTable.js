import api from '@/utils/api'

// 获取可用的图纸和版本列表
export function getAvailableDrawings() {
    return api.get('/truth-tables/available-drawings')
}

// 获取真值表列表
export function getTruthTables() {
    return api.get('/truth-tables')
}

// 获取真值表详情
export function getTruthTable(id) {
    return api.get(`/truth-tables/${id}`)
}

// 创建真值表
export function createTruthTable(data) {
    return api.post('/truth-tables', data)
}

// 更新真值表
export function updateTruthTable(id, data) {
    return api.put(`/truth-tables/${id}`, data)
}

// 删除真值表
export function deleteTruthTable(id) {
    return api.delete(`/truth-tables/${id}`)
}

// 创建测试组
export function createTestGroup(data) {
    return api.post('/test-groups', data)
}

// 更新测试组
export function updateTestGroup(id, data) {
    return api.put(`/test-groups/${id}`, data)
}

// 删除测试组
export function deleteTestGroup(id) {
    return api.delete(`/test-groups/${id}`)
} 