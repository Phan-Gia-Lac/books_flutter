import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AppRoutes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/authVM.dart';
import 'admin_product_screen.dart';
import 'admin_pending_screen.dart';
import 'admin_profile_screen.dart';


class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95,
          children: [
            _buildMenuCard(
              context,
              icon: Icons.menu_book_rounded,
              label: 'Product',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProductScreen()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.assignment_rounded,
              label: 'Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPendingScreen()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ProfileColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        'ADMIN · COMICO',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.white),
          onPressed: () {
            _showSignOutDialog(context);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProfileColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ProfileColors.wireFrame),
        ),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            color: ProfileColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        content: const Text(
          'You will need to sign in again to access the admin panel.',
          style: TextStyle(color: ProfileColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ProfileColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthVM>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              );
            },
            child: const Text(
              'Sign out',
              style: TextStyle(
                color: ProfileColors.lime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ── Menu Card (icon in middle, label below) ─────────────────────────────
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ProfileColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ProfileColors.surfaceRaised,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}