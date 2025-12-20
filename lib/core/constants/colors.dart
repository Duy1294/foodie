import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF6B35); // Orange
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8C5A);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4ECDC4); // Teal
  static const Color secondaryDark = Color(0xFF3BA39C);
  static const Color secondaryLight = Color(0xFF6ED9D1);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFD93D); // Yellow
  static const Color error = Color(0xFFE74C3C); // Red
  static const Color success = Color(0xFF27AE60); // Green
  static const Color warning = Color(0xFFF39C12); // Orange
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFADB5BD);
  static const Color textDark = Color(0xFF000000);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFDEE2E6);
  static const Color borderDark = Color(0xFF495057);
  
  // Rating Colors
  static const Color rating = Color(0xFFFFC107); // Gold
  
  // Status Colors
  static const Color statusPending = Color(0xFFF39C12);
  static const Color statusConfirmed = Color(0xFF3498DB);
  static const Color statusPreparing = Color(0xFF9B59B6);
  static const Color statusReady = Color(0xFF1ABC9C);
  static const Color statusDelivered = Color(0xFF27AE60);
  static const Color statusCancelled = Color(0xFFE74C3C);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

