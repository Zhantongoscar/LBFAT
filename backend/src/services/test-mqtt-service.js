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
            // 检查设备状态
            const deviceStatusTopic = topic.split('/').slice(0, 4).join('/') + '/status'
            let isOffline = false
            
            const handler = {
                resolve,
                reject,
                timer: setTimeout(() => {
                    this.responseHandlers.delete(responseTopic)
                    reject(new Error(isOffline ? '设备离线，无法执行命令' : '测试执行超时'))
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
            
            try {
                // 解析响应数据
                const response = typeof payload === 'string' ? JSON.parse(payload) : payload
                logger.info('解析MQTT响应:', response)
                
                // 检查响应格式
                if (!response || typeof response !== 'object') {
                    throw new Error('无效的响应数据')
                }
                
                // 检查响应状态
                if (response.status !== 'success') {
                    throw new Error(response.error || '执行失败')
                }
                
                // 直接返回响应数据，保持原始格式
                handler.resolve(response)
            } catch (error) {
                logger.error('解析响应数据失败:', error)
                handler.reject(new Error('响应数据格式错误: ' + error.message))
            }
        }
    }

    // 发送读取命令并等待响应
    async sendReadCommand(projectName, moduleType, serialNumber, channel) {
        try {
            const topic = `${projectName}/${moduleType}/${serialNumber}/${channel}/command`
            const command = {
                command: "read",
                value: "0"
            }
            
            logger.info('发送读取命令:', { topic, command })
            
            // 发送命令
            await this.mqttService.publish(topic, command)
            
            // 等待响应
            const responsePromise = this.waitForResponse(topic)
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
                command: "write",
                value: String(value)  // 确保value是字符串
            }
            
            logger.info('发送写入命令:', { topic, command })
            
            // 直接等待响应
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