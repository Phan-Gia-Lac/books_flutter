// src/services/auth.service.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userModel = require('../models/user.model');
const env = require('../config/env');

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

    // 3. Tạo JWT Token chứa id và role
    const payload = { id: user.id, role: user.role };
    const accessToken = jwt.sign(payload, env.jwt.secret_key, {
        expiresIn: env.jwt.expires_in,
    });

    // Xóa password khỏi object trả về
    delete user.password;

    return { user, accessToken };
};