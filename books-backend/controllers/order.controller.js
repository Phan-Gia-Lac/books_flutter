// src/controllers/order.controller.js
const orderService = require('../services/order.service');

/**
 * 🛒 [CUSTOMER] Tạo đơn hàng mới
 * POST /api/orders
 */
exports.createOrder = async (req, res, next) => {
    try {
        const customerId = req.user.id; // Lấy từ auth.middleware
        const { items, shipping_address, payment_method } = req.body;

        // items là mảng: [{ comic_id: 1, quantity: 2 }, { comic_id: 3, quantity: 1 }]
        const newOrder = await orderService.placeOrder(customerId, {
            items,
            shipping_address,
            payment_method
        });

        res.status(201).json({
            success: true,
            message: 'Đặt hàng thành công',
            data: newOrder
        });
    } catch (error) {
        next(error);
    }
};

/**
 * 📜 [CUSTOMER] Lịch sử đơn hàng của chính mình
 * GET /api/orders/me
 */
exports.getMyOrders = async (req, res, next) => {
    try {
        const customerId = req.user.id;

        const orders = await orderService.getUserOrders(customerId);

        res.status(200).json({
            success: true,
            message: 'Lấy lịch sử đơn hàng thành công',
            data: orders
        });
    } catch (error) {
        next(error);
    }
};

/**
 * 🛠️ [STAFF / ADMIN] Cập nhật trạng thái đơn hàng (Duyệt đơn, Đang giao...)
 * PATCH /api/orders/:id/status
 */
exports.updateOrderStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const staffId = req.user.id; // Lưu lại ID người duyệt để ghi log nếu cần

        const updatedOrder = await orderService.changeOrderStatus(id, status, staffId);

        res.status(200).json({
            success: true,
            message: `Đã cập nhật trạng thái đơn hàng thành ${status}`,
            data: updatedOrder
        });
    } catch (error) {
        next(error);
    }
};