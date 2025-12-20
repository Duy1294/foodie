import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khoản sử dụng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ĐIỀU KHOẢN SỬ DỤNG',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cập nhật lần cuối: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Chấp nhận điều khoản',
              'Bằng việc sử dụng ứng dụng Foodie, bạn đồng ý tuân thủ các điều khoản và điều kiện được nêu trong tài liệu này. Nếu bạn không đồng ý, vui lòng không sử dụng ứng dụng.',
            ),
            _buildSection(
              '2. Sử dụng dịch vụ',
              'Bạn được phép sử dụng ứng dụng Foodie cho mục đích cá nhân và thương mại hợp pháp. Bạn không được sử dụng ứng dụng cho bất kỳ mục đích bất hợp pháp nào.',
            ),
            _buildSection(
              '3. Tài khoản người dùng',
              'Bạn chịu trách nhiệm bảo mật thông tin đăng nhập của mình. Bạn phải thông báo ngay cho chúng tôi nếu phát hiện bất kỳ hoạt động trái phép nào.',
            ),
            _buildSection(
              '4. Đơn hàng và thanh toán',
              'Khi đặt hàng, bạn đồng ý thanh toán đầy đủ số tiền đã đặt. Chúng tôi có quyền từ chối hoặc hủy đơn hàng nếu có bất kỳ vấn đề nào.',
            ),
            _buildSection(
              '5. Quyền sở hữu trí tuệ',
              'Tất cả nội dung trong ứng dụng, bao gồm logo, văn bản, hình ảnh, đều thuộc quyền sở hữu của Foodie và được bảo vệ bởi luật bản quyền.',
            ),
            _buildSection(
              '6. Giới hạn trách nhiệm',
              'Foodie không chịu trách nhiệm về bất kỳ thiệt hại nào phát sinh từ việc sử dụng hoặc không thể sử dụng ứng dụng.',
            ),
            _buildSection(
              '7. Thay đổi điều khoản',
              'Chúng tôi có quyền thay đổi các điều khoản này bất cứ lúc nào. Việc tiếp tục sử dụng ứng dụng sau khi thay đổi được coi là bạn đã chấp nhận các điều khoản mới.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Nếu bạn có bất kỳ câu hỏi nào về điều khoản sử dụng, vui lòng liên hệ với chúng tôi qua email: support@foodie.app',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

