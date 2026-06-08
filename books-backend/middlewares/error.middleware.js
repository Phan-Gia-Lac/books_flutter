// src/middlewares/error.middleware.js
const env = require('../config/env');

// Express nhận diện đây là Error Middleware vì có đủ 4 tham số (err, req, res, next)
module.exports = (err, req, res, next) => {
    // Log lỗi ra console để dev dễ debug
    console.error('[Global Error]:', err.message);

    const statusCode = err.statusCode || 500;
    let message = err.message || 'Đã có lỗi xảy ra từ phía máy chủ';

    // Bắt một số lỗi đặc thù của Database (PostgreSQL/Knex)
    if (err.code === '23505') {
        // Lỗi Unique Violation của Postgres (VD: Trùng email)
        message = 'Dữ liệu này đã tồn tại trong hệ thống';
        statusCode = 409; // Conflict
    }

    // Trả về JSON chuẩn
    res.status(statusCode).json({
        success: false,
        message: message,
        // Chỉ hiển thị stack trace (đường dẫn file lỗi) khi đang code ở máy local
        stack: env.app.node_env === 'development' ? err.stack : undefined
    });
};