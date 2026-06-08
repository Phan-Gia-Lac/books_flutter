// src/routes/comic.route.js
const express = require('express');
const router = express.Router();
const comicController = require('../controllers/comic.controller');
const auth = require('../middlewares/auth.middleware');
const role = require('../middlewares/role.middleware');

// [PUBLIC] Khách hàng xem danh sách và chi tiết truyện
router.get('/', comicController.getAllComics);
router.get('/:id', comicController.getComicById);

// [PRIVATE - STAFF & ADMIN] Thêm truyện mới
router.post('/', auth, role(['STAFF', 'ADMIN']), comicController.createComic);

// [PRIVATE - STAFF & ADMIN] Cập nhật hoặc Xóa truyện (Bạn có thể thêm controller sau)
// router.put('/:id', auth, role(['STAFF', 'ADMIN']), comicController.updateComic);
// router.delete('/:id', auth, role(['STAFF', 'ADMIN']), comicController.deleteComic);

module.exports = router;