// src/services/comic.service.js
const comicModel = require('../models/comic.model');

/**
 * Lấy danh sách truyện có phân trang, tìm kiếm, lọc và sắp xếp
 */
exports.getComicsList = async ({
    limit,
    offset,
    categoryId,
    authorId,
    publisherId,
    search,
    searchIds,
    minPrice,
    maxPrice,
    minRating,
    sortBy
}) => {
    return comicModel.findActiveComics({
        limit,
        offset,
        category_id: categoryId,
        author_id: authorId,
        publisher_id: publisherId,
        search,
        searchIds,
        min_price: minPrice,
        max_price: maxPrice,
        min_rating: minRating,
        sort_by: sortBy
    });
};

/**
 * Lấy thông tin chi tiết một cuốn truyện (kèm danh mục)
 */
exports.getComicDetail = async (id) => {
    return comicModel.findByIdWithCategory(id);
};

/**
 * Tạo truyện mới (STAFF & ADMIN)
 */
exports.createNewComic = async (comicData) => {
    return comicModel.createComic(comicData);
};

/**
 * Cập nhật truyện (STAFF & ADMIN)
 */
exports.updateComic = async (id, comicData) => {
    return comicModel.updateComic(id, comicData);
};

/**
 * Xóa truyện (STAFF & ADMIN)
 */
exports.deleteComic = async (id) => {
    return comicModel.deleteComic(id);
};
