// ── BookDetailScreen ─────────────────────────────────────────────────────────
// FIX: converted from a top-level function returning Scaffold into a proper
//      StatelessWidget so it can be pushed via Navigator.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/data_model.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/productsVM.dart';
import '../main_pages/cart_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ProfileColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Center(
                child: Icon(
                  Icons.book_rounded,
                  color: book.coverColor.withValues(alpha: 0.9),
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              book.title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${book.author}',
              style: TextStyle(
                color: ProfileColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                const SizedBox(width: 4),
                Text(
                  book.rating.toString(),
                  style: TextStyle(
                    color: ProfileColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: ProfileColors.lime,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Consumer<ProductsVM>(
              builder: (context, vm, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => vm.addToCart(book),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: ProfileColors.lime,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Add to cart · \$${book.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: ProfileColors.saveButtonText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (vm.itemCount > 0) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _openCart(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: ProfileColors.wireFrame),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'View cart (${vm.itemCount})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
