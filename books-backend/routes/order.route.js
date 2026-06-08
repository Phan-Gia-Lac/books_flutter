// src/routes/order.route.js
const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const auth = require('../middlewares/auth.middleware');
const role = require('../middlewares/role.middleware');

// [CUSTOMER] Người dùng đăng nhập tạo đơn hàng
router.post('/', auth, orderController.createOrder);

// [CUSTOMER] Người dùng xem lịch sử đơn hàng của chính mình
router.get('/me', auth, orderController.getMyOrders);

// [STAFF & ADMIN] Cập nhật trạng thái đơn (duyệt, giao hàng, hoàn thành...)
router.patch('/:id/status', auth, role(['STAFF', 'ADMIN']), orderController.updateOrderStatus);

// [STAFF & ADMIN] Lấy danh sách toàn bộ đơn hàng của hệ thống (Bạn có thể thêm sau)
// router.get('/', auth, role(['STAFF', 'ADMIN']), orderController.getAllOrders);

module.exports = router;