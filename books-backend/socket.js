// src/socket.js
const { Server } = require('socket.io');

let io;

module.exports = {
    init: (httpServer) => {
        io = new Server(httpServer, {
            cors: {
                origin: "*", // Allow all origins for simplicity in development
                methods: ["GET", "POST", "PUT", "PATCH", "DELETE"]
            }
        });

        io.on('connection', (socket) => {
            console.log(`⚡ Client connected: ${socket.id}`);

            socket.on('disconnect', () => {
                console.log(`🔌 Client disconnected: ${socket.id}`);
            });
        });

        return io;
    },
    getIO: () => {
        if (!io) {
            throw new Error('Socket.io not initialized!');
        }
        return io;
    }
};
