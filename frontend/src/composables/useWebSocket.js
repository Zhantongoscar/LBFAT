import { ref, onUnmounted } from 'vue'
import { useDeviceStore } from '../store/device'
import { ElMessage } from 'element-plus'

export function useWebSocket() {
    const ws = ref(null)
    const deviceStore = useDeviceStore()
    const wsUrl = import.meta.env.VITE_WS_URL || 'ws://localhost:3000/ws'
    const isConnected = ref(false)
    const reconnectAttempts = ref(0)
    const maxReconnectAttempts = 5
    const reconnectTimeout = ref(null)

    const connect = () => {
        if (ws.value?.readyState === WebSocket.OPEN) {
            return
        }

        ws.value = new WebSocket(wsUrl)

        ws.value.onopen = () => {
            console.log('WebSocket connected')
            isConnected.value = true
            reconnectAttempts.value = 0
            ElMessage.success('实时连接已建立')
        }

        ws.value.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data)
                handleMessage(data)
            } catch (error) {
                console.error('Error handling WebSocket message:', error)
            }
        }

        ws.value.onclose = () => {
            console.log('WebSocket disconnected')
            isConnected.value = false
            ElMessage.warning('实时连接已断开')
            attemptReconnect()
        }

        ws.value.onerror = (error) => {
            console.error('WebSocket error:', error)
            isConnected.value = false
        }
    }

    const handleMessage = (data) => {
        switch (data.type) {
            case 'connection':
                console.log('Connection message:', data.message)
                break
            case 'device_status':
                deviceStore.updateDeviceStatus(data.device)
                break
            default:
                console.warn('Unknown message type:', data.type)
        }
    }

    const attemptReconnect = () => {
        if (reconnectAttempts.value >= maxReconnectAttempts) {
            ElMessage.error('无法建立实时连接，请刷新页面重试')
            return
        }

        reconnectAttempts.value++
        const delay = Math.min(1000 * Math.pow(2, reconnectAttempts.value), 10000)

        reconnectTimeout.value = setTimeout(() => {
            console.log(`Attempting to reconnect... (${reconnectAttempts.value}/${maxReconnectAttempts})`)
            connect()
        }, delay)
    }

    const subscribeToProject = (projectName) => {
        if (ws.value?.readyState === WebSocket.OPEN) {
            ws.value.send(JSON.stringify({
                type: 'subscribe',
                projectName
            }))
        }
    }

    const disconnect = () => {
        if (reconnectTimeout.value) {
            clearTimeout(reconnectTimeout.value)
            reconnectTimeout.value = null
        }

        if (ws.value) {
            ws.value.close()
            ws.value = null
        }

        isConnected.value = false
    }

    // 组件卸载时自动断开连接
    onUnmounted(() => {
        disconnect()
    })

    return {
        connect,
        disconnect,
        subscribeToProject,
        isConnected
    }
} 