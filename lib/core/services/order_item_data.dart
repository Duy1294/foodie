class OrderItemData {
  final String menuItemId;
  final int quantity;
  final double unitPrice;
  final String? specialInstructions;

  OrderItemData({
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    this.specialInstructions,
  });
}

