const db = require('../config/db');

/**
 * Lấy danh sách đánh giá của 1 cuốn truyện
 * GET /api/comics/:comicId/reviews
 */
exports.getComicReviews = async (req, res, next) => {
    try {
        const { comicId } = req.params;

        const reviews = await db('reviews')
            .join('users', 'reviews.user_id', 'users.id')
            .select(
                'reviews.*',
                'users.full_name as user_name'
            )
            .where('comic_id', comicId)
            .orderBy('created_at', 'desc');

        res.status(200).json({
            success: true,
            data: reviews
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Gửi đánh giá mới
 * POST /api/comics/:comicId/reviews
 */
exports.createReview = async (req, res, next) => {
    try {
        const { comicId } = req.params;
        const { rating, comment } = req.body;
        const userId = req.user.id;

        // Kiểm tra xem đã review chưa (optional: 1 user chỉ được review 1 lần mỗi truyện)
        const existingReview = await db('reviews')
            .where({ comic_id: comicId, user_id: userId })
            .first();

        let review;
        if (existingReview) {
            // Cập nhật review cũ
            [review] = await db('reviews')
                .where({ id: existingReview.id })
                .update({ rating, comment, updated_at: new Date() })
                .returning('*');
        } else {
            // Tạo review mới
            [review] = await db('reviews')
                .insert({
                    comic_id: comicId,
                    user_id: userId,
                    rating,
                    comment
                })
                .returning('*');
        }

        res.status(201).json({
            success: true,
            message: 'Cảm ơn bạn đã đánh giá!',
            data: review
        });
    } catch (error) {
        next(error);
    }
};
