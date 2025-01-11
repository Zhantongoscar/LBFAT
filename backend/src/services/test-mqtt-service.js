const mqttService = require('./mqtt-service')
const logger = require('../utils/logger')

class TestMqttService {
    constructor() {
        this.mqttService = mqttService
    }

    // 发送读取命令并等待响应
    async sendReadCommand(projectName, moduleType, serialNumber, channel) {
        try {
            const topic = `${projectName}/${moduleType}/${serialNumber}/${channel}/command`
            const command = { command: 'read' }
            
            logger.info('发送读取命令:', { topic, command })
            return await this.mqttService.publish(topic, command)
        } catch (error) {
            logger.error('发送读取命令失败:', error)
            throw error
        }
    }

    // 发送写入命令并等待响应
    async sendWriteCommand(projectName, moduleType, serialNumber, channel, value) {
        try {
            const topic = `${projectName}/${moduleType}/${serialNumber}/${channel}/command`
            const command = { 
                command: 'write',
                value: value
            }
            
            logger.info('发送写入命令:', { topic, command })
            return await this.mqttService.publish(topic, command)
        } catch (error) {
            logger.error('发送写入命令失败:', error)
            throw error
        }
    }
}

module.exports = new TestMqttService() 