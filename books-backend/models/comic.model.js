const db = require('../config/db');

const TABLE_NAME = 'comics';

// Lấy chi tiết truyện CÓ KÈM tên danh mục
exports.findByIdWithCategory = async (id) => {
    return db(TABLE_NAME)
        .join('categories', `${TABLE_NAME}.category_id`, 'categories.id')
        .select(
            `${TABLE_NAME}.*`, // Lấy tất cả thông tin của truyện
            'categories.name as category_name', // Đổi tên cột name của categories để tránh trùng lặp
            db.raw('CAST(ROUND(COALESCE((SELECT AVG(rating) FROM reviews WHERE reviews.comic_id = comics.id), 0), 1) AS float) as rating')
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
exports.findActiveComics = async ({
    limit = 10,
    offset = 0,
    category_id = null,
    author_id = null,
    publisher_id = null,
    search = '',
    min_price = null,
    max_price = null,
    min_rating = null,
    sort_by = 'newest'
}) => {
    let query = db(TABLE_NAME)
        .where(`${TABLE_NAME}.status`, 'active')
        .andWhere(`${TABLE_NAME}.is_deleted`, false);

    if (category_id) {
        query = query.where(`${TABLE_NAME}.category_id`, category_id);
    }
    if (author_id) {
        query = query.where(`${TABLE_NAME}.author_id`, author_id);
    }
    if (publisher_id) {
        query = query.where(`${TABLE_NAME}.publisher_id`, publisher_id);
    }
    if (search) {
        query = query.where(`${TABLE_NAME}.title`, 'ilike', `%${search}%`);
    }
    if (min_price !== null && min_price !== undefined) {
        query = query.where(`${TABLE_NAME}.price`, '>=', min_price);
    }
    if (max_price !== null && max_price !== undefined) {
        query = query.where(`${TABLE_NAME}.price`, '<=', max_price);
    }
    if (min_rating !== null && min_rating !== undefined) {
        query = query.where(
            db.raw('COALESCE((SELECT AVG(rating) FROM reviews WHERE reviews.comic_id = comics.id), 0)'),
            '>=',
            min_rating
        );
    }

    // Lấy tổng số lượng kết quả phù hợp trước khi thực hiện join và pagination
    const countQuery = query.clone();
    const [{ count }] = await countQuery.count(`${TABLE_NAME}.id as count`);
    const totalItems = parseInt(count, 10);

    // Join thêm thông tin thể loại, tác giả, nhà xuất bản để trả về kết quả đầy đủ
    query = query
        .leftJoin('categories', `${TABLE_NAME}.category_id`, 'categories.id')
        .leftJoin('authors', `${TABLE_NAME}.author_id`, 'authors.id')
        .leftJoin('publishers', `${TABLE_NAME}.publisher_id`, 'publishers.id')
        .select(
            `${TABLE_NAME}.*`,
            'categories.name as category_name',
            'authors.name as author_name',
            'publishers.name as publisher_name',
            db.raw('CAST(ROUND(COALESCE((SELECT AVG(rating) FROM reviews WHERE reviews.comic_id = comics.id), 0), 1) AS float) as rating')
        );

    // Áp dụng sắp xếp
    if (sort_by === 'price_asc') {
        query = query.orderBy(`${TABLE_NAME}.price`, 'asc');
    } else if (sort_by === 'price_desc') {
        query = query.orderBy(`${TABLE_NAME}.price`, 'desc');
    } else if (sort_by === 'title_asc') {
        query = query.orderBy(`${TABLE_NAME}.title`, 'asc');
    } else if (sort_by === 'title_desc') {
        query = query.orderBy(`${TABLE_NAME}.title`, 'desc');
    } else if (sort_by === 'rating_desc') {
        query = query.orderByRaw('COALESCE((SELECT AVG(rating) FROM reviews WHERE reviews.comic_id = comics.id), 0) DESC');
    } else {
        // Mặc định: Mới nhất
        query = query.orderBy(`${TABLE_NAME}.created_at`, 'desc');
    }

    const comics = await query
        .limit(limit)
        .offset(offset);

    return { comics, totalItems };
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