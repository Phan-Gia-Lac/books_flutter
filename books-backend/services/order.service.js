// src/services/order.service.js
const db = require('../config/db');
const orderModel = require('../models/order.model');
const comicModel = require('../models/comic.model');

/**
 * 🛒 Đặt hàng mới
 * Sử dụng Database Transaction để đảm bảo tính toàn vẹn (tránh race condition khi decrement stock)
 */
exports.placeOrder = async (customerId, { items, shipping_address, payment_method }) => {
    // items: [{ comic_id: 1, quantity: 2 }, ...]
    if (!items || items.length === 0) {
        const error = new Error('Đơn hàng phải có ít nhất 1 sản phẩm');
        error.statusCode = 400;
        throw error;
    }

    // Chạy trong transaction
    return db.transaction(async (trx) => {
        let totalAmount = 0;
        const processedItems = [];

        // 1. Kiểm tra tồn kho và tính tổng tiền dựa trên giá trong DB
        for (let item of items) {
            // Lấy thông tin truyện mới nhất từ DB
            const comic = await comicModel.findById(item.comic_id);
            if (!comic) {
                const error = new Error(`Không tìm thấy truyện với ID ${item.comic_id}`);
                error.statusCode = 404;
                throw error;
            }

            if (comic.stock_quantity < item.quantity) {
                const error = new Error(`Truyện "${comic.title}" không đủ hàng trong kho (Còn lại: ${comic.stock_quantity})`);
                error.statusCode = 400;
                throw error;
            }

            // Trừ kho (decrement) sử dụng transaction
            await comicModel.decrementStock(item.comic_id, item.quantity, trx);

            const itemTotalPrice = comic.price * item.quantity;
            totalAmount += itemTotalPrice;

            // Ghi nhận thông tin chi tiết item để insert
            processedItems.push({
                comic_id: item.comic_id,
                quantity: item.quantity,
                price: comic.price // lưu giá thực tế lúc mua
            });
        }

        // 2. Tạo bản ghi đơn hàng chính
        const orderData = {
            customer_id: customerId,
            total_amount: totalAmount,
            status: 'pending',
            shipping_address,
            payment_method
        };

        const newOrder = await orderModel.createOrder(orderData, processedItems, trx);
        
        // Trả về order kèm items
        newOrder.items = processedItems;
        return newOrder;
    });
};

/**
 * Lấy lịch sử đơn hàng của khách hàng
 */
exports.getUserOrders = async (customerId) => {
    return orderModel.findByCustomerId(customerId);
};

/**
 * Cập nhật trạng thái đơn hàng (STAFF/ADMIN)
 */
exports.changeOrderStatus = async (orderId, status, staffId) => {
    // Kiểm tra đơn hàng có tồn tại không
    const order = await orderModel.findById(orderId);
    if (!order) {
        const error = new Error('Không tìm thấy đơn hàng này');
        error.statusCode = 404;
        throw error;
    }

    // Các trạng thái hợp lệ
    const validStatuses = ['pending', 'processing', 'shipped', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
        const error = new Error('Trạng thái đơn hàng không hợp lệ');
        error.statusCode = 400;
        throw error;
    }

    return orderModel.updateStatus(orderId, status, staffId);
};
