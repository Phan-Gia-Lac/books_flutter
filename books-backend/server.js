// src/server.js
const app = require('./app');
const env = require('./config/env');

const PORT = env.app.port || 3000;

const server = app.listen(PORT, () => {
    console.log(`=========================================`);
    console.log(`🚀 Server đang chạy trên port: ${PORT}`);
    console.log(`   Môi trường: ${env.app.node_env}`);
    console.log(`   API Endpoint: http://localhost:${PORT}/api`);
    console.log(`=========================================`);
});

// CHANGE THIS: Don't kill the server instantly, just log it out!
process.on('unhandledRejection', (err) => {
    console.error('❌ Lỗi Unhandled Rejection CHI TIẾT:');
    console.error(err); // This will print the full stack trace (e.g., Knex connection error)
    // server.close(() => process.exit(1)); <-- Comment this out temporary
});

process.on('SIGTERM', () => {
    console.log('👋 Nhận tín hiệu SIGTERM, đang tắt server...');
    server.close(() => {
        console.log('🔒 Server đã dừng.');
        process.exit(0);
    });
});