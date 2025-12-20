import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String id;
  final String userId;
  final String label;
  final String fullAddress;
  final String? street;
  final String? ward;
  final String? district;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? recipientName;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullAddress,
    this.street,
    this.ward,
    this.district,
    this.city,
    this.latitude,
    this.longitude,
    this.phone,
    this.recipientName,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  Address copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullAddress,
    String? street,
    String? ward,
    String? district,
    String? city,
    double? latitude,
    double? longitude,
    String? phone,
    String? recipientName,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      recipientName: recipientName ?? this.recipientName,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

