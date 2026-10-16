import 'package:flutter/material.dart';

/// Centralized color palette for TBC Digital App
class AppColors {
  AppColors._();

  // Primary Theme Colors
  static const Color primary = Color(0xFF7FB77E);
  static const Color primaryLight = Color(0xFF9ED69E);
  static const Color primaryDark = Color(0xFF5B9E5A);
  static const Color primaryUltraLight = Color(0xFFE8F5E9);

  // Backgrounds
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundAlt = Color(0xFFF5F7FB);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textMuted = Color(0xFF95A5A6);

  // Status & Feedback Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFFE8F8F5);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF9E7);
  static const Color danger = Color(0xFFE74C3C);
  static const Color dangerLight = Color(0xFFFDEDEC);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFEBF5FB);

  // Borders & Dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

