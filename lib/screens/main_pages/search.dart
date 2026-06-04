import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Reusing Book model — move this to a shared models file later
class Book {
  final String title;
  final String author;
  final double rating;
  final double price;
  final Color coverColor;
  final String genre;

  const Book({
    required this.title,
    required this.author,
    required this.rating,
    required this.price,
    required this.coverColor,
    required this.genre,
  });
}

// Placeholder books
final List<Book> _allBooks = [
  Book(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', rating: 4.5, price: 12.99, coverColor: const Color(0xFF6C63FF), genre: 'Fiction'),
  Book(title: 'To Kill a Mockingbird', author: 'Harper Lee', rating: 4.8, price: 10.99, coverColor: const Color(0xFF2196F3), genre: 'Fiction'),
  Book(title: '1984', author: 'George Orwell', rating: 4.7, price: 9.99, coverColor: const Color(0xFFE91E63), genre: 'Sci-Fi'),
  Book(title: 'Dune', author: 'Frank Herbert', rating: 4.6, price: 14.99, coverColor: const Color(0xFFFF9800), genre: 'Sci-Fi'),
  Book(title: 'Harry Potter', author: 'J.K. Rowling', rating: 4.9, price: 15.99, coverColor: const Color(0xFF9C27B0), genre: 'Fantasy'),
  Book(title: 'The Hobbit', author: 'J.R.R. Tolkien', rating: 4.7, price: 11.99, coverColor: const Color(0xFF4CAF50), genre: 'Fantasy'),
  Book(title: 'Sherlock Holmes', author: 'Arthur Conan Doyle', rating: 4.5, price: 8.99, coverColor: const Color(0xFF795548), genre: 'Mystery'),
  Book(title: 'The Alchemist', author: 'Paulo Coelho', rating: 4.6, price: 10.99, coverColor: const Color(0xFF009688), genre: 'Fiction'),
  Book(title: 'Brave New World', author: 'Aldous Huxley', rating: 4.3, price: 9.99, coverColor: const Color(0xFFF44336), genre: 'Sci-Fi'),
  Book(title: 'Fahrenheit 451', author: 'Ray Bradbury', rating: 4.4, price: 8.99, coverColor: const Color(0xFF3F51B5), genre: 'Sci-Fi'),
];

const List<String> _genres = [
  'Fiction', 'Sci-Fi', 'Fantasy', 'Mystery',
  'Romance', 'Thriller', 'Horror', 'Biography',
  'Self-Help', 'History',
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedGenre;
  bool _isFocused = false;

  List<Book> get _suggestions => _query.isEmpty
      ? []
      : _allBooks
          .where((b) =>
              b.title.toLowerCase().startsWith(_query.toLowerCase()))
          .take(4)
          .toList();

  List<Book> get _results => _allBooks.where((b) {
        final matchesQuery = _query.isEmpty ||
            b.title.toLowerCase().contains(_query.toLowerCase()) ||
            b.author.toLowerCase().contains(_query.toLowerCase());
        final matchesGenre =
            _selectedGenre == null || b.genre == _selectedGenre;
        return matchesQuery && matchesGenre;
      }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Search',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Focus(
              onFocusChange: (focused) =>
                  setState(() => _isFocused = focused),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.accent,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search books, authors...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Suggestions dropdown ──
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final book = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: book.title.substring(0, _query.length),
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: book.title.substring(_query.length),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.north_west_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    onTap: () {
                      _searchController.text = book.title;
                      setState(() => _query = book.title);
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // ── Body ──
          Expanded(
            child: _query.isEmpty
                ? _buildEmptyState()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  // ── Empty state — popular genres ──
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Genres',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Genre chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _genres.map((genre) {
              final isSelected = _selectedGenre == genre;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGenre = isSelected ? null : genre;
                    if (!isSelected) _query = genre;
                    _searchController.text = isSelected ? '' : genre;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: ProfileColors.lime,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? ProfileColors.limeDim
                          : ProfileColors.lime,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Results — grid ──
  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return _buildBookCard(_results[index]);
      },
    );
  }

  Widget _buildBookCard(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: book.coverColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.book_rounded,
                    color: Colors.white54, size: 36),
              ),
            ),
          ),
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
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 13),
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