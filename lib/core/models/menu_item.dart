import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

@JsonSerializable()
class MenuItem {
  final String id;
  final String restaurantId;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final bool isPopular;
  final DateTime createdAt;

  MenuItem({
    required this.id,
    required this.restaurantId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.isPopular = false,
    required this.createdAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    bool? isPopular,
    DateTime? createdAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

