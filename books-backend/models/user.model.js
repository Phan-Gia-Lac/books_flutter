const db = require('../config/db');

const TABLE_NAME = 'users';

exports.findByEmail = async (email) => {
    return db(TABLE_NAME).where({ email, is_deleted: false }).first();
};

exports.findById = async (id) => {
    return db(TABLE_NAME)
        .select('id', 'full_name', 'email', 'role', 'created_at') // Ẩn password hash
        .where({ id, is_deleted: false })
        .first();
};

exports.createUser = async (userData) => {
    // .returning('*') đặc thù của PostgreSQL, giúp trả về bản ghi ngay sau khi insert
    const [newUser] = await db(TABLE_NAME).insert(userData).returning('*');
    return newUser;
};

exports.updateUser = async (id, updateData) => {
    const [updatedUser] = await db(TABLE_NAME)
        .where({ id })
        .update(updateData)
        .returning('*');
    return updatedUser;
};

exports.findAll = async () => {
    return db(TABLE_NAME)
        .select('id', 'full_name', 'email', 'role', 'phone_number', 'points', 'is_deleted', 'created_at')
        .orderBy('created_at', 'desc');
};