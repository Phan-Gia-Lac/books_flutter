// src/config/db.js
const knex = require('knex');
const knexfile = require('../db/knexfile');
const env = require('./env');

// Tự động chọn cấu hình dựa trên môi trường (development, production...)
const environment = env.app.node_env || 'development';
const db = knex(knexfile[environment]);

module.exports = db;