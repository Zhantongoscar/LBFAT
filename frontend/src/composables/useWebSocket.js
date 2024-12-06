import { ref } from 'vue'

// WebSocket 状态常量
const WS_STATES = {
    CONNECTING: 0,
    OPEN: 1,
    CLOSING: 2,
    CLOSED: 3
}

// 状态变量
const ws = ref(null)
const isConnected = ref(false)

export function useWebSocket() {
    const connect = () => {
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
                setTimeout(connect, 5000)
            })

            ws.value.addEventListener('error', (error) => {
                console.error('WebSocket错误:', error)
                isConnected.value = false
            })
        }
    }

    const cleanup = () => {
        if (ws.value) {
            ws.value.close()
            ws.value = null
        }
        isConnected.value = false
    }

    // 初始连接
    connect()
    
    return {
        ws,
        isConnected,
        cleanup
    }
} 