import { defineStore } from 'pinia'
import { ref } from 'vue'
import { 
  getTestInstances, 
  createTestInstance, 
  deleteTestInstance,
  startTest,
  abortTest,
  updateTestGroupEnable as updateGroupEnable
} from '@/api/testInstance'

export const useTestInstanceStore = defineStore('testInstance', () => {
  const testInstances = ref([])
  const selectedInstance = ref(null)
  const loading = ref(false)

  // 获取测试实例列表
  const fetchTestInstances = async () => {
    try {
      loading.value = true
      const data = await getTestInstances()
      testInstances.value = data
    } catch (error) {
      console.error('获取测试实例失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 创建测试实例
  const createInstance = async (instanceData) => {
    try {
      loading.value = true
      const data = await createTestInstance(instanceData)
      await fetchTestInstances()
      return data
    } catch (error) {
      console.error('创建测试实例失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 删除测试实例
  const deleteInstance = async (instanceId) => {
    try {
      loading.value = true
      await deleteTestInstance(instanceId)
      await fetchTestInstances()
    } catch (error) {
      console.error('删除测试实例失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 开始测试实例
  const startTestInstance = async (instanceId) => {
    try {
      loading.value = true
      await startTest(instanceId)
      await fetchTestInstances()
    } catch (error) {
      console.error('开始测试失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 中止测试实例
  const abortTestInstance = async (instanceId) => {
    try {
      loading.value = true
      await abortTest(instanceId)
      await fetchTestInstances()
    } catch (error) {
      console.error('中止测试失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 更新测试组启用状态
  const updateTestGroupEnable = async (groupId, enable) => {
    try {
      loading.value = true
      await updateGroupEnable(groupId, enable)
    } catch (error) {
      console.error('更新测试组状态失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  return {
    testInstances,
    selectedInstance,
    loading,
    fetchTestInstances,
    createInstance,
    deleteInstance,
    startTestInstance,
    abortTestInstance,
    updateTestGroupEnable
  }
}) 