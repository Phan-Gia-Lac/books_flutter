// src/models/order.model.js
const db = require('../config/db');

const ORDERS_TABLE = 'orders';
const ITEMS_TABLE = 'order_items';

/**
 * Lấy lịch sử đơn hàng của 1 khách hàng kèm danh sách sản phẩm
 */
exports.findByCustomerId = async (customerId) => {
    const orders = await db(ORDERS_TABLE)
        .where({ customer_id: customerId })
        .orderBy('order_date', 'desc');

    // Nạp chi tiết sản phẩm cho từng đơn hàng
    for (let order of orders) {
        order.items = await db(ITEMS_TABLE)
            .join('comics', `${ITEMS_TABLE}.comic_id`, 'comics.id')
            .select(
                `${ITEMS_TABLE}.*`,
                'comics.title as comic_title',
                'comics.cover_image as comic_cover_image'
            )
            .where({ order_id: order.id });
    }

    return orders;
};

/**
 * Tìm đơn hàng theo ID kèm sản phẩm
 */
exports.findById = async (id) => {
    const order = await db(ORDERS_TABLE).where({ id }).first();
    if (!order) return null;

    order.items = await db(ITEMS_TABLE)
        .join('comics', `${ITEMS_TABLE}.comic_id`, 'comics.id')
        .select(
            `${ITEMS_TABLE}.*`,
            'comics.title as comic_title',
            'comics.cover_image as comic_cover_image'
        )
        .where({ order_id: order.id });

    return order;
};

/**
 * Cập nhật trạng thái đơn hàng
 */
exports.updateStatus = async (id, status, staffId, trx = db) => {
    const [updatedOrder] = await trx(ORDERS_TABLE)
        .where({ id })
        .update({
            status,
            staff_id: staffId,
            updated_at: new Date()
        })
        .returning('*');
    return updatedOrder;
};

/**
 * Tạo đơn hàng mới trong transaction
 */
exports.createOrder = async (orderData, items, trx) => {
    // 1. Chèn vào bảng orders
    const [newOrder] = await trx(ORDERS_TABLE).insert(orderData).returning('*');

    // 2. Chèn các items vào bảng order_items
    const orderItems = items.map(item => ({
        order_id: newOrder.id,
        comic_id: item.comic_id,
        quantity: item.quantity,
        price: item.price // Giá lưu tại thời điểm mua
    }));

    await trx(ITEMS_TABLE).insert(orderItems);

    return newOrder;
};
