import 'package:flutter/material.dart';

/// Service Hub color palette (matches the design: #FFC107, #0D1B2A, #1E293B, #10B981, #FFFFFF)
class AppColors {
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkBg = Color(0xFF0D1B2A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color success = Color(0xFF10B981);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color danger = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryYellow,
        primary: AppColors.primaryYellow,
        secondary: AppColors.darkBg,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: AppColors.darkBg,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      fontFamily: 'Roboto',
    );
  }
}

/// Fixed list of service categories shown on "Select Service".
/// Extend this list any time — no backend change needed.
class ServiceCategory {
  final String name;
  final IconData icon;
  final String description;

  const ServiceCategory(this.name, this.icon, [this.description = '']);
}

const List<ServiceCategory> kServiceCategories = [
  ServiceCategory('Plumber', Icons.plumbing),
  ServiceCategory('Electrician', Icons.electrical_services),
  ServiceCategory('Driver', Icons.local_taxi),
  ServiceCategory('Carpenter', Icons.carpenter),
  ServiceCategory('Painter', Icons.format_paint),
  ServiceCategory('More', Icons.apps),
];

/// Firestore collection names — kept in one place so they never typo.
class Col {
  static const users = 'users';
  static const providers = 'providers';
  static const bookings = 'bookings';
}
