const express = require('express');
const router = express.Router();
const db = require('../config/db');

router.get('/', async (req, res, next) => {
    try {
        const categories = await db('categories').select('*');
        res.status(200).json({
            success: true,
            data: categories
        });
    } catch (error) {
        next(error);
    }
});

module.exports = router;