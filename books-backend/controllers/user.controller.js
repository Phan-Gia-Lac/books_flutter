// src/controllers/user.controller.js
const userModel = require('../models/user.model');

/**
 * 👤 Get personal profile
 * GET /api/users/me
 */
exports.getProfile = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const user = await userModel.findById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy người dùng này'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Lấy thông tin cá nhân thành công',
            data: user
        });
    } catch (error) {
        next(error);
    }
};

/**
 * 👤 Update personal profile
 * PUT /api/users/me
 */
exports.updateProfile = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { full_name, phone_number } = req.body;

        // Chỉ cho phép update tên và số điện thoại từ body
        const updatedUser = await userModel.updateUser(userId, {
            full_name,
            phone_number,
            updated_at: new Date()
        });

        // Ẩn password trước khi trả về
        if (updatedUser) {
            delete updatedUser.password;
        }

        res.status(200).json({
            success: true,
            message: 'Cập nhật thông tin cá nhân thành công',
            data: updatedUser
        });
    } catch (error) {
        next(error);
    }
};

/**
 * 👑 [ADMIN ONLY] Get all users
 * GET /api/users
 */
exports.getAllUsers = async (req, res, next) => {
    try {
        const users = await userModel.findAll();

        res.status(200).json({
            success: true,
            message: 'Lấy danh sách người dùng thành công',
            data: users
        });
    } catch (error) {
        next(error);
    }
};

/**
 * 👑 [ADMIN ONLY] Block/Unblock user account (toggle is_deleted status)
 * PATCH /api/users/:id/status
 */
exports.toggleUserStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        
        // Tìm user trước
        const user = await userModel.findById(id);
        if (!user) {
            // Xem thêm trường hợp user bị is_deleted = true nhưng admin vẫn muốn unlock
            // Nên query trực tiếp từ db để tìm bất kể trạng thái is_deleted
            const rawUser = await require('../config/db')('users').where({ id }).first();
            if (!rawUser) {
                return res.status(404).json({
                    success: false,
                    message: 'Không tìm thấy người dùng này'
                });
            }
            // Toggle từ true -> false
            const updatedUser = await userModel.updateUser(id, { is_deleted: false, updated_at: new Date() });
            delete updatedUser.password;
            return res.status(200).json({
                success: true,
                message: 'Đã mở khóa tài khoản thành công',
                data: updatedUser
            });
        }

        // Toggle từ false -> true (Khóa)
        const updatedUser = await userModel.updateUser(id, { is_deleted: true, updated_at: new Date() });
        delete updatedUser.password;

        res.status(200).json({
            success: true,
            message: 'Đã khóa tài khoản thành công',
            data: updatedUser
        });
    } catch (error) {
        next(error);
    }
};
