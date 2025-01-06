import { ref } from 'vue'

// WebSocket 状态常量
const WS_STATES = {
    CONNECTING: 0,
    OPEN: 1,
    CLOSING: 2,
    CLOSED: 3
}

// 全局状态变量
const ws = ref(null)
const isConnected = ref(false)
const messageListeners = new Set()

// 创建单例WebSocket实例
function createWebSocket() {
    if (!ws.value || ws.value.readyState === WS_STATES.CLOSED) {
        const wsUrl = import.meta.env.VITE_WS_URL || 'ws://localhost:3000'
        console.log('正在连接WebSocket:', wsUrl)
        ws.value = new WebSocket(wsUrl)

        ws.value.addEventListener('open', () => {
            console.log('WebSocket连接已建立')
            isConnected.value = true
        })

        ws.value.addEventListener('close', () => {
            console.log('WebSocket连接已关闭，5秒后重试')
            isConnected.value = false
            setTimeout(createWebSocket, 5000)
        })

        ws.value.addEventListener('error', (error) => {
            console.error('WebSocket错误:', error)
            isConnected.value = false
        })

        // 添加消息处理器
        ws.value.addEventListener('message', (event) => {
            messageListeners.forEach(listener => {
                try {
                    listener(event)
                } catch (error) {
                    console.error('消息监听器执行失败:', error)
                }
            })
        })
    }
    return ws.value
}

// 初始化WebSocket连接
createWebSocket()

export function useWebSocket() {
    const addMessageListener = (listener) => {
        messageListeners.add(listener)
        console.log('添加消息监听器，当前监听器数量:', messageListeners.size)
    }

    const removeMessageListener = (listener) => {
        messageListeners.delete(listener)
        console.log('移除消息监听器，当前监听器数量:', messageListeners.size)
    }

    const cleanup = () => {
        messageListeners.clear()
        if (ws.value) {
            ws.value.close()
            ws.value = null
        }
        isConnected.value = false
    }

    return {
        ws,
        isConnected,
        addMessageListener,
        removeMessageListener,
        cleanup
    }
} 