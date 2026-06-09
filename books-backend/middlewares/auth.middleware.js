// src/middlewares/auth.middleware.js
const jwt = require('jsonwebtoken');
const env = require('../config/env');

module.exports = (req, res, next) => {
    // Lấy token từ header (Thường có dạng: "Bearer eyJhbG...")
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            success: false,
            message: 'Vui lòng đăng nhập để truy cập tài nguyên này'
        });
    }

    // Tách lấy phần mã token
    const token = authHeader.split(' ')[1];

    try {
        // Giải mã token bằng Secret Key
        const decoded = jwt.verify(token, env.jwt.secret_key);

        // Gắn thông tin user (VD: { id: 1, role: 'CUSTOMER' }) vào request
        req.user = decoded;

        // Cho phép request đi tiếp vào Controller
        next();
    } catch (error) {
        let message = 'Token không hợp lệ';
        if (error.name === 'TokenExpiredError') {
            message = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
        }

        return res.status(401).json({
            success: false,
            message: message
        });
    }
};