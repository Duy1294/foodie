import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

// Helper function for enum decoding - compatible with json_serializable
T $enumDecode<T extends Enum>(
  Map<T, String> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  final sourceString = source.toString();
  for (final MapEntry<T, String> entry in enumValues.entries) {
    if (entry.value == sourceString) {
      return entry.key;
    }
  }

  if (unknownValue != null) {
    return unknownValue;
  }

  throw ArgumentError(
    '`$source` is not one of the supported values: '
    '${enumValues.values.join(', ')}',
  );
}

enum UserRole {
  @JsonValue('customer')
  customer,
  @JsonValue('restaurant_owner')
  restaurantOwner,
  @JsonValue('driver')
  driver,
  @JsonValue('admin')
  admin,
}

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

