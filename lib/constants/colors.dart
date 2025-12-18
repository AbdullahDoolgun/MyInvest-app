import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A1930); // Deep Navy Blue
  static const Color primaryLight = Color(0xFF152C4E); // Lighter Navy
  static const Color accent = Color(0xFF1E88E5); // Blue Accent
  static const Color background = Color(0xFFF5F7FA); // Light Grayish Blue
  static const Color surface = Colors.white;

  // Stock Colors
  static const Color up = Color(0xFF00C853); // Vibrant Green
  static const Color upLight = Color(0xFFE8F5E9); // Light Green bg
  static const Color down = Color(0xFFD50000); // Vibrant Red
  static const Color downLight = Color(0xFFFFEBEE); // Light Red bg
  static const Color neutral = Color(0xFF757575); // Grey
  static const Color neutralLight = Color(0xFFF5F5F5);

  static const Color textPrimary = Color(0xFF0A1930);
  static const Color textSecondary = Color(0xFF78909C);

  // Light Theme Scheme
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: Colors.white,
    surface: surface,
    onSurface: textPrimary,
    error: down,
    onError: Colors.white,
    outline: Colors.grey,
  );

  // Dark Theme Scheme
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.white, // Inverted from Navy
    onPrimary: primary, // Navy text on White primary (if used)
    secondary: accent,
    onSecondary: Colors.white,
    surface: primary, // Navy background for surface
    onSurface: Colors.white, // White text on Navy surface
    error: down,
    onError: Colors.white,
    outline: Colors.white24,
  );
}
