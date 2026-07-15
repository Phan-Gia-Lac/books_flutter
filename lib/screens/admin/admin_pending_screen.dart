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
      context.read<AdminVM>().fetchOrders(token);
      // context.read<AdminVM>().fetchPendingOrders(token);
    });
  }

  Future<void> _handleApprove(BuildContext context, dynamic order) async {
    final token = context.read<AuthVM>().accessToken ?? '';
    final success = await context.read<AdminVM>().approveOrder(order['id'], token);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Order #${order['id']} moved to Processing'
            : (context.read<AdminVM>().error ?? 'Failed to approve')),
      ),
    );
  }

  Future<void> _handleComplete(BuildContext context, dynamic order) async {
    final token = context.read<AuthVM>().accessToken ?? '';
    final success = await context.read<AdminVM>().completeOrder(order['id'], token);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Order #${order['id']} marked as Completed'
            : (context.read<AdminVM>().error ?? 'Failed to complete')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    // backgroundColor: ProfileColors.background,
    // appBar: AppBar
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ProfileColors.background,
        appBar: AppBar(
          backgroundColor: ProfileColors.background,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.white),
          title: const Text(
            'Order Management',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Processing'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(context, 'pending'),
            _buildOrderList(context, 'processing'),
          ],
        ),
      ),
        // body: Consumer<AdminVM>(
        //     builder: (context, vm, child) {
        //       if (vm.isLoading) {
        //         return const Center(
        //             child: CircularProgressIndicator(color: AppColors.accent));
        //       }
    );
  }

  // if (vm.error != null && vm.pendingOrders.isEmpty) {
  // return Center(
  // child: Column(
  // mainAxisAlignment: MainAxisAlignment.center,
  // children: [
  // Text('Lỗi: ${vm.error}',
  // style: const TextStyle(color: Colors.white)),
  // const SizedBox(height: 16),
  // ElevatedButton(
  // onPressed: () {
  // final token = context.read<AuthVM>().accessToken ?? '';
  // vm.fetchPendingOrders(token);
  // },
  // child: const Text('Thử lại'),
  // ),
  // ],
  // ),
  // );
  // }
  Widget _buildOrderList(BuildContext context, String status) {
    return Consumer<AdminVM>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accent));
        }

        // if (vm.pendingOrders.isEmpty) {
        //  return const Center(
        //    child: Text('No pending orders',
        //      style: TextStyle(color: AppColors.textSecondary)),
        //    );
        //  )
        // }

        final filteredOrders = status == 'pending' ? vm.pendingOrders : vm.processingOrders;

        // return RefreshIndicator(
        //     onRefresh: () {
        //       final token = context.read<AuthVM>().accessToken ?? '';
        //       return vm.fetchPendingOrders(token);
        //     },
        //     child: ListView.separated(
        //         padding: const EdgeInsets.all(20),
        //         itemCount: vm.pendingOrders.length,
        //         separatorBuilder: (_, __) => const SizedBox(height: 12),
        //         itemBuilder: (context, index) {
        //           final order = vm.pendingOrders[index];
        //           return _buildOrderCard(context, order);
        //         },
        if (vm.error != null && filteredOrders.isEmpty) {
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
                    vm.fetchOrders(token);
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (filteredOrders.isEmpty) {
          return Center(
            child: Text('No $status orders 🎉',
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }

        return RefreshIndicator(
          onRefresh: () {
            final token = context.read<AuthVM>().accessToken ?? '';
            return vm.fetchOrders(token);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filteredOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _buildOrderCard(context, order);
            },
          ),
        );
      },
    );
  }

  // ── Order Card ─────────────────────────────────────────────────────────
  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final status = order['status'] ?? 'pending';
    final isPending = status == 'pending';
    
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
                  color: (isPending ? Colors.orange : Colors.blue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isPending ? Colors.orangeAccent : Colors.blueAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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
              onPressed: () => isPending 
                  ? _handleApprove(context, order) 
                  : _handleComplete(context, order),
              icon: Icon(isPending ? Icons.check_circle_outline : Icons.done_all, size: 18),
              label: Text(isPending ? 'Approve' : 'Mark as Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPending ? AppColors.accent : Colors.blueAccent,
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
