const mqttService = require('./mqtt-service')
const logger = require('../utils/logger')

class TestMqttService {
    constructor() {
        this.mqttService = mqttService
        this.responseHandlers = new Map()
    }

    // 等待设备响应
    waitForResponse(topic, timeout = 5000) {
        const responseTopic = topic.replace('/command', '/response')
        return new Promise((resolve, reject) => {
            const handler = {
                resolve,
                reject,
                timer: setTimeout(() => {
                    this.responseHandlers.delete(responseTopic)
                    reject(new Error('等待设备响应超时'))
                }, timeout)
            }
            this.responseHandlers.set(responseTopic, handler)
        })
    }

    // 处理设备响应
    handleResponse(topic, payload) {
        const handler = this.responseHandlers.get(topic)
        if (handler) {
            clearTimeout(handler.timer)
            this.responseHandlers.delete(topic)
            handler.resolve(payload)
        }
    }

    // 发送读取命令并等待响应
    async sendReadCommand(projectName, moduleType, serialNumber, channel) {
        try {
            const topic = `${projectName}/${moduleType}/${serialNumber}/${channel}/command`
            const command = { command: 'read' }
            
            logger.info('发送读取命令:', { topic, command })
            
            // 设置等待响应的处理器
            const responsePromise = this.waitForResponse(topic)
            
            // 发送命令
            await this.mqttService.publish(topic, command)
            
            // 等待响应
            const response = await responsePromise
            logger.info('收到读取响应:', response)
            
            return response
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
            
            // 设置等待响应的处理器
            const responsePromise = this.waitForResponse(topic)
            
            // 发送命令
            await this.mqttService.publish(topic, command)
            
            // 等待响应
            const response = await responsePromise
            logger.info('收到写入响应:', response)
            
            return response
        } catch (error) {
            logger.error('发送写入命令失败:', error)
            throw error
        }
    }
}

module.exports = new TestMqttService() 