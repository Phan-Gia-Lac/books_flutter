// src/models/category.model.js
const db = require('../config/db');
const TABLE_NAME = 'categories';

exports.getAllCategories = async () => {
    return db(TABLE_NAME)
        .select('id', 'name', 'description')
        .orderBy('name', 'asc');
};

exports.findById = async (id) => {
    return db(TABLE_NAME).where({ id }).first();
};