const db = require('../config/db');

const TABLE_NAME = 'users';

exports.findByRole = async (role) => {
    if (role === 'ADMIN') {
        return db(TABLE_NAME).whereNot('role', ['CUSTOMER', 'STAFF']).select('*');
    } else {
        const error = new Error('Invalid role');
        error.statusCode = 400;
        throw error;
    }
};

