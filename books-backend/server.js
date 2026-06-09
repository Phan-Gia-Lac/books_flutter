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

// Xử lý các sự kiện tắt server không mong muốn để đóng kết nối DB an toàn nếu cần
process.on('unhandledRejection', (err) => {
    console.error('❌ Lỗi Unhandled Rejection:', err);
    server.close(() => process.exit(1));
});

process.on('SIGTERM', () => {
    console.log('👋 Nhận tín hiệu SIGTERM, đang tắt server...');
    server.close(() => {
        console.log('🔒 Server đã dừng.');
        process.exit(0);
    });
});
