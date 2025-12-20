import 'package:flutter/material.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

class SettingsService {
  final StorageService _storage = StorageService();

  // Theme Mode
  Future<ThemeMode> getThemeMode() async {
    try {
      final themeString = await _storage.getString(AppConstants.keyTheme);
      if (themeString == null) return ThemeMode.system;
      
      switch (themeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeString = 'system';
    }
    await _storage.setString(AppConstants.keyTheme, themeString);
  }

  // Language
  Future<String> getLanguage() async {
    try {
      final language = await _storage.getString(AppConstants.keyLanguage);
      return language ?? 'vi'; // Default to Vietnamese
    } catch (e) {
      return 'vi';
    }
  }

  Future<void> setLanguage(String languageCode) async {
    await _storage.setString(AppConstants.keyLanguage, languageCode);
  }

  // Notifications
  Future<bool> getNotificationEnabled() async {
    try {
      final enabled = _storage.getString('notification_enabled');
      return enabled != 'false'; // Default to true
    } catch (e) {
      return true;
    }
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await _storage.setString('notification_enabled', enabled.toString());
  }

  // Privacy settings
  Future<Map<String, bool>> getPrivacySettings() async {
    try {
      return {
        'shareLocation': _storage.getString('privacy_share_location') != 'false',
        'shareProfile': _storage.getString('privacy_share_profile') != 'false',
        'analytics': _storage.getString('privacy_analytics') != 'false',
      };
    } catch (e) {
      return {
        'shareLocation': true,
        'shareProfile': true,
        'analytics': true,
      };
    }
  }

  Future<void> setPrivacySetting(String key, bool value) async {
    await _storage.setString('privacy_$key', value.toString());
  }
}

