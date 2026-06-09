// src/routes/index.js
const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.route');
const comicRoutes = require('./comic.route');
const orderRoutes = require('./order.route');
const userRoutes = require('./user.route');

// Khai báo tiền tố cho từng nhóm route
router.use('/auth', authRoutes);       // Các API bắt đầu bằng /api/auth
router.use('/comics', comicRoutes);    // Các API bắt đầu bằng /api/comics
router.use('/orders', orderRoutes);    // Các API bắt đầu bằng /api/orders
router.use('/users', userRoutes);      // Các API bắt đầu bằng /api/users

module.exports = router;