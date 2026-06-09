const db = require('../config/db');

const TABLE_NAME = 'comics';

// Lấy chi tiết truyện CÓ KÈM tên danh mục
exports.findByIdWithCategory = async (id) => {
    return db(TABLE_NAME)
        .join('categories', `${TABLE_NAME}.category_id`, 'categories.id')
        .select(
            `${TABLE_NAME}.*`, // Lấy tất cả thông tin của truyện
            'categories.name as category_name' // Đổi tên cột name của categories để tránh trùng lặp
        )
        .where(`${TABLE_NAME}.id`, id)
        .andWhere(`${TABLE_NAME}.is_deleted`, false)
        .first();
};

// Dành cho role STAFF/ADMIN thêm truyện mới
exports.createComic = async (comicData) => {
    const [newComic] = await db(TABLE_NAME)
        .insert(comicData)
        .returning('*'); // Trả về data sau khi insert thành công
    return newComic;
};

// Truy vấn danh sách truyện hiển thị cho Customer (không lấy truyện đã ẩn)
exports.findActiveComics = async ({ limit = 10, offset = 0, category_id = null }) => {
    let query = db(TABLE_NAME).where({ status: 'active', is_deleted: false });

    if (category_id) {
        query = query.where({ category_id });
    }

    return query
        .orderBy('created_at', 'desc')
        .limit(limit)
        .offset(offset);
};

exports.findById = async (id) => {
    return db(TABLE_NAME).where({ id, is_deleted: false }).first();
};

// Hàm này thiết kế nhận tham số `trx` (Transaction) từ tầng Service
// Rất quan trọng khi có người đặt hàng để trừ kho an toàn
exports.decrementStock = async (id, quantity, trx = db) => {
    return trx(TABLE_NAME)
        .where({ id })
        // Dùng decrement của knex để tránh race condition khi nhiều người mua cùng lúc
        .decrement('stock_quantity', quantity)
        .returning(['id', 'stock_quantity']);
};