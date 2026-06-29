/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function (knex) {
    return knex.schema
        .createTable('categories', (table) => {
            table.increments('id').primary();
            table.string('name', 100).notNullable();
            table.string('description', 255);
            table.timestamps(true, true);
        })
        .createTable('publishers', (table) => {
            table.increments('id').primary();
            table.string('name', 100).notNullable();
            table.timestamps(true, true);
        })
        .createTable('authors', (table) => {
            table.increments('id').primary();
            table.string('name', 100).notNullable();
            table.string('nationality', 100);
            table.timestamps(true, true);
        })
        .createTable('users', (table) => {
            //For better performance use increment //If we going for security, we should use UUID
            table.increments('id').primary();
            table.string('full_name', 100).notNullable();
            table.string('email', 100).notNullable().unique();
            table.string('password', 255).notNullable();
            table.string('role', 50).notNullable().defaultTo('CUSTOMER'); // CUSTOMER, STAFF, ADMIN
            table.string('phone_number', 15);
            table.integer('points').defaultTo(0);
            table.boolean('is_deleted').defaultTo(false);
            table.timestamps(true, true);
        })
        .createTable('comics', (table) => {
            table.increments('id').primary();
            table.string('title', 200).notNullable();
            table.integer('volume').defaultTo(1);
            table.integer('price').notNullable();
            table.integer('stock_quantity').notNullable().defaultTo(0);
            table.integer('category_id').unsigned().references('id').inTable('categories').onDelete('SET NULL');
            table.integer('author_id').unsigned().references('id').inTable('authors').onDelete('SET NULL');
            table.integer('publisher_id').unsigned().references('id').inTable('publishers').onDelete('SET NULL');
            table.string('cover_image', 255);
            table.string('status', 50).defaultTo('active'); // active, inactive
            table.boolean('is_deleted').defaultTo(false);
            table.timestamps(true, true);
            table.text('description');
        })
        .createTable('orders', (table) => {
            table.increments('id').primary();
            table.timestamp('order_date').defaultTo(knex.fn.now());
            table.integer('customer_id').unsigned().references('id').inTable('users').onDelete('SET NULL');
            table.integer('staff_id').unsigned().references('id').inTable('users').onDelete('SET NULL');
            table.integer('total_amount').defaultTo(0);
            table.string('status', 50).defaultTo('pending'); // pending, processing, shipped, completed, cancelled
            table.string('shipping_address', 255);
            table.string('payment_method', 50);
            table.timestamps(true, true);
        })
        .createTable('order_items', (table) => {
            table.integer('order_id').unsigned().references('id').inTable('orders').onDelete('CASCADE');
            table.integer('comic_id').unsigned().references('id').inTable('comics').onDelete('RESTRICT');
            table.integer('quantity').notNullable();
            table.integer('price').notNullable();
            table.primary(['order_id', 'comic_id']);
        })
        .createTable('reviews', (table) => {
            table.increments('id').primary();
            table.integer('comic_id').unsigned().references('id').inTable('comics').onDelete('CASCADE');
            table.integer('user_id').unsigned().references('id').inTable('users').onDelete('CASCADE');
            table.integer('rating').notNullable().checkBetween([1, 5]); // 1-5 sao
            table.text('comment');
            table.timestamps(true, true);
        });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function (knex) {
    return knex.schema
        .dropTableIfExists('order_items')
        .dropTableIfExists('orders')
        .dropTableIfExists('comics')
        .dropTableIfExists('users')
        .dropTableIfExists('authors')
        .dropTableIfExists('publishers')
        .dropTableIfExists('categories')
        .dropTableIfExists('reviews');
};