import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AppRoutes.dart';
import '../../models/cart_item.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/productsVM.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'Cart',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<ProductsVM>(
        builder: (context, vm, _) {
          if (vm.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: ProfileColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add books from the store',
                    style: TextStyle(
                      color: ProfileColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = vm.cartItems[index];
                    return _CartItemTile(
                      cartItem: item,
                      onIncrement: () => vm.incrementQuantity(item.book.id!),
                      onDecrement: () => vm.decrementQuantity(item.book.id!),
                      onRemove: () => vm.removeAt(index),
                    );
                  },
                ),
              ),
              _CartSummary(
                total: vm.total,
                itemCount: vm.itemCount,
                onClear: vm.clearCart,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final book = cartItem.book;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 72,
            decoration: BoxDecoration(
              color: ProfileColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.coverImage != null && book.coverImage!.isNotEmpty
                  ? Image.asset(
                      book.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.book_rounded,
                          color: book.coverColor.withValues(alpha: 0.85),
                          size: 28,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.book_rounded,
                        color: book.coverColor.withValues(alpha: 0.85),
                        size: 28,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(
                    color: ProfileColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: ProfileColors.lime,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onRemove,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close_rounded, color: ProfileColors.textSecondary, size: 18),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: ProfileColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onDecrement,
                      iconSize: 16,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.remove_rounded, color: Colors.white),
                    ),
                    Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: onIncrement,
                      iconSize: 16,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.total,
    required this.itemCount,
    required this.onClear,
  });

  final double total;
  final int itemCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        border: Border(top: BorderSide(color: ProfileColors.wireFrame)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: ProfileColors.lime,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.checkout);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: ProfileColors.lime,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ProfileColors.saveButtonText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onClear,
            child: const Text(
              'Clear cart',
              style: TextStyle(color: ProfileColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
