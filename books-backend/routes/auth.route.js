// src/routes/auth.route.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
// const validate = require('../middlewares/validate.middleware');
// const { registerSchema, loginSchema } = require('../utils/validations');

// API Đăng ký
router.post('/register', authController.register);
// Nếu có validate middleware: router.post('/register', validate(registerSchema), authController.register);

// API Đăng nhập
router.post('/login', authController.login);

module.exports = router;