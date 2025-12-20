import '../models/address.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AddressService {
  final ApiService _apiService = ApiService();

  Future<List<Address>> getAddresses() async {
    try {
      final response = await _apiService.get(ApiConstants.addresses);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final addressesList = data['data'] as List;
        return addressesList.map((json) {
          final addressJson = json as Map<String, dynamic>;
          return Address.fromJson(addressJson);
        }).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Address> getAddressById(String addressId) async {
    try {
      final response = await _apiService.get(ApiConstants.addressDetail(addressId));
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final addressJson = data['data'] as Map<String, dynamic>;
        return Address.fromJson(addressJson);
      }
      throw Exception('Address not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<Address> createAddress({
    required String label,
    required String fullAddress,
    String? street,
    String? ward,
    String? district,
    String? city,
    double? latitude,
    double? longitude,
    String? phone,
    String? recipientName,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.addresses,
        data: {
          'label': label,
          'fullAddress': fullAddress,
          if (street != null) 'street': street,
          if (ward != null) 'ward': ward,
          if (district != null) 'district': district,
          if (city != null) 'city': city,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (phone != null) 'phone': phone,
          if (recipientName != null) 'recipientName': recipientName,
          'isDefault': isDefault,
        },
      );
      
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final addressJson = data['data'] as Map<String, dynamic>;
        return Address.fromJson(addressJson);
      }
      throw Exception('Failed to create address');
    } catch (e) {
      rethrow;
    }
  }

  Future<Address> updateAddress({
    required String addressId,
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
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.addressDetail(addressId),
        data: {
          if (label != null) 'label': label,
          if (fullAddress != null) 'fullAddress': fullAddress,
          if (street != null) 'street': street,
          if (ward != null) 'ward': ward,
          if (district != null) 'district': district,
          if (city != null) 'city': city,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (phone != null) 'phone': phone,
          if (recipientName != null) 'recipientName': recipientName,
          if (isDefault != null) 'isDefault': isDefault,
        },
      );
      
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final addressJson = data['data'] as Map<String, dynamic>;
        return Address.fromJson(addressJson);
      }
      throw Exception('Failed to update address');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _apiService.delete(ApiConstants.addressDetail(addressId));
    } catch (e) {
      rethrow;
    }
  }
}

