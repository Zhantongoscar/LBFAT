// 创建新的测试实例
export const createNewInstance = (data) => {
  return request({
    url: '/test/instances',
    method: 'post',
    data
  })
} 