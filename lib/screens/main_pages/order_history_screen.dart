import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/authVM.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _apiService = ApiService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'all';

  final Map<String, String> _statusMap = {
    'all': 'Tất cả',
    'pending': 'Chờ duyệt',
    'processing': 'Đang xử lý',
    'shipped': 'Đang giao',
    'completed': 'Hoàn thành',
    'cancelled': 'Đã hủy',
  };

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final auth = Provider.of<AuthVM>(context, listen: false);
    if (!auth.isLoggedIn) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _apiService.fetchMyOrders(auth.accessToken!);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredOrders {
    if (_selectedStatus == 'all') return _orders;
    return _orders.where((o) => o['status'] == _selectedStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'completed': return ProfileColors.lime;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        title: const Text('Lịch sử đơn hàng', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _statusMap.entries.map((entry) {
                final isSelected = _selectedStatus == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedStatus = entry.key);
                    },
                    backgroundColor: ProfileColors.surface,
                    selectedColor: ProfileColors.lime,
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: ProfileColors.lime))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _filteredOrders.isEmpty
                        ? const Center(child: Text('Không có đơn hàng nào', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return _OrderCard(
                                order: order,
                                statusColor: _getStatusColor(order['status']),
                                statusLabel: _statusMap[order['status']] ?? order['status'],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final Color statusColor;
  final String statusLabel;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(order['order_date']).toLocal();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
    final items = order['items'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order['id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const Divider(color: Colors.white10, height: 24),
          ...items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.book_outlined, color: Colors.white24, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['comic_title'] ?? 'Truyện tranh',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('x${item['quantity']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              )),
          if (items.length > 2)
            Text('và ${items.length - 2} sản phẩm khác...', style: const TextStyle(color: Colors.white30, fontSize: 11)),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '${order['total_amount'].toString()} VNĐ',
                style: const TextStyle(color: ProfileColors.lime, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
