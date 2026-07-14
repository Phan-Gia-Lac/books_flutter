const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const auth = require('../middlewares/auth.middleware');
const role = require('../middlewares/role.middleware');

// Áp dụng middleware xác thực và phân quyền cho TẤT CẢ route của Admin
router.use(auth);
router.use(role(['ADMIN'])); // Chỉ cho phép role ADMIN truy cập

// 1. Quản lý sản phẩm (Truyện tranh)
router.post('/comics', adminController.addProduct);      // Thêm sản phẩm
router.delete('/comics/:id', adminController.deleteProduct); // Xóa sản phẩm

// 2. Quản lý đơn hàng
router.get('/orders', adminController.getAllOrders);              // Xem tất cả đơn hàng
router.patch('/orders/:id/status', adminController.approveOrder); // Duyệt đơn hàng / Đổi trạng thái

module.exports = router;