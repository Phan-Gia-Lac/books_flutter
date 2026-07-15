const db = require('../config/db');
const orderService = require('../services/order.service');

// Thêm sản phẩm
exports.addProduct = async (req, res, next) => {
    try {
        const comicData = req.body;
        // Nếu có xử lý upload file ảnh (Multer, Cloudinary,...)
        if (req.file) {
            comicData.cover_image = req.file.path;
        }

        const [newComic] = await db('comics').insert(comicData).returning('*');

        res.status(201).json({
            success: true,
            message: 'Thêm sản phẩm thành công',
            data: newComic
        });
    } catch (error) {
        next(error);
    }
};

// Xóa sản phẩm (Soft delete)
exports.deleteProduct = async (req, res, next) => {
    try {
        const { id } = req.params;

        const deletedCount = await db('comics').where({ id }).update({ is_deleted: true, updated_at: new Date() });

        if (deletedCount === 0) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy sản phẩm'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Xóa sản phẩm thành công'
        });
    } catch (error) {
        next(error);
    }
};

// Duyệt đơn hàng / Cập nhật trạng thái
exports.approveOrder = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { status } = req.body; // VD: 'processing', 'shipped', 'completed', 'cancelled'
        const staffId = req.user.id; // Người duyệt

        const updatedOrder = await orderService.changeOrderStatus(id, status, staffId);

        // Real-time: Notify the Customer that their order status has changed
        try {
            const io = require('../socket');
            io.getIO().emit('ORDER_STATUS_UPDATED', updatedOrder);
        } catch (socketErr) {
            console.error('Socket emission failed (ORDER_STATUS_UPDATED):', socketErr);
        }

        res.status(200).json({
            success: true,
            message: `Cập nhật trạng thái đơn hàng thành '${status}' thành công`,
            data: updatedOrder
        });
    } catch (error) {
        next(error);
    }
};

// Lấy danh sách toàn bộ đơn hàng (Cho Admin)
exports.getAllOrders = async (req, res, next) => {
    try {
        const orders = await db('orders').orderBy('order_date', 'desc');

        // Nạp chi tiết sản phẩm cho từng đơn hàng
        for (let order of orders) {
            order.items = await db('order_items')
                .join('comics', 'order_items.comic_id', 'comics.id')
                .select(
                    'order_items.*',
                    'comics.title as comic_title',
                    'comics.cover_image as comic_cover_image'
                )
                .where({ order_id: order.id });
        }

        res.status(200).json({
            success: true,
            message: 'Lấy danh sách đơn hàng thành công',
            data: orders
        });
    } catch (error) {
        next(error);
    }
};