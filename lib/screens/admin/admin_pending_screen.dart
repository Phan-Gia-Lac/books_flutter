import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/adminVM.dart';
import '../../viewmodel/authVM.dart';


// ── AdminPendingScreen ─────────────────────────────────────────────────────
class AdminPendingScreen extends StatefulWidget {
  const AdminPendingScreen({super.key});

  @override
  State<AdminPendingScreen> createState() => _AdminPendingScreenState();
}

class _AdminPendingScreenState extends State<AdminPendingScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthVM>().accessToken ?? '';
      context.read<AdminVM>().fetchPendingOrders(token);
    });
  }

  Future<void> _handleApprove(BuildContext context, dynamic order) async {
    final token = context.read<AuthVM>().accessToken ?? '';
    final success = await context.read<AdminVM>().approveOrder(order['id'], token);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Order #${order['id']} approved'
            : (context.read<AdminVM>().error ?? 'Failed to approve')),
      ),
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
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'Pending Orders',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Consumer<AdminVM>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (vm.error != null && vm.pendingOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${vm.error}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final token = context.read<AuthVM>().accessToken ?? '';
                      vm.fetchPendingOrders(token);
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (vm.pendingOrders.isEmpty) {
            return const Center(
              child: Text('No pending orders 🎉',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              final token = context.read<AuthVM>().accessToken ?? '';
              return vm.fetchPendingOrders(token);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: vm.pendingOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = vm.pendingOrders[index];
                return _buildOrderCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  // ── Order Card ─────────────────────────────────────────────────────────
  Widget _buildOrderCard(BuildContext context, dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order['id']}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: \$${order['total_amount'] ?? order['total'] ?? '0.00'}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if (order['shipping_address'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ship to: ${order['shipping_address']}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _handleApprove(context, order),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}   