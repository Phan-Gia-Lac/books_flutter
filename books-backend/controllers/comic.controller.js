// src/controllers/comic.controller.js
const comicService = require('../services/comic.service');

/**
 * Lấy danh sách truyện đang bán (Dành cho Customer)
 * Hỗ trợ phân trang và lọc theo thể loại
 * GET /api/comics?page=1&limit=10&category=2
 */
exports.getAllComics = async (req, res, next) => {
    try {
        // Lấy query parameters từ URL, thiết lập giá trị mặc định nếu không có
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const categoryId = req.query.category ? parseInt(req.query.category) : null;

        const offset = (page - 1) * limit;

        // Service sẽ gọi database thông qua Model
        const comics = await comicService.getComicsList({ limit, offset, categoryId });

        res.status(200).json({
            success: true,
            message: 'Lấy danh sách truyện thành công',
            data: comics,
            meta: {
                current_page: page,
                items_per_page: limit,
                // Nếu làm kỹ, Service có thể trả thêm total_items để frontend tính tổng số trang
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

        res.status(201).json({
            success: true,
            message: 'Thêm truyện tranh mới thành công',
            data: newComic
        });
    } catch (error) {
        next(error);
    }
};