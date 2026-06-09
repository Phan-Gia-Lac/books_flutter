// src/config/env.js
require('dotenv').config();

// Gom nhóm các biến môi trường theo từng tính năng
const env = {
    app: {
        port: process.env.PORT || 3000,
        node_env: process.env.NODE_ENV || 'development',
        client_url: process.env.CLIENT_URL || 'http://localhost:3000', // Dành cho CORS
    },
    db: {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || '123456',
        name: process.env.DB_NAME || 'comic_shop',
    },
    jwt: {
        secret_key: process.env.JWT_SECRET_KEY || 'comic_secret_default_key_2026',
        expires_in: process.env.JWT_EXPIRES_IN || '7d', // Token sống 7 ngày
    },
    payment: {
        vnpay: {
            tmn_code: process.env.VNPAY_TMN_CODE,
            hash_secret: process.env.VNPAY_HASH_SECRET,
            url: process.env.VNPAY_URL || 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
            return_url: process.env.VNPAY_RETURN_URL,
        },
        momo: {
            partner_code: process.env.MOMO_PARTNER_CODE,
            access_key: process.env.MOMO_ACCESS_KEY,
            secret_key: process.env.MOMO_SECRET_KEY,
            endpoint: process.env.MOMO_ENDPOINT || 'https://test-payment.momo.vn/v2/gateway/api/create',
        }
    }
};

// Kiểm tra nhanh các biến cực kỳ quan trọng không được phép thiếu
if (!process.env.JWT_SECRET_KEY && env.app.node_env === 'production') {
    console.warn('⚠️ CẢNH BÁO: Chưa cấu hình JWT_SECRET_KEY cho môi trường Production!');
}

module.exports = env;