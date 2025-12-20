class VietQRService {
  // MB Bank configuration
  // acqId: Mã ngân hàng theo chuẩn VietQR
  // MB Bank (Military Commercial Bank) có acqId = 970422
  static const String acqId = '970422'; // MB Bank acqId
  static const String accountNo = '0398559657';
  static const String accountName = 'FOODIE APP';
  static const String template = 'compact';

  /// Generate VietQR URL for payment
  /// 
  /// [amount] - Số tiền cần thanh toán (VND)
  /// [orderNumber] - Mã đơn hàng để tạo lời nhắn
  static String generateQRUrl({
    required double amount,
    required String orderNumber,
  }) {
    final int amountInt = amount.toInt();
    final String addInfo = 'Thanh toan don hang $orderNumber';
    
    // VietQR API format: https://img.vietqr.io/image/{acqId}-{accountNo}-{template}.png
    // With query parameters: amount, addInfo, accountName
    final Uri qrUri = Uri.parse('https://img.vietqr.io/image/$acqId-$accountNo-$template.png').replace(
      queryParameters: {
        'amount': amountInt.toString(),
        'addInfo': addInfo,
        'accountName': accountName,
      },
    );
    
    final String qrUrl = qrUri.toString();
    print('Generated QR URL: $qrUrl'); // Debug
    
    return qrUrl;
  }

  /// Get payment instructions
  static String getPaymentInstructions(String orderNumber) {
    return '''
📱 Hướng dẫn thanh toán:

1. Mở app ngân hàng hoặc MoMo
2. Chọn chức năng "Quét mã QR"
3. Quét mã QR bên dưới
4. Kiểm tra thông tin:
   - Số tiền: Đúng với đơn hàng
   - Nội dung: Thanh toan don hang $orderNumber
5. Xác nhận thanh toán

💡 Sau khi thanh toán, nhấn nút "Đã thanh toán" để hoàn tất đơn hàng.
    ''';
  }
}

