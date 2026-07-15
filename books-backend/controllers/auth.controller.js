// src/controllers/auth.controller.js
const authService = require('../services/auth.service');

/**
 * Đăng ký tài khoản dành riêng cho Khách hàng (Customer)
 * POST /api/auth/register
 */
exports.register = async (req, res, next) => {
    try {
        const { email, password, full_name } = req.body;

        // Toàn bộ logic kiểm tra email trùng, băm password, và lưu DB nằm ở Service
        const newUser = await authService.registerCustomer({ email, password, full_name });

        res.status(201).json({
            success: true,
            message: 'Đăng ký tài khoản thành công',
            data: newUser
        });
    } catch (error) {
        // Nếu lỗi (vd: Email đã tồn tại), đẩy sang error.middleware.js xử lý
        next(error);
    }
};

/**
 * Đăng nhập chung cho cả 3 Roles (Customer, Staff, Admin)
 * POST /api/auth/login
 */
exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        const result = await authService.authenticateUser(email, password);

        if (result.requires2FA) {
            return res.status(200).json({
                success: true,
                message: 'Vui lòng kiểm tra email để lấy mã OTP',
                data: result
            });
        }

        // Trường hợp không cần OTP (đã cache hoặc là ADMIN)
        res.status(200).json({
            success: true,
            message: 'Đăng nhập thành công',
            data: result // { requires2FA: false, user, accessToken }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Xác thực mã OTP và cấp Token
 * POST /api/auth/verify-otp
 */
exports.verifyOtp = async (req, res, next) => {
    try {
        const { email, otp } = req.body;

        if (!email || !otp) {
            return res.status(400).json({
                success: false,
                message: 'Vui lòng cung cấp email và mã OTP'
            });
        }

        // Service sẽ kiểm tra OTP, nếu đúng thì cấp JWT Token
        const { user, accessToken } = await authService.verifyOTPAndLogin(email, otp);

        res.status(200).json({
            success: true,
            message: 'Đăng nhập và xác thực thành công',
            data: {
                user,
                accessToken // App di động sẽ lưu token này vào Flutter Secure Storage
            }
        });
    } catch (error) {
        next(error);
    }
};