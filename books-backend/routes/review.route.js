const express = require('express');
const router = express.Router({ mergeParams: true }); // Để lấy được comicId từ route cha
const reviewController = require('../controllers/review.controller');
const auth = require('../middlewares/auth.middleware');

// [PUBLIC] Lấy danh sách review của 1 cuốn truyện
router.get('/', reviewController.getComicReviews);

// [PRIVATE - CUSTOMER] Gửi đánh giá mới
router.post('/', auth, reviewController.createReview);

module.exports = router;
