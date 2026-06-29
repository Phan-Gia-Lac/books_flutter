const bcrypt = require('bcrypt');

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.seed = async function (knex) {
    // Truncate all tables and reset identity sequences
    await knex.raw(
        'TRUNCATE TABLE "order_items", "orders", "comics", "users", "authors", "publishers", "categories" RESTART IDENTITY CASCADE'
    );

    // Hash a default password for all users
    const salt = await bcrypt.genSalt(10);
    const defaultPassword = await bcrypt.hash('123456', salt);

    // Seed Categories (formerly TheLoai)
    await knex('categories').insert([
        { name: 'Manga (Japan)', description: 'Japanese comic books and graphic novels' },
        { name: 'Comic (Western)', description: 'European and American comic books' },
        { name: 'Vietnamese Comics', description: 'Comics written and published in Vietnam' }
    ]);

    // Seed Publishers (formerly NhaXuatBan)
    await knex('publishers').insert([
        { name: 'Kim Dong Publishing House' },
        { name: 'Hai Phong Publishing House' },
        { name: 'Literature Publishing House' },
        { name: 'General Publishing House of HCMC' },
        { name: 'Phan Thi Publishing House' }
    ]);

    // Seed Authors (formerly TacGia)
    await knex('authors').insert([
        { name: 'Fujiko F. Fujio', nationality: 'Japan' },
        { name: 'Gosho Aoyama', nationality: 'Japan' },
        { name: 'Akira Toriyama', nationality: 'Japan' },
        { name: 'Stan Lee', nationality: 'USA' },
        { name: 'Peyo', nationality: 'Belgium' },
        { name: 'Hergé', nationality: 'Belgium' },
        { name: 'Le Linh', nationality: 'Vietnam' },
        { name: 'Nguyen Hung Lan', nationality: 'Vietnam' },
        { name: 'Dao Hai', nationality: 'Vietnam' }
    ]);

    // Seed Users (formerly KhachHang & NhanVien)
    await knex('users').insert([ 
        // Customers
        { full_name: 'Nguyen Van An', email: 'an.nguyen@gmail.com', password: defaultPassword, role: 'CUSTOMER', phone_number: '0901234567', points: 100 },
        { full_name: 'Tran Thi Binh', email: 'binh.tran@gmail.com', password: defaultPassword, role: 'CUSTOMER', phone_number: '0987654321', points: 50 },
        { full_name: 'Le Hoang Cuong', email: 'cuong.le@gmail.com', password: defaultPassword, role: 'CUSTOMER', phone_number: '0911222333', points: 0 },
        // Staff
        { full_name: 'Pham Thu Ha', email: 'ha.pham@comicshop.com', password: defaultPassword, role: 'STAFF', phone_number: '0912345678', points: 0 },
        // Admin
        { full_name: 'Vu Hai Dang', email: 'dang.vu@comicshop.com', password: defaultPassword, role: 'ADMIN', phone_number: '0987654321', points: 0 }
    ]);
 
    // Seed Comics (formerly TruyenTranh)
    await knex('comics').insert([
        { title: 'Doraemon', volume: 1, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-1.png' },
        { title: 'Doraemon', volume: 2, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-2.png' },
        { title: 'Doraemon', volume: 3, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-3.png' },
        { title: 'Doraemon', volume: 4, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-4.png' },
        { title: 'Doraemon', volume: 5, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-5.png' },
        { title: 'Doraemon', volume: 32, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-32.png' },
        { title: 'Doraemon', volume: 33, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-33.png' },
        { title: 'Doraemon', volume: 34, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-34.png' },
        { title: 'Detective Conan', volume: 91, price: 20000, stock_quantity: 50, category_id: 1, author_id: 2, publisher_id: 1, cover_image: 'assets/book-images/Conan-91.png' },
        { title: 'Detective Conan', volume: 99, price: 20000, stock_quantity: 50, category_id: 1, author_id: 2, publisher_id: 1, cover_image: 'assets/book-images/Conan-99.png' },
        { title: 'Detective Conan', volume: 107, price: 20000, stock_quantity: 50, category_id: 1, author_id: 2, publisher_id: 1, cover_image: 'assets/book-images/Conan-107.png' },
        { title: 'Dragon Ball', volume: 18, price: 20000, stock_quantity: 50, category_id: 1, author_id: 3, publisher_id: 1, cover_image: 'assets/book-images/Dragon-Ball-18.png' },
        { title: 'Dragon Ball', volume: 36, price: 20000, stock_quantity: 50, category_id: 1, author_id: 3, publisher_id: 1, cover_image: 'assets/book-images/Dragon-Ball-36.png' },
        { title: 'Spider-Man', volume: 1, price: 50000, stock_quantity: 50, category_id: 2, author_id: 4, publisher_id: 1, cover_image: 'assets/book-images/Spider-Man-1.png' },
        { title: 'The Smurfs', volume: 1, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-1.png' },
        { title: 'The Smurfs', volume: 2, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-2.png' },
        { title: 'The Smurfs', volume: 4, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-4.png' },
        { title: 'The Smurfs', volume: 8, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-8.png' },
        { title: 'The Smurfs', volume: 12, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-12.png' },
        { title: 'The Adventures of Tintin', volume: 1, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-1.png' },
        { title: 'The Adventures of Tintin', volume: 3, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-3.png' },
        { title: 'The Adventures of Tintin', volume: 5, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-5.png' },
        { title: 'The Adventures of Tintin', volume: 7, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-7.png' },
        { title: 'The Adventures of Tintin', volume: 9, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-9.png' },
        { title: 'The Adventures of Tintin', volume: 11, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-11.png' },
        { title: 'The Adventures of Tintin', volume: 12, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-12.png' },
        { title: 'The Adventures of Tintin', volume: 15, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-15.png' },
        { title: 'Than Dong Dat Viet', volume: 1, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-1.png' },
        { title: 'Than Dong Dat Viet', volume: 2, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-2.png' },
        { title: 'Than Dong Dat Viet', volume: 12, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-12.png' },
        { title: 'Than Dong Dat Viet', volume: 21, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-21.png' },
        { title: 'Than Dong Dat Viet', volume: 45, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-45.png' },
        { title: 'Dung Si Hesman', volume: 1, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-1.png' },
        { title: 'Dung Si Hesman', volume: 2, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-2.png' },
        { title: 'Dung Si Hesman', volume: 3, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-3.png' },
        { title: 'Dung Si Hesman', volume: 12, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-12.png' },
        { title: 'Ty Quay', volume: 1, price: 20000, stock_quantity: 50, category_id: 3, author_id: 9, publisher_id: 1, cover_image: 'assets/book-images/Ty-Quay-1.png' },
        { title: 'Ty Quay', volume: 2, price: 20000, stock_quantity: 50, category_id: 3, author_id: 9, publisher_id: 1, cover_image: 'assets/book-images/Ty-Quay-2.png' }
    ]);

    // Seed Orders (formerly HoaDon)
    await knex('orders').insert([
        { order_date: '2026-03-01 08:30:00', customer_id: 1, staff_id: 4, total_amount: 62000, status: 'completed', shipping_address: '123 Nguyen Trai, Q.5, TP.HCM', payment_method: 'COD' },
        { order_date: '2026-03-02 14:15:00', customer_id: 2, staff_id: 4, total_amount: 115000, status: 'completed', shipping_address: '456 Le Loi, Q.1, TP.HCM', payment_method: 'MOMO' }
    ]);

    // Seed Order Items (formerly ChiTietHoaDon)
    await knex('order_items').insert([
        { order_id: 1, comic_id: 1, quantity: 2, price: 20000 },
        { order_id: 1, comic_id: 3, quantity: 1, price: 22000 },
        { order_id: 2, comic_id: 4, quantity: 1, price: 50000 },
        { order_id: 2, comic_id: 5, quantity: 1, price: 65000 }
    ]);
};
