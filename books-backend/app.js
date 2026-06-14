// src/app.js (located at root of books-backend)
const express = require('express');
const routes = require('./routes');
const errorMiddleware = require('./middlewares/error.middleware');

const app = express();

// 1. Parser JSON body
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 2. Custom CORS Middleware
app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

// 3. API root health check
app.get('/api', (req, res) => {
    res.json({
        success: true,
        message: 'Comic API is running',
        availableRoutes: ['/api/auth', '/api/comics', '/api/orders', '/api/users']
    });
});

// 4. Mount Routes
app.use('/api', routes);

// 5. Fallback route for 404
app.use((req, res, next) => {
    const error = new Error('Đường dẫn không tồn tại');
    error.statusCode = 404;
    next(error);
});

// 5. Global Error Handling Middleware
app.use(errorMiddleware);

module.exports = app;
