import api from '@/utils/api'

// 获取真值表列表
export function getTruthTables() {
    return api.get('/api/truth-tables')
}

// 获取真值表详情
export function getTruthTable(id) {
    return api.get(`/api/truth-tables/${id}`)
}

// 创建真值表
export function createTruthTable(data) {
    return api.post('/api/truth-tables', data)
}

// 更新真值表
export function updateTruthTable(id, data) {
    return api.put(`/api/truth-tables/${id}`, data)
}

// 删除真值表
export function deleteTruthTable(id) {
    return api.delete(`/api/truth-tables/${id}`)
} 