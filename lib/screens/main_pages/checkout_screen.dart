import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/productsVM.dart';
import '../../viewmodel/authVM.dart';
import '../../services/api_service.dart';
import '../../AppRoutes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  int _currentStep = 0;
  String _paymentMethod = 'COD';
  bool _isLoading = false;
  final _apiService = ApiService();
  // UPDATED: Shipping fee updated to 1000
  // OLD: final double _shippingFee = 2.0;
  final double _shippingFee = 1000.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthVM>(context, listen: false).user;
      if (user != null) {
        _nameController.text = user.fullName;
        _phoneController.text = user.phoneNumber ?? '';
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty || 
          _phoneController.text.trim().isEmpty || 
          _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin giao hàng')),
        );
        return;
      }
    }
    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _handlePlaceOrder() async {
    final vm = Provider.of<ProductsVM>(context, listen: false);
    if (vm.cartItems.isEmpty) return;

    final auth = Provider.of<AuthVM>(context, listen: false);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = vm.cartItems.map((item) => {
        'comic_id': item.book.id,
        'quantity': item.quantity,
      }).toList();

      final fullAddress = '${_nameController.text.trim()} | ${_phoneController.text.trim()}\n${_addressController.text.trim()}';

      await _apiService.placeOrder(
        items: items,
        address: fullAddress,
        paymentMethod: _paymentMethod,
        token: auth.accessToken!,
      );

      if (mounted) {
        vm.clearCart();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: ProfileColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Column(
              children: [
                Icon(Icons.check_circle_rounded, color: ProfileColors.lime, size: 48),
                SizedBox(height: 16),
                Text('Đặt hàng thành công', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
              'Đơn hàng của bạn đã được tiếp nhận và đang chờ xử lý.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileColors.lime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Về trang chủ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(context, AppRoutes.orderHistory);
                    },
                    child: const Text('Xem đơn hàng', style: TextStyle(color: Colors.white60)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductsVM>(context);
    final total = vm.total + _shippingFee;

    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: _currentStep == 0 ? () => Navigator.pop(context) : _previousStep,
        ),
        title: Text(
          _currentStep == 0 ? 'Thông tin giao hàng' : 
          _currentStep == 1 ? 'Thanh toán' : 'Xác nhận đơn hàng',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(vm),
            ),
          ),
          
          // Bottom Action Bar
          _buildBottomBar(vm, total),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? ProfileColors.lime : Colors.white10,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.white30,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: 40,
                  height: 2,
                  color: index < _currentStep ? ProfileColors.lime : Colors.white10,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(ProductsVM vm) {
    switch (_currentStep) {
      case 0: return _buildShippingForm();
      case 1: return _buildPaymentSelection();
      case 2: return _buildOrderReview(vm);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildShippingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Họ và tên', _nameController, Icons.person_outline_rounded),
        const SizedBox(height: 20),
        _buildTextField('Số điện thoại', _phoneController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        _buildTextField('Địa chỉ giao hàng', _addressController, Icons.location_on_outlined, maxLines: 3),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ProfileColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: ProfileColors.lime, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Thông tin này sẽ được lưu cho các đơn hàng sau.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white30, size: 20),
            filled: true,
            fillColor: ProfileColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ProfileColors.lime, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn phương thức thanh toán', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPaymentOption('COD', 'Thanh toán khi nhận hàng', 'Trả tiền khi shipper giao hàng tận nơi', Icons.money_rounded),
        _buildPaymentOption('BANK', 'Chuyển khoản ngân hàng', 'Thanh toán qua số tài khoản ngân hàng', Icons.account_balance_rounded),
        _buildPaymentOption('MOMO', 'Ví điện tử MoMo', 'Thanh toán nhanh qua ứng dụng MoMo', Icons.account_balance_wallet_rounded, isPlaceholder: true),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon, {bool isPlaceholder = false}) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: isPlaceholder ? null : () => setState(() => _paymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ProfileColors.lime.withValues(alpha: 0.1) : ProfileColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? ProfileColors.lime : Colors.white10, width: 1.5),
        ),
        child: Opacity(
          opacity: isPlaceholder ? 0.5 : 1.0,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? ProfileColors.lime : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isSelected ? Colors.black : Colors.white60),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              if (isPlaceholder)
                const Text('Sắp ra mắt', style: TextStyle(color: ProfileColors.lime, fontSize: 10, fontWeight: FontWeight.bold))
              else if (isSelected)
                const Icon(Icons.check_circle_rounded, color: ProfileColors.lime, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderReview(ProductsVM vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sản phẩm', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...vm.cartItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 56,
                decoration: BoxDecoration(
                  color: ProfileColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: item.book.coverImage != null ? Image.asset(item.book.coverImage!, fit: BoxFit.cover) : const Icon(Icons.book, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.book.title, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Số lượng: ${item.quantity}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Text('\$${(item.book.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        )),
        const Divider(color: Colors.white10, height: 32),
        const Text('Giao hàng tới', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${_nameController.text} | ${_phoneController.text}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(_addressController.text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const Divider(color: Colors.white10, height: 32),
        const Text('Phương thức thanh toán', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(_paymentMethod == 'COD' ? Icons.money_rounded : Icons.account_balance_rounded, color: ProfileColors.lime, size: 18),
            const SizedBox(width: 8),
            Text(_paymentMethod == 'COD' ? 'Thanh toán khi nhận hàng' : 'Chuyển khoản ngân hàng', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(ProductsVM vm, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStep == 2) ...[
            _buildPriceRow('Tạm tính', '\$${vm.total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            // UPDATED: Fixed RangeError by using correct toStringAsFixed(2)
            // OLD: _buildPriceRow('Phí vận chuyển', '\$${_shippingFee.toStringAsFixed(1000)}'),
            _buildPriceRow('Phí vận chuyển', '\$${_shippingFee.toStringAsFixed(2)}'),
            const Divider(color: Colors.white10, height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng thanh toán', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: ProfileColors.lime, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_currentStep < 2 ? _nextStep : _handlePlaceOrder),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProfileColors.lime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text(
                          _currentStep < 2 ? 'Tiếp tục' : 'Đặt hàng ngay',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
