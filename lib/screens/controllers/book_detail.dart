// ── BookDetailScreen ─────────────────────────────────────────────────────────
// FIX: converted from a top-level function returning Scaffold into a proper
//      StatelessWidget so it can be pushed via Navigator.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/data_model.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/productsVM.dart';
import '../../viewmodel/authVM.dart';
import '../../services/api_service.dart';
import '../main_pages/cart_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _apiService = ApiService();
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  final _commentController = TextEditingController();
  int _userRating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    if (widget.book.id == null) return;
    setState(() => _isLoadingReviews = true);
    final reviews = await _apiService.fetchComicReviews(widget.book.id!);
    setState(() {
      _reviews = reviews;
      _isLoadingReviews = false;
    });
  }

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProfileColors.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Đọc thử: ${widget.book.title}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: PageView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: ProfileColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: widget.book.coverImage != null && widget.book.coverImage!.isNotEmpty
                      ? Image.asset(
                          widget.book.coverImage!,
                          fit: BoxFit.contain,
                        )
                      : const Center(
                          child: Icon(Icons.book_rounded, color: Colors.white24, size: 64),
                        ),
                ),
              );
            },
          ),
        ),
        actions: [
          Center(
            child: Text(
              'Vuốt ngang để xem tiếp (Trang 1-3)',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    final auth = Provider.of<AuthVM>(context, listen: false);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
      );
      return;
    }

    try {
      await _apiService.submitReview(
        comicId: widget.book.id!,
        rating: _userRating,
        comment: _commentController.text.trim(),
        token: auth.accessToken!,
      );
      _commentController.clear();
      _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Book detail',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          Consumer<ProductsVM>(
            builder: (context, vm, _) {
              if (vm.itemCount == 0) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _openCart(context),
                icon: Badge(
                  label: Text('${vm.itemCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      // body: Padding
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ProfileColors.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              // child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child:
                    widget.book.coverImage != null &&
                        widget.book.coverImage!.isNotEmpty
                    ? Image.asset(
                        widget.book.coverImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.book_rounded,
                            color: widget.book.coverColor.withValues(
                              alpha: 0.9,
                            ),
                            size: 80,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.book_rounded,
                          color: widget.book.coverColor.withValues(alpha: 0.9),
                          size: 80,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.book.title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${widget.book.author}',
              style: TextStyle(
                color: ProfileColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ProfileColors.lime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Tập ${widget.book.volume}',
                style: const TextStyle(
                  color: ProfileColors.lime,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC107),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.book.rating.toString(),
                  style: TextStyle(
                    color: ProfileColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${widget.book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: ProfileColors.lime,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Description
            const Text(
              'Tóm tắt nội dung',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.description ?? 'Chưa có tóm tắt cho cuốn truyện này.',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showPreviewDialog,
                    icon: const Icon(Icons.menu_book_rounded, size: 20),
                    label: const Text('Đọc thử'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileColors.surfaceRaised,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Review Form
            _buildReviewForm(),

            const SizedBox(height: 24),

            // Reviews List
            if (_isLoadingReviews)
              const Center(
                child: CircularProgressIndicator(color: ProfileColors.lime),
              )
            else if (_reviews.isEmpty)
              const Center(
                child: Text(
                  'Chưa có bình luận nào. Hãy là người đầu tiên!',
                  style: TextStyle(color: Colors.white30),
                ),
              )
            else
              ..._reviews.map((r) => _ReviewTile(review: r)),

            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _userRating = index + 1),
                icon: Icon(
                  index < _userRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(right: 4),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Chia sẻ cảm nhận của bạn...',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: ProfileColors.surfaceRaised,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileColors.lime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Gửi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ProfileColors.background,
        border: Border(top: BorderSide(color: ProfileColors.wireFrame)),
      ),
      child: Consumer<ProductsVM>(
        builder: (context, vm, _) {
          return ElevatedButton(
            onPressed: () => vm.addToCart(widget.book),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfileColors.lime,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Thêm vào giỏ · \$${widget.book.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 14,
              );
            }),
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
