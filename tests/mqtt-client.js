const mqtt = require('mqtt')
const client = mqtt.connect('mqtt://172.29.0.2:1883')

// 设备配置
const deviceConfig = {
    projectName: 'lb_test',
    moduleType: 'EDB',
    serialNumber: '4'
}

// 构建主题
const statusTopic = `${deviceConfig.projectName}/${deviceConfig.moduleType}/${deviceConfig.serialNumber}/status`

// 在线状态消息
const onlineMessage = {
    status: 'online',
    rssi: -71
}

// 离线状态消息（遗嘱消息）
const offlineMessage = {
    status: 'offline',
    rssi: 0
}

// 连接成功回调
client.on('connect', () => {
    console.log('Connected to MQTT broker')

    // 设置遗嘱消息
    client.publish(statusTopic, JSON.stringify(offlineMessage), { retain: true })

    // 发布在线状态
    client.publish(statusTopic, JSON.stringify(onlineMessage))
    console.log('Published online status')

    // 每60秒发送一次在线状态
    setInterval(() => {
        // 随机生成-100到-40之间的RSSI值
        const rssi = Math.floor(Math.random() * 60) - 100
        const message = {
            status: 'online',
            rssi: rssi
        }
        client.publish(statusTopic, JSON.stringify(message))
        console.log('Published status update:', message)
    }, 60000)
})

// 错误处理
client.on('error', (error) => {
    console.error('MQTT error:', error)
})

// 处理程序退出
process.on('SIGINT', () => {
    console.log('Publishing offline status and disconnecting...')
    client.publish(statusTopic, JSON.stringify(offlineMessage), { retain: true }, () => {
        client.end()
        process.exit()
    })
})

// 添加命令行交互
const readline = require('readline')
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})

console.log('\nCommands:')
console.log('1: Publish online status')
console.log('2: Publish offline status')
console.log('3: Update RSSI')
console.log('q: Quit')

rl.on('line', (input) => {
    switch (input.trim()) {
        case '1':
            client.publish(statusTopic, JSON.stringify(onlineMessage))
            console.log('Published online status')
            break
        case '2':
            client.publish(statusTopic, JSON.stringify(offlineMessage))
            console.log('Published offline status')
            break
        case '3':
            const rssi = Math.floor(Math.random() * 60) - 100
            const message = {
                status: 'online',
                rssi: rssi
            }
            client.publish(statusTopic, JSON.stringify(message))
            console.log('Published status update:', message)
            break
        case 'q':
            console.log('Publishing offline status and disconnecting...')
            client.publish(statusTopic, JSON.stringify(offlineMessage), { retain: true }, () => {
                client.end()
                process.exit()
            })
            break
        default:
            console.log('Unknown command')
    }
}) 