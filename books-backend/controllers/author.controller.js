const db = require('../config/db');

exports.getAllAuthors = async (req, res, next) => {
    try {
        const authors = await db('authors').select('*').orderBy('name', 'asc');
        res.status(200).json({
            success: true,
            data: authors
        });
    } catch (error) {
        next(error);
    }
};
