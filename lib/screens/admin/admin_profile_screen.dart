import 'package:books_flutter/AppRoutes.dart';
import 'package:books_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:books_flutter/viewmodel/authVM.dart';
import 'package:provider/provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  void _onSignOut(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthVM>().user;

    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'ADMIN PROFILE',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: ProfileColors.surface,
              child: Icon(Icons.admin_panel_settings_rounded, size: 50, color: ProfileColors.lime),
            ),
            const SizedBox(height: 24),
            _buildInfoCard('Name', user?.fullName ?? 'Admin'),
            const SizedBox(height: 12),
            _buildInfoCard('Email', user?.email ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoCard('Role', user?.role ?? 'ADMIN'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _onSignOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
