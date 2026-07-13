// src/services/auth.service.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userModel = require('../models/user.model');
const env = require('../config/env');
const mailer = require('../mailer');

// Biến lưu trữ OTP tạm thời trên RAM: email -> { otp, expiresAt, user }
const otpCache = new Map();

exports.registerCustomer = async (userData) => {
    // 1. Kiểm tra email đã tồn tại chưa
    const existingUser = await userModel.findByEmail(userData.email);
    if (existingUser) {
        const error = new Error('Email này đã được sử dụng');
        error.statusCode = 409; // Conflict
        throw error;
    }

    // 2. Băm mật khẩu (Salt rounds: 10 là mức chuẩn hiện tại)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(userData.password, salt);

    // 3. Lưu vào database (mặc định role là CUSTOMER như đã setup ở migration)
    const newUser = await userModel.createUser({
        ...userData,
        password: hashedPassword,
    });

    // Xóa password trước khi trả về cho Controller
    delete newUser.password;
    return newUser;
};

exports.authenticateUser = async (email, password) => {
    // 1. Tìm user theo email
    const user = await userModel.findByEmail(email);
    if (!user) {
        const error = new Error('Email hoặc mật khẩu không chính xác');
        error.statusCode = 401; // Unauthorized
        throw error;
    }

    // 2. So sánh mật khẩu
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
        const error = new Error('Email hoặc mật khẩu không chính xác');
        error.statusCode = 401;
        throw error;
    }

    // Xóa password khỏi object để an toàn
    delete user.password;

    // 3. Nếu là ADMIN thì không cần OTP, cấp token và đăng nhập luôn
    if (user.role === 'ADMIN') {
        const payload = { id: user.id, role: user.role };
        const accessToken = jwt.sign(payload, env.jwt.secret_key, {
            expiresIn: env.jwt.expires_in,
        });
        return { requires2FA: false, user, accessToken };
    }

    // 4. Tạo mã OTP ngẫu nhiên 6 chữ số
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

    // 5. Lưu vào bộ nhớ tạm (hết hạn sau 5 phút)
    otpCache.set(user.email, {
        otp: otpCode,
        expiresAt: Date.now() + 5 * 60 * 1000,
        user: user // Lưu tạm user để sau này tạo Token không cần query lại DB
    });

    // 6. Gửi email
    await mailer.sendOTP(user.email, otpCode);
    // await mailer.sendOTP(user.email, otpCode);
    // [DEV MODE]: Bắt buộc gửi tất cả OTP về email thật của bạn (phanphuongphi@gmail.com) 
    // thay vì gửi vào các email giả (như an.nguyen@gmail.com) để bạn dễ test mọi tài khoản.
    // const testEmail = "phanphuongphi@gmail.com"; // có thể thay đổi testEmail khác khi debug  

    // Vẫn trả về email ảo cho Frontend để Frontend biết đang đăng nhập tài khoản nào
    return { requires2FA: true, email: user.email, role: user.role };
};

exports.verifyOTPAndLogin = async (email, otpCode) => {
    const cachedData = otpCache.get(email);

    // 1. Kiểm tra mã có tồn tại không
    if (!cachedData) {
        const error = new Error('Mã OTP không hợp lệ hoặc đã hết hạn (phiên không tồn tại)');
        error.statusCode = 401;
        throw error;
    }

    // 2. Kiểm tra thời gian hết hạn
    if (Date.now() > cachedData.expiresAt) {
        otpCache.delete(email);
        const error = new Error('Mã OTP đã hết hạn. Vui lòng đăng nhập lại.');
        error.statusCode = 401;
        throw error;
    }

    // 3. Kiểm tra mã OTP
    if (cachedData.otp !== otpCode) {
        const error = new Error('Mã OTP không chính xác');
        error.statusCode = 401;
        throw error;
    }

    // 4. Mã hợp lệ -> Tạo JWT Token
    const user = cachedData.user;
    const payload = { id: user.id, role: user.role };
    const accessToken = jwt.sign(payload, env.jwt.secret_key, {
        expiresIn: env.jwt.expires_in,
    });

    // Xóa cache vì đã sử dụng xong
    otpCache.delete(email);

    return { user, accessToken };
};