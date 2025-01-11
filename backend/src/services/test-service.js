const mqttService = require('./mqtt-service')
const logger = require('../utils/logger')

class TestService {
    constructor() {
        this.mqttService = mqttService
    }

    // 执行单个测试项
    async executeTestItem(testItem) {
        try {
            logger.info('开始执行测试项:', testItem)

            // 构造设备ID
            const deviceId = `${testItem.project_name}/${testItem.module_type}/${testItem.serial_number}`
            
            // 根据类型执行测试
            if (testItem.type === 'DI' || testItem.type === 'AI') {
                return await this.executeInputTest(deviceId, testItem)
            } else if (testItem.type === 'DO' || testItem.type === 'AO') {
                return await this.executeOutputTest(deviceId, testItem)
            }
        } catch (error) {
            logger.error('测试项执行失败:', error)
            throw error
        }
    }

    // 执行输入测试
    async executeInputTest(deviceId, testItem) {
        // 发送读取命令
        const topic = `${deviceId}/${testItem.channel}/command`
        const command = { command: 'read' }

        // 发送命令并等待响应
        const response = await this.mqttService.publish(topic, command)
        
        // 记录结果
        return {
            actualValue: response.value,
            status: response.status,
            passed: this.compareValue(response.value, testItem.expectedValue, testItem.tolerance)
        }
    }

    // 执行输出测试
    async executeOutputTest(deviceId, testItem) {
        // 1. 发送写入命令
        const topic = `${deviceId}/${testItem.channel}/command`
        const command = { 
            command: 'write',
            value: testItem.expectedValue
        }

        // 发送写入命令
        const writeResponse = await this.mqttService.publish(topic, command)
        if (writeResponse.status !== 'success') {
            return {
                status: 'failed',
                error: '写入失败'
            }
        }

        // 2. 读取验证
        const readCommand = { command: 'read' }
        const readResponse = await this.mqttService.publish(topic, readCommand)

        // 3. 比对结果
        return {
            actualValue: readResponse.value,
            status: readResponse.status,
            passed: this.compareValue(readResponse.value, testItem.expectedValue, testItem.tolerance)
        }
    }

    // 比对值
    compareValue(actual, expected, tolerance = 0) {
        if (typeof actual === 'number' && typeof expected === 'number') {
            return Math.abs(actual - expected) <= tolerance
        }
        return actual === expected
    }
}

module.exports = new TestService() 