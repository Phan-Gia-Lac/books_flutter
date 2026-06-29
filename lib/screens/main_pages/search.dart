import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/data_model.dart';
import '../../viewmodel/productsVM.dart';
import '../controllers/book_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedCategoryId;
  int? _selectedAuthorId;
  int? _selectedPublisherId;
  String _query = '';

  // Filter states
  RangeValues _currentPriceRange = const RangeValues(0, 100000);
  double _minRating = 0;
  String? _sortBy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ProductsVM>(context, listen: false);
      vm.fetchCategories();
      vm.fetchAuthors();
      vm.fetchPublishers();

      // Handle category passed from HomeScreen
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _selectedCategoryId = args;
      }

      _triggerSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _triggerSearch() {
    Provider.of<ProductsVM>(context, listen: false).searchBooks(
      query: _searchController.text,
      categoryId: _selectedCategoryId,
      authorId: _selectedAuthorId,
      publisherId: _selectedPublisherId,
      minPrice: _currentPriceRange.start,
      maxPrice: _currentPriceRange.end,
      minRating: _minRating,
      sortBy: _sortBy,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _query = query);
      _triggerSearch();
    });
  }

  void _selectCategory(int? categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
    });
    _triggerSearch();
  }

  void _showFilterSheet() {
    final vm = Provider.of<ProductsVM>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: ProfileColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ lọc & Sắp xếp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // ── Price Range ──
                  const Text(
                    'Khoảng giá (\$)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RangeSlider(
                    values: _currentPriceRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: ProfileColors.lime,
                    inactiveColor: Colors.white10,
                    labels: RangeLabels(
                      '\$${_currentPriceRange.start.round()}',
                      '\$${_currentPriceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setModalState(() => _currentPriceRange = values);
                      setState(() {});
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_currentPriceRange.start.round()}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${_currentPriceRange.end.round()}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Rating ──
                  const Text(
                    'Đánh giá tối thiểu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final starVal = index + 1.0;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => _minRating = starVal);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _minRating == starVal
                                ? ProfileColors.lime
                                : ProfileColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$index+',
                                style: TextStyle(
                                  color: _minRating == starVal
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star_rounded,
                                color: _minRating == starVal
                                    ? Colors.black
                                    : Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // ── Author ──
                  const Text(
                    'Tác giả',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vm.authors.length,
                      itemBuilder: (context, index) {
                        final author = vm.authors[index];
                        final isSelected = _selectedAuthorId == author.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(author.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(
                                () => _selectedAuthorId = selected
                                    ? author.id
                                    : null,
                              );
                              setState(() {});
                            },
                            selectedColor: ProfileColors.lime,
                            backgroundColor: ProfileColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Publisher ──
                  const Text(
                    'Nhà xuất bản',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vm.publishers.length,
                      itemBuilder: (context, index) {
                        final pub = vm.publishers[index];
                        final isSelected = _selectedPublisherId == pub.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(pub.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(
                                () => _selectedPublisherId = selected
                                    ? pub.id
                                    : null,
                              );
                              setState(() {});
                            },
                            selectedColor: ProfileColors.lime,
                            backgroundColor: ProfileColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Sorting ──
                  const Text(
                    'Sắp xếp theo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _sortChip(setModalState, 'Mới nhất', 'newest'),
                      _sortChip(
                        setModalState,
                        'Giá: Thấp đến Cao',
                        'price_asc',
                      ),
                      _sortChip(
                        setModalState,
                        'Giá: Cao đến Thấp',
                        'price_desc',
                      ),
                      _sortChip(setModalState, 'Đánh giá cao', 'rating_desc'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Apply Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProfileColors.lime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _triggerSearch();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setModalState(() {
                          _currentPriceRange = const RangeValues(0, 100000);
                          _minRating = 0;
                          _sortBy = null;
                          _selectedAuthorId = null;
                          _selectedPublisherId = null;
                        });
                        setState(() {});
                        _triggerSearch();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xóa tất cả',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sortChip(StateSetter setModalState, String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() => _sortBy = selected ? value : null);
        setState(() {});
      },
      selectedColor: ProfileColors.lime,
      backgroundColor: ProfileColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductsVM>(context);

    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tìm kiếm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar & Filter Button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: ProfileColors.lime,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm truyện, tác giả...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor: ProfileColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white60,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          (_sortBy != null ||
                              _minRating > 0 ||
                              _currentPriceRange.start > 0 ||
                              _currentPriceRange.end < 100000 ||
                              _selectedAuthorId != null ||
                              _selectedPublisherId != null)
                          ? ProfileColors.lime
                          : ProfileColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color:
                          (_sortBy != null ||
                              _minRating > 0 ||
                              _currentPriceRange.start > 0 ||
                              _currentPriceRange.end < 100000 ||
                              _selectedAuthorId != null ||
                              _selectedPublisherId != null)
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Categories Horizontal List ──
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: vm.categories.length,
              itemBuilder: (context, index) {
                final cat = vm.categories[index];
                final isSelected = _selectedCategoryId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (_) => _selectCategory(cat.id),
                    backgroundColor: ProfileColors.surface,
                    selectedColor: ProfileColors.lime,
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: isSelected ? ProfileColors.lime : Colors.white10,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Body ──
          Expanded(
            child: vm.isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: ProfileColors.lime),
                  )
                : _buildResults(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ProductsVM vm) {
    if (vm.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy truyện nào',
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _query.isEmpty
                  ? 'Hãy thử tìm kiếm gì đó'
                  : 'Thử từ khóa khác xem sao',
              style: const TextStyle(color: Colors.white30, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: vm.searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final book = vm.searchResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
            );
          },
          child: _buildBookCard(book),
        );
      },
    );
  }

  Widget _buildBookCard(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: book.coverColor.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              //child: const Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: book.coverImage != null && book.coverImage!.isNotEmpty
                    ? Image.asset(
                        book.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.book_rounded,
                                color: Colors.white54,
                                size: 36,
                              ),
                            ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.book_rounded,
                          color: Colors.white54,
                          size: 36,
                        ),
                      ),
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
                    color: Colors.white,
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
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC107),
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          book.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${book.price}',
                      style: const TextStyle(
                        color: ProfileColors.lime,
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
