import 'package:json_annotation/json_annotation.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  final String id;
  final String name;
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? coverImageUrl;
  final double deliveryFee;
  final double minimumOrder;
  final double ratingAverage;
  final int ratingCount;
  final bool isActive;
  final bool isVerified;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic>? openingHours;
  final DateTime createdAt;

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.logoUrl,
    this.coverImageUrl,
    this.deliveryFee = 0,
    this.minimumOrder = 0,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.isActive = true,
    this.isVerified = false,
    this.openingHours,
    required this.createdAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);
  Map<String, dynamic> toJson() => _$RestaurantToJson(this);

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? logoUrl,
    String? coverImageUrl,
    double? deliveryFee,
    double? minimumOrder,
    double? ratingAverage,
    int? ratingCount,
    bool? isActive,
    bool? isVerified,
    Map<String, dynamic>? openingHours,
    DateTime? createdAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      openingHours: openingHours ?? this.openingHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

