import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Temporary book model for placeholder data
class Book {
  final String title;
  final String author;
  final double rating;
  final double price;
  final Color coverColor; // placeholder color instead of real image

  const Book({
    required this.title,
    required this.author,
    required this.rating,
    required this.price,
    required this.coverColor,
  });
}

// Placeholder data
final List<Book> _featuredBooks = [
  Book(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', rating: 4.5, price: 12.99, coverColor: const Color(0xFF6C63FF)),
  Book(title: 'To Kill a Mockingbird', author: 'Harper Lee', rating: 4.8, price: 10.99, coverColor: const Color(0xFF2196F3)),
  Book(title: '1984', author: 'George Orwell', rating: 4.7, price: 9.99, coverColor: const Color(0xFFE91E63)),
  Book(title: 'Dune', author: 'Frank Herbert', rating: 4.6, price: 14.99, coverColor: const Color(0xFFFF9800)),
];

final List<Book> _popularBooks = [
  Book(title: 'Harry Potter', author: 'J.K. Rowling', rating: 4.9, price: 15.99, coverColor: const Color(0xFF9C27B0)),
  Book(title: 'The Hobbit', author: 'J.R.R. Tolkien', rating: 4.7, price: 11.99, coverColor: const Color(0xFF4CAF50)),
  Book(title: 'Sherlock Holmes', author: 'Arthur Conan Doyle', rating: 4.5, price: 8.99, coverColor: const Color(0xFF795548)),
  Book(title: 'The Alchemist', author: 'Paulo Coelho', rating: 4.6, price: 10.99, coverColor: const Color(0xFF009688)),
  Book(title: 'Brave New World', author: 'Aldous Huxley', rating: 4.3, price: 9.99, coverColor: const Color(0xFFF44336)),
  Book(title: 'Fahrenheit 451', author: 'Ray Bradbury', rating: 4.4, price: 8.99, coverColor: const Color(0xFF3F51B5)),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 28),
            _buildSectionHeader('Featured', onSeeAll: () {}),
            const SizedBox(height: 16),
            _buildFeaturedBooks(),
            const SizedBox(height: 28),
            _buildSectionHeader('Popular', onSeeAll: () {}),
            const SizedBox(height: 16),
            _buildPopularGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'COMICO STORE',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Banner ──
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3B37C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background decoration circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LIMITED OFFER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Get 30% off\nyour first order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured Books horizontal scroll ──
  Widget _buildFeaturedBooks() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _featuredBooks.length,
        itemBuilder: (context, index) {
          return _buildFeaturedCard(_featuredBooks[index]);
        },
      ),
    );
  }

  Widget _buildFeaturedCard(Book book) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: book.coverColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.book_rounded, color: Colors.white54, size: 40),
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            book.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Rating + Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                  const SizedBox(width: 2),
                  Text(
                    book.rating.toString(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${book.price}',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Popular Books grid ──
  Widget _buildPopularGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _popularBooks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return _buildPopularCard(_popularBooks[index]);
      },
    );
  }

  Widget _buildPopularCard(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: book.coverColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.book_rounded, color: Colors.white54, size: 36),
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 13),
                        const SizedBox(width: 2),
                        Text(
                          book.rating.toString(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${book.price}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}