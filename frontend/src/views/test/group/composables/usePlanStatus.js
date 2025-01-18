export const usePlanStatus = () => {
  const getStatusType = (status) => {
    const types = {
      pending: 'info',
      running: 'warning',
      completed: 'success',
      aborted: 'danger'
    }
    return types[status] || 'info'
  }

  const getStatusText = (status) => {
    const texts = {
      pending: '待执行',
      running: '执行中',
      completed: '已完成',
      aborted: '已中止'
    }
    return texts[status] || '未知'
  }

  const getResultType = (result) => {
    const types = {
      pass: 'success',
      fail: 'danger',
      unknown: 'info'
    }
    return types[result] || 'info'
  }

  const getResultText = (result) => {
    const texts = {
      pass: '通过',
      fail: '失败',
      unknown: '未知'
    }
    return texts[result] || '未知'
  }

  return {
    getStatusType,
    getStatusText,
    getResultType,
    getResultText
  }
} 