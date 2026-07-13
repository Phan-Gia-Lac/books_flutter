// src/controllers/comic.controller.js
const db = require('../config/db');
const comicService = require('../services/comic.service');
const { searchComics: searchVectorComics, upsertComicData } = require('../services/search-model');
const io = require('../socket');

/**
 * Lấy danh sách truyện đang bán (Dành cho Customer)
 * Hỗ trợ phân trang và lọc theo thể loại
 * GET /api/comics?page=1&limit=10&category=2
 */
exports.getAllComics = async (req, res, next) => {
    try {
        // Lấy query parameters từ URL, thiết lập giá trị mặc định nếu không có
        const page = req.query.page && !isNaN(parseInt(req.query.page)) ? parseInt(req.query.page) : 1;
        const limit = req.query.limit && !isNaN(parseInt(req.query.limit)) ? parseInt(req.query.limit) : 10;
        const categoryId = req.query.category && !isNaN(parseInt(req.query.category)) ? parseInt(req.query.category) : null;
        const authorId = req.query.author && !isNaN(parseInt(req.query.author)) ? parseInt(req.query.author) : null;
        const publisherId = req.query.publisher && !isNaN(parseInt(req.query.publisher)) ? parseInt(req.query.publisher) : null;
        const search = req.query.search || '';
        const minPrice = req.query.min_price && !isNaN(parseInt(req.query.min_price)) ? parseInt(req.query.min_price) : null;
        const maxPrice = req.query.max_price && !isNaN(parseInt(req.query.max_price)) ? parseInt(req.query.max_price) : null;
        const minRating = req.query.min_rating && !isNaN(parseFloat(req.query.min_rating)) ? parseFloat(req.query.min_rating) : null;
        const sortBy = req.query.sort_by || 'newest';

        const offset = (page - 1) * limit;

        // Service sẽ gọi database thông qua Model
        const { comics, totalItems } = await comicService.getComicsList({
            limit,
            offset,
            categoryId,
            authorId,
            publisherId,
            search,
            minPrice,
            maxPrice,
            minRating,
            sortBy
        });

        res.status(200).json({
            success: true,
            message: 'Lấy danh sách truyện thành công',
            data: comics,
            meta: {
                current_page: page,
                items_per_page: limit,
                total_items: totalItems,
                total_pages: Math.ceil(totalItems / limit)
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Xem chi tiết một cuốn truyện
 * GET /api/comics/:id
 */
exports.getComicById = async (req, res, next) => {
    try {
        const { id } = req.params;

        const comic = await comicService.getComicDetail(id);

        if (!comic) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy truyện tranh này'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Lấy thông tin truyện thành công',
            data: comic
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Thêm truyện mới (Chỉ dành cho Role: STAFF hoặc ADMIN)
 * POST /api/comics
 */
exports.createComic = async (req, res, next) => {
    try {
        // Lấy toàn bộ thông tin truyện từ body request
        const comicData = req.body;

        // Nếu hệ thống có upload ảnh bìa (cover_image) qua form-data,
        // thông thường URL ảnh đã được middleware (như Multer + Cloudinary) 
        // xử lý và gắn vào req.file.path. Ta có thể map nó vào comicData ở đây.
        if (req.file) {
            comicData.cover_image = req.file.path;
        }

        const newComic = await comicService.createNewComic(comicData);

        // Upsert the comic data to Pinecone
        await upsertComicData([newComic]);

        // Real-time: Notify all clients that a new comic has been created
        try {
            io.getIO().emit('COMIC_CREATED', newComic);
        } catch (socketErr) {
            console.error('Socket emission failed:', socketErr);
        }

        res.status(201).json({
            success: true,
            message: 'Thêm truyện tranh mới thành công',
            data: newComic
        });
    } catch (error) {
        next(error);
    }
};



exports.searchComics = async (req, res) => {
    const { q } = req.query;

    if (!q || q.trim() === '') {
        return res.status(400).json({ error: 'Query is required' });
    }

    try {
        const page = req.query.page && !isNaN(parseInt(req.query.page)) ? parseInt(req.query.page) : 1;
        const limit = req.query.limit && !isNaN(parseInt(req.query.limit)) ? parseInt(req.query.limit) : 10;
        const categoryId = req.query.category && !isNaN(parseInt(req.query.category)) ? parseInt(req.query.category) : null;
        const authorId = req.query.author && !isNaN(parseInt(req.query.author)) ? parseInt(req.query.author) : null;
        const publisherId = req.query.publisher && !isNaN(parseInt(req.query.publisher)) ? parseInt(req.query.publisher) : null;
        const minPrice = req.query.min_price && !isNaN(parseInt(req.query.min_price)) ? parseInt(req.query.min_price) : null;
        const maxPrice = req.query.max_price && !isNaN(parseInt(req.query.max_price)) ? parseInt(req.query.max_price) : null;
        const minRating = req.query.min_rating && !isNaN(parseFloat(req.query.min_rating)) ? parseFloat(req.query.min_rating) : null;
        const sortBy = req.query.sort_by || 'newest';

        const offset = (page - 1) * limit;

        const matches = await searchVectorComics(q);

        let searchIds = null;
        if (matches && matches.length > 0) {
            searchIds = matches.map((match) => parseInt(match._id, 10));
        } else {
            // If no vector matches, we can return empty or fallback to SQL
            return res.status(200).json({
                success: true,
                message: 'Không tìm thấy truyện phù hợp',
                data: [],
                meta: {
                    current_page: page,
                    items_per_page: limit,
                    total_items: 0,
                    total_pages: 0
                }
            });
        }

        const { comics, totalItems } = await comicService.getComicsList({
            limit,
            offset,
            categoryId,
            authorId,
            publisherId,
            search: q,
            searchIds,
            minPrice,
            maxPrice,
            minRating,
            sortBy
        });

        // Ensure vector search order is preserved if no other sort is applied
        let finalComics = comics;
        if (sortBy === 'newest' && searchIds) {
            finalComics = searchIds
                .map((id) => comics.find((p) => p.id === id))
                .filter(Boolean);
        }

        return res.status(200).json({
            success: true,
            message: 'Tìm kiếm truyện thành công',
            data: finalComics,
            meta: {
                current_page: page,
                items_per_page: limit,
                total_items: totalItems,
                total_pages: Math.ceil(totalItems / limit)
            }
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Search failed' });
    }
};

exports.upsertProducts = async (req, res) => {
    try {
        const products = await db('comics').select('*');

        if (products.length === 0) {
            return res.status(404).json({ error: 'No products found' });
        }

        await upsertComicData(products);
        return res.json({ message: `✅ Upserted ${products.length} products to Pinecone` });
    } catch (err) {
        console.error('❌ Upsert error details:', err);
        return res.status(500).json({ error: err.message });
    }
};

exports.updateComic = async (req, res, next) => {
    try {
        const { id } = req.params;
        const updatedComic = await comicService.updateComic(id, req.body);

        // Real-time: Notify all clients that a comic has been updated
        try {
            io.getIO().emit('COMIC_UPDATED', updatedComic);
        } catch (socketErr) {
            console.error('Socket emission failed:', socketErr);
        }

        res.status(200).json({ success: true, message: 'Updated successfully', data: updatedComic });
    } catch (error) { next(error); }
};

exports.deleteComic = async (req, res, next) => {
    try {
        const { id } = req.params;
        await comicService.deleteComic(id);

        // Real-time: Notify all clients that a comic has been deleted
        try {
            // Using parseInt to ensure the ID is consistent (number vs string)
            io.getIO().emit('COMIC_DELETED', parseInt(id, 10));
        } catch (socketErr) {
            console.error('Socket emission failed:', socketErr);
        }

        res.status(200).json({ success: true, message: 'Deleted successfully' });
    } catch (error) { next(error); }
};