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
    { title: 'Doraemon', volume: 1, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-1.png', description: 'The historic first volume introducing the iconic robotic cat from the 22nd century and his futuristic gadgets.' },
    { title: 'Doraemon', volume: 2, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-2.png', description: 'Follow Nobita and Doraemon as they use miraculous gadgets to navigate through daily school struggles and neighborhood adventures.' },
    { title: 'Doraemon', volume: 3, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-3.png', description: 'More chaotic and heartwarming stories featuring Gian, Suneo, and Shizuka getting caught up in Doraemon\'s inventions.' },
    { title: 'Doraemon', volume: 4, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-4.png', description: 'Exciting short stories featuring classic gadgets like the Anywhere Door and Time Machine helping Nobita out of trouble.' },
    { title: 'Doraemon', volume: 5, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-5.png', description: 'A wonderful collection of chapters highlighting the deep friendship between a clumsy boy and his trusty robotic companion.' },
    { title: 'Doraemon', volume: 32, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-32.png', description: 'Classic late-series adventures filled with imaginative sci-fi concepts and creative problem-solving.' },
    { title: 'Doraemon', volume: 33, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-33.png', description: 'Fun-filled escapades where Nobita tries to misuse Doraemon\'s tools, leading to hilarious moral lessons.' },
    { title: 'Doraemon', volume: 34, price: 20000, stock_quantity: 50, category_id: 1, author_id: 1, publisher_id: 1, cover_image: 'assets/book-images/Doraemon-34.png', description: 'Memorable stories focusing on neighborhood mysteries and family bonds, aided by magical 22nd-century technology.' },
    { title: 'Detective Conan', volume: 91, price: 20000, stock_quantity: 50, category_id: 1, author_id: 2, publisher_id: 1, cover_image: 'assets/book-images/Conan-91.png', description: 'Brilliant high-school detective Shinichi Kudo, trapped in a child\'s body, unravels intricate locked-room murder mysteries.' },
    { title: 'Detective Conan', volume: 99, price: 20000, stock_quantity: 50, category_id: 1, author_id: 2, publisher_id: 1, cover_image: 'assets/book-images/Conan-99.png', description: 'The tension rises as Conan Edogawa edges closer to uncovering secrets about the dangerous Black Organization.' },
    { title: 'Detective Conan', volume: 107, price: 20000, stock_quantity: 50, category_id: 1, author_id: 2, publisher_id: 1, cover_image: 'assets/book-images/Conan-107.png', description: 'Mind-bending deduction cases and thrilling encounters that push the Junior Detective League to their limits.' },
    { title: 'Dragon Ball', volume: 18, price: 20000, stock_quantity: 50, category_id: 1, author_id: 3, publisher_id: 1, cover_image: 'assets/book-images/Dragon-Ball-18.png', description: 'High-stakes martial arts battles and epic confrontations as Goku and his allies defend Earth against powerful threats.' },
    { title: 'Dragon Ball', volume: 36, price: 20000, stock_quantity: 50, category_id: 1, author_id: 3, publisher_id: 1, cover_image: 'assets/book-images/Dragon-Ball-36.png', description: 'Legendary, fast-paced cosmic action featuring intense power-ups, iconic transformations, and ultimate energy clashes.' },
    { title: 'Spider-Man', volume: 1, price: 50000, stock_quantity: 50, category_id: 2, author_id: 4, publisher_id: 1, cover_image: 'assets/book-images/Spider-Man-1.png', description: 'Peter Parker balances the everyday struggles of a student with the great responsibility of protecting New York City.' },
    { title: 'The Smurfs', volume: 1, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-1.png', description: 'The charming introduction to the small blue creatures living in mushroom houses, constantly outsmarting the evil Gargamel.' },
    { title: 'The Smurfs', volume: 2, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-2.png', description: 'Delightful village adventures featuring Papa Smurf, Smurfette, and the rest of the community working together.' },
    { title: 'The Smurfs', volume: 4, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-4.png', description: 'Whimsical tales deep inside the enchanted forest, full of humor, teamwork, and magical mishaps.' },
    { title: 'The Smurfs', volume: 8, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-8.png', description: 'Exciting community-focused escapades showing how the Smurfs overcome greed, jealousy, and external dangers.' },
    { title: 'The Smurfs', volume: 12, price: 50000, stock_quantity: 50, category_id: 2, author_id: 5, publisher_id: 2, cover_image: 'assets/book-images/Smurfs-12.png', description: 'Classic European comic storytelling packed with clever subtext, fun dialogue, and wonderful fantasy elements.' },
    { title: 'The Adventures of Tintin', volume: 1, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-1.png', description: 'The brave young reporter Tintin and his loyal dog Snowy embark on their very first global investigative journey.' },
    { title: 'The Adventures of Tintin', volume: 3, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-3.png', description: 'A thrilling mystery taking Tintin across exotic lands, unmasking smugglers and dangerous international criminals.' },
    { title: 'The Adventures of Tintin', volume: 5, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-5.png', description: 'Masterfully drawn political intrigue and treasure hunts, showcasing Hergé\'s signature clear-line art style.' },
    { title: 'The Adventures of Tintin', volume: 7, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-7.png', description: 'High-stakes suspense as Tintin collaborates with Captain Haddock to decipher historical clues and hidden maps.' },
    { title: 'The Adventures of Tintin', volume: 9, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-9.png', description: 'An action-packed adventure blending rich historical context with clever comedy and daring escapes.' },
    { title: 'The Adventures of Tintin', volume: 11, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-11.png', description: 'Unforgettable detective work involving eccentric scientists, ancient curses, and perilous natural landscapes.' },
    { title: 'The Adventures of Tintin', volume: 12, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-12.png', description: 'Tintin navigates complex deception and dangerous paths in a brilliant demonstration of courage and logic.' },
    { title: 'The Adventures of Tintin', volume: 15, price: 50000, stock_quantity: 50, category_id: 2, author_id: 6, publisher_id: 2, cover_image: 'assets/book-images/Tintin-15.png', description: 'A spectacular, universally acclaimed tale of loyalty and survival in one of the world\'s most unforgiving environments.' },
    { title: 'Than Dong Dat Viet', volume: 1, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-1.png', description: 'The unforgettable debut of Le Tuan, a brilliant prodigy who uses his immense wit to solve village disputes and outsmart officials.' },
    { title: 'Than Dong Dat Viet', volume: 2, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-2.png', description: 'Le Tuan, alongside his close friends Hieu, Meo, and Do, faces hilarious cultural puzzles and historical challenges.' },
    { title: 'Than Dong Dat Viet', volume: 12, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-12.png', description: 'Witty adaptations of classic Vietnamese folklore and court politics, filled with traditional humor and sharp intellect.' },
    { title: 'Than Dong Dat Viet', volume: 21, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-21.png', description: 'Le Tuan travels to the royal capital to assist the Emperor, outwitting foreign envoys with absolute brilliance.' },
    { title: 'Than Dong Dat Viet', volume: 45, price: 20000, stock_quantity: 50, category_id: 3, author_id: 7, publisher_id: 5, cover_image: 'assets/book-images/TDDV-45.png', description: 'Highly entertaining historical satire and clever folk problem-solving that celebrates traditional Vietnamese wisdom.' },
    { title: 'Dung Si Hesman', volume: 1, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-1.png', description: 'The legendary Vietnamese sci-fi series begins, introducing the iconic giant robot guardian defending the galaxy.' },
    { title: 'Dung Si Hesman', volume: 2, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-2.png', description: 'Interstellar battles heat up as heroic pilots team up to control Hesman against ruthless alien invaders.' },
    { title: 'Dung Si Hesman', volume: 3, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-3.png', description: 'High-octane mecha action mixed with deep sci-fi world-building that captured the hearts of a generation.' },
    { title: 'Dung Si Hesman', volume: 12, price: 20000, stock_quantity: 50, category_id: 3, author_id: 8, publisher_id: 5, cover_image: 'assets/book-images/Hesman-12.png', description: 'Complex space politics, unexpected betrayals, and massive robot duels in deep space.' },
    { title: 'Ty Quay', volume: 1, price: 20000, stock_quantity: 50, category_id: 3, author_id: 9, publisher_id: 1, cover_image: 'assets/book-images/Ty-Quay-1.png', description: 'The modern childhood classic following the hilarious, mischievous pranks and schoolyard antics of Ty and his friends.' },
    { title: 'Ty Quay', volume: 2, price: 20000, stock_quantity: 50, category_id: 3, author_id: 9, publisher_id: 1, cover_image: 'assets/book-images/Ty-Quay-2.png', description: 'Heartwarming family moments and relatable classroom troubles that perfectly capture contemporary Vietnamese student life.' }
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
