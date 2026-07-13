import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/data_model.dart';
import '../../viewmodel/adminVM.dart';
import '../../viewmodel/authVM.dart';
import 'add_edit_comic_screen.dart';


// ── AdminProductScreen ─────────────────────────────────────────────────────
class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminVM>().fetchBooks();
    });
  }

  void _navigateToEdit(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditComicScreen(book: book)),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditComicScreen()),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProfileColors.surface,
        title: const Text('Delete this comic?', style: TextStyle(color: AppColors.white)),
        content: Text('"${book.title}" will be permanently removed.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final token = context.read<AuthVM>().accessToken ?? '';
    final success = await context.read<AdminVM>().deleteBook(book.id, token);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Comic deleted' : (context.read<AdminVM>().error ?? 'Failed to delete')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _navigateToAdd(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminVM>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (vm.error != null && vm.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${vm.error}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchBooks(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (vm.books.isEmpty) {
            return const Center(
              child: Text('No comics yet — tap + to add one',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vm.fetchBooks(),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: vm.books.length,
              itemBuilder: (context, index) {
                final book = vm.books[index];
                return GestureDetector(
                  onTap: () => _navigateToEdit(context, book),
                  child: _buildProductCard(context, book),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ProfileColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.white),
      title: const Text(
        'Manage Products',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ── Product Card ──────────────────────────────────────────────────────
  Widget _buildProductCard(BuildContext context, Book book) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ProfileColors.surfaceRaised,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: book.coverImage != null && book.coverImage!.isNotEmpty
                    ? Image.asset(
                        book.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.book_rounded,
                              color: book.coverColor.withValues(alpha: 0.85), size: 36),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.book_rounded,
                            color: book.coverColor.withValues(alpha: 0.85), size: 36),
                      ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: ProfileColors.surface,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${book.price}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToEdit(context, book),
                      child: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                    ),
                    GestureDetector(
                      onTap: () => _confirmDelete(context, book),
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
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