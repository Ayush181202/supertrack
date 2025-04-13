import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF007BFF);
  static const Color secondary = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color accent = Color(0xFFFFB049);
  static const Color protein = Color(0xFF28A745);
  static const Color carbs = Color(0xFFFFC107);
  static const Color fat = Color(0xFFFF6B6B);
  static const Color water = Color(0xFF17A2B8);
}

class AppTextStyles {
  static const TextStyle headerLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle headerMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle headerSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textDark,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppBorderRadius {
  static final BorderRadius xs = BorderRadius.circular(4);
  static final BorderRadius sm = BorderRadius.circular(8);
  static final BorderRadius md = BorderRadius.circular(12);
  static final BorderRadius lg = BorderRadius.circular(16);
  static final BorderRadius xl = BorderRadius.circular(24);
}

class AppShadows {
  static final BoxShadow small = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  static final BoxShadow medium = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
  
  static final BoxShadow large = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
} 