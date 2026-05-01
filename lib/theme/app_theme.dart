import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color darkBackground = Color(0xFF09090B);

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    final poppins = GoogleFonts.poppinsTextTheme(base);

    return poppins.copyWith(
      displayLarge: poppins.displayLarge?.copyWith(
        fontSize: 34,
        height: 1.15,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: poppins.displayMedium?.copyWith(
        fontSize: 30,
        height: 1.16,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: poppins.displaySmall?.copyWith(
        fontSize: 26,
        height: 1.18,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: poppins.headlineLarge?.copyWith(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: poppins.headlineMedium?.copyWith(
        fontSize: 22,
        height: 1.22,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: poppins.headlineSmall?.copyWith(
        fontSize: 20,
        height: 1.24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: poppins.titleLarge?.copyWith(
        fontSize: 19,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: poppins.titleMedium?.copyWith(
        fontSize: 17,
        height: 1.28,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: poppins.titleSmall?.copyWith(
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: poppins.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: poppins.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.42,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: poppins.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: poppins.labelLarge?.copyWith(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: poppins.labelMedium?.copyWith(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: poppins.labelSmall?.copyWith(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      outline: const Color(0xFFE5E7EB),
    ),
    scaffoldBackgroundColor: lightBackground,
    textTheme: _buildTextTheme(Brightness.light),
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF6B7280),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF111827),
      outline: const Color(0xFF374151),
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: _buildTextTheme(Brightness.dark),
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF111827),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF374151)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Color(0xFF111827),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}
