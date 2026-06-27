const db = require('../config/db');

exports.getAllPublishers = async (req, res, next) => {
    try {
        const publishers = await db('publishers').select('*').orderBy('name', 'asc');
        res.status(200).json({
            success: true,
            data: publishers
        });
    } catch (error) {
        next(error);
    }
};
