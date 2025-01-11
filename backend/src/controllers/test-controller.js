const testService = require('../services/test-service')
const logger = require('../utils/logger')

class TestController {
    // 执行测试项
    async executeTest(req, res) {
        try {
            const testItem = req.body
            logger.info('收到测试执行请求:', testItem)

            // 执行测试
            const result = await testService.executeTestItem(testItem)

            // 返回结果
            res.json({
                success: true,
                data: result
            })
        } catch (error) {
            logger.error('测试执行失败:', error)
            res.status(500).json({
                success: false,
                error: error.message
            })
        }
    }
}

module.exports = new TestController() 