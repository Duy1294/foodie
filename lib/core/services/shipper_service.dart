import '../constants/api_constants.dart';
import 'api_service.dart';

class ShipperService {
  final ApiService _apiService = ApiService();

  /// Get current shipper profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.shipperProfile);
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Update vehicle info
  Future<Map<String, dynamic>> updateVehicleInfo({
    String? vehicleType,
    String? licensePlate,
    String? vehicleBrand,
    String? vehicleModel,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (vehicleType != null) data['vehicleType'] = vehicleType;
      if (licensePlate != null) data['licensePlate'] = licensePlate;
      if (vehicleBrand != null) data['vehicleBrand'] = vehicleBrand;
      if (vehicleModel != null) data['vehicleModel'] = vehicleModel;

      final response = await _apiService.put(
        ApiConstants.shipperVehicle,
        data: data,
      );

      final responseData = response.data;
      if (responseData is Map && responseData.containsKey('data')) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Update current location
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.shipperLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Update online status
  Future<bool> updateOnlineStatus(bool isOnline) async {
    try {
      final response = await _apiService.put(
        ApiConstants.shipperOnlineStatus,
        data: {
          'isOnline': isOnline,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final statusData = data['data'] as Map<String, dynamic>;
        return statusData['isOnline'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Update notification settings
  Future<Map<String, dynamic>> updateNotificationSettings(bool notificationEnabled) async {
    try {
      final response = await _apiService.put(
        ApiConstants.shipperNotificationSettings,
        data: {
          'notificationEnabled': notificationEnabled,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Update working hours
  Future<Map<String, dynamic>> updateWorkingHours(Map<String, Map<String, String>> workingHours) async {
    try {
      final response = await _apiService.put(
        ApiConstants.shipperWorkingHours,
        data: {
          'workingHours': workingHours,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Update delivery areas
  Future<Map<String, dynamic>> updateDeliveryAreas(List<String> deliveryAreas) async {
    try {
      final response = await _apiService.put(
        ApiConstants.shipperDeliveryAreas,
        data: {
          'deliveryAreas': deliveryAreas,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }
}

