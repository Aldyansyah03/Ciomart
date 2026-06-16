import 'package:flutter/material.dart';

class AppColors {
  static const Color brandCream = Color(0xFFFEF3E2);
  static const Color brandYellow = Color(0xFFFAB12F);
  static const Color brandOrange = Color(0xFFFA812F);
  static const Color brandRed = Color(0xFFDD0303);
  
  static const Color background = brandCream;
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  
  static const Color success = brandYellow;
  static const Color warning = brandOrange;
  static const Color danger = brandRed;
}

class ApiConstants {
  // Use online Render backend URL
  static const String baseUrl = 'https://ciomart-backend.onrender.com/api';
}

class AppConstants {
  static const double taxRate = 0.10; // 10% PPN
}
