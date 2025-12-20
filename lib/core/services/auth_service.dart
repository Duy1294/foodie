import 'dart:convert';
import '../models/user.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    // Load user from storage
    final userJson = _storage.getString(AppConstants.keyUser);
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
      } catch (e) {
        // Invalid user data, clear it
        await logout();
      }
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final userJson = data['user'] as Map<String, dynamic>;

      // Save tokens
      await _storage.setSecureString(AppConstants.keyToken, token);
      if (refreshToken != null) {
        await _storage.setSecureString(
          AppConstants.keyRefreshToken,
          refreshToken,
        );
      }

      // Save user
      _currentUser = User.fromJson(userJson);
      await _storage.setString(
        AppConstants.keyUser,
        jsonEncode(userJson),
      );

      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          if (phone != null) 'phone': phone,
        },
      );

      final data = response.data;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final userJson = data['user'] as Map<String, dynamic>;

      // Save tokens
      await _storage.setSecureString(AppConstants.keyToken, token);
      if (refreshToken != null) {
        await _storage.setSecureString(
          AppConstants.keyRefreshToken,
          refreshToken,
        );
      }

      // Save user
      _currentUser = User.fromJson(userJson);
      await _storage.setString(
        AppConstants.keyUser,
        jsonEncode(userJson),
      );

      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (e) {
      // Ignore errors on logout
    } finally {
      _currentUser = null;
      await _storage.remove(AppConstants.keyToken);
      await _storage.remove(AppConstants.keyRefreshToken);
      await _storage.remove(AppConstants.keyUser);
    }
  }

  Future<void> forgotPassword(String email) async {
    await _apiService.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiService.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'password': newPassword,
      },
    );
  }

  /// Set current user (used by Firebase Auth Service)
  void setCurrentUser(User user) {
    _currentUser = user;
  }
}

