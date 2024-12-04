const WebSocket = require('ws');
const logger = require('../utils/logger');

class WebSocketService {
    constructor() {
        this.wss = null;
        this.clients = new Set();
    }

    initialize(server) {
        this.wss = new WebSocket.Server({ server });

        this.wss.on('connection', (ws) => {
            logger.info('New WebSocket client connected');
            this.clients.add(ws);

            ws.on('close', () => {
                logger.info('WebSocket client disconnected');
                this.clients.delete(ws);
            });

            ws.on('error', (error) => {
                logger.error('WebSocket error:', error);
            });
        });
    }

    broadcast(message) {
        this.clients.forEach((client) => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify(message));
            }
        });
    }
}

module.exports = new WebSocketService(); 