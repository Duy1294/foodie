import 'package:flutter/material.dart';
import '../../../../core/services/vietqr_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../home/presentation/screens/home_screen.dart';

class QRPaymentScreen extends StatefulWidget {
  final String orderNumber;
  final double amount;
  final String orderId;

  const QRPaymentScreen({
    super.key,
    required this.orderNumber,
    required this.amount,
    required this.orderId,
  });

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen> {
  bool _isPaid = false;

  String get _qrUrl => VietQRService.generateQRUrl(
        amount: widget.amount,
        orderNumber: widget.orderNumber,
      );

  void _handlePaymentConfirmed() {
    setState(() => _isPaid = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Xác nhận thanh toán'),
          ],
        ),
        content: const Text(
          'Cảm ơn bạn đã thanh toán!\n\n'
          'Đơn hàng của bạn sẽ được xử lý sau khi xác nhận thanh toán thành công.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to checkout
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Về trang chủ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán qua QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order info card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin đơn hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mã đơn hàng:'),
                        Text(
                          widget.orderNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số tiền:'),
                        Text(
                          _formatCurrency(widget.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // QR Code
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Quét mã QR để thanh toán',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Image.network(
                        _qrUrl,
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('QR Code Error: $error');
                          print('QR URL: $_qrUrl');
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 50,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Không thể tải QR code',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {}); // Reload
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Thử lại'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance, 
                                color: Colors.blue[700], 
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Ngân hàng:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'MB Bank - ${VietQRService.accountNo}',
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, 
                                color: Colors.blue[700], 
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Chủ tài khoản:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            VietQRService.accountName,
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Instructions
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Hướng dẫn thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep('1', 'Mở app ngân hàng hoặc MoMo trên điện thoại'),
                    _buildInstructionStep('2', 'Chọn chức năng "Quét mã QR"'),
                    _buildInstructionStep('3', 'Quét mã QR ở trên'),
                    _buildInstructionStep('4', 'Kiểm tra thông tin: Số tiền và nội dung thanh toán'),
                    _buildInstructionStep('5', 'Xác nhận thanh toán trong app'),
                    _buildInstructionStep('6', 'Nhấn nút "Đã thanh toán" bên dưới'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Nội dung thanh toán',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thanh toan don hang ${widget.orderNumber}',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vui lòng nhập đúng nội dung này khi thanh toán',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Confirm payment button
            ElevatedButton(
              onPressed: _isPaid ? null : _handlePaymentConfirmed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isPaid
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Đã xác nhận thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Đã thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            
            // Note
            Text(
              '💡 Lưu ý: Vui lòng thanh toán đúng số tiền và nội dung để đơn hàng được xử lý nhanh chóng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ';
  }
}

