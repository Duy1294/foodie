import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính sách bảo mật'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHÍNH SÁCH BẢO MẬT',
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
              '1. Thông tin chúng tôi thu thập',
              'Chúng tôi thu thập thông tin bạn cung cấp khi đăng ký, đặt hàng, hoặc sử dụng dịch vụ, bao gồm:\n'
              '• Thông tin cá nhân: tên, email, số điện thoại, địa chỉ\n'
              '• Thông tin thanh toán: phương thức thanh toán (được mã hóa)\n'
              '• Thông tin sử dụng: lịch sử đơn hàng, tìm kiếm, tương tác với ứng dụng\n'
              '• Vị trí: khi bạn cho phép, chúng tôi thu thập vị trí để tìm nhà hàng gần nhất',
            ),
            _buildSection(
              '2. Cách chúng tôi sử dụng thông tin',
              'Thông tin của bạn được sử dụng để:\n'
              '• Cung cấp và cải thiện dịch vụ\n'
              '• Xử lý đơn hàng và thanh toán\n'
              '• Gửi thông báo về đơn hàng và khuyến mãi\n'
              '• Phân tích và cải thiện trải nghiệm người dùng\n'
              '• Tuân thủ các yêu cầu pháp lý',
            ),
            _buildSection(
              '3. Chia sẻ thông tin',
              'Chúng tôi không bán thông tin của bạn. Chúng tôi chỉ chia sẻ thông tin với:\n'
              '• Nhà hàng: để xử lý đơn hàng của bạn\n'
              '• Đối tác giao hàng: để giao đơn hàng\n'
              '• Nhà cung cấp dịch vụ: để vận hành ứng dụng\n'
              '• Khi được yêu cầu bởi pháp luật',
            ),
            _buildSection(
              '4. Bảo mật thông tin',
              'Chúng tôi sử dụng các biện pháp bảo mật tiên tiến để bảo vệ thông tin của bạn:\n'
              '• Mã hóa dữ liệu trong quá trình truyền tải\n'
              '• Lưu trữ an toàn trên server được bảo vệ\n'
              '• Kiểm soát truy cập nghiêm ngặt\n'
              '• Cập nhật bảo mật thường xuyên',
            ),
            _buildSection(
              '5. Quyền của bạn',
              'Bạn có quyền:\n'
              '• Truy cập và chỉnh sửa thông tin cá nhân\n'
              '• Yêu cầu xóa tài khoản\n'
              '• Từ chối nhận thông báo marketing\n'
              '• Yêu cầu xuất dữ liệu của bạn\n'
              '• Khiếu nại về việc xử lý dữ liệu',
            ),
            _buildSection(
              '6. Cookie và công nghệ theo dõi',
              'Chúng tôi sử dụng cookie và công nghệ tương tự để:\n'
              '• Ghi nhớ tùy chọn của bạn\n'
              '• Phân tích cách sử dụng ứng dụng\n'
              '• Cải thiện hiệu suất và trải nghiệm',
            ),
            _buildSection(
              '7. Thay đổi chính sách',
              'Chúng tôi có thể cập nhật chính sách này theo thời gian. Chúng tôi sẽ thông báo cho bạn về các thay đổi quan trọng.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Liên hệ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nếu bạn có câu hỏi về chính sách bảo mật, vui lòng liên hệ:\n'
                    'Email: privacy@foodie.app\n'
                    'Điện thoại: 1900-xxxx',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
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

