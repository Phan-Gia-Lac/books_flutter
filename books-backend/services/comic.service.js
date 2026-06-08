// src/services/comic.service.js
const comicModel = require('../models/comic.model');

/**
 * Lấy danh sách truyện có phân trang và lọc theo thể loại
 */
exports.getComicsList = async ({ limit, offset, categoryId }) => {
    return comicModel.findActiveComics({
        limit,
        offset,
        category_id: categoryId
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
