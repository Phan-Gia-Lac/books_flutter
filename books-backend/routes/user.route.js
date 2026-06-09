// src/routes/user.route.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const auth = require('../middlewares/auth.middleware');
const role = require('../middlewares/role.middleware');

// [CUSTOMER & STAFF & ADMIN] Xem và cập nhật hồ sơ cá nhân
router.get('/me', auth, userController.getProfile);
router.put('/me', auth, userController.updateProfile);

// [ADMIN ONLY] Quản lý toàn bộ người dùng hệ thống
router.get('/', auth, role(['ADMIN']), userController.getAllUsers);
router.patch('/:id/status', auth, role(['ADMIN']), userController.toggleUserStatus); // Khóa/Mở khóa tài khoản

module.exports = router;