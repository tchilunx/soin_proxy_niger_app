import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Primary colors (Teal - matching Rails admin SoinProxi-Niger)
  // Palette alignée au logo SoinProxi-Niger (teal)
  static const Color primaryColor = Color(0xFF14B8A6); // primary-500
  static const Color primaryLight = Color(0xFF2DD4BF); // primary-400
  static const Color primaryDark = Color(0xFF0D9488); // primary-600
  static const Color primary50 = Color(0xFFF0FDFA);
  static const Color primary100 = Color(0xFFCCFBF1);
  static const Color primary200 = Color(0xFF99F6E4);
  static const Color primary300 = Color(0xFF5EEAD4);
  static const Color primary700 = Color(0xFF0F766E);
  static const Color primary800 = Color(0xFF115E59);
  static const Color primary900 = Color(0xFF134E4A);

  // Accent colors (Orange - matching Rails admin SoinProxi-Niger)
  // Palette alignée au logo SoinProxi-Niger (orange)
  static const Color accentColor = Color(0xFFF97316); // accent-500
  static const Color accentLight = Color(0xFFFB923C); // accent-400
  static const Color accentDark = Color(0xFFEA580C); // accent-600
  static const Color accent50 = Color(0xFFFFF7ED);
  static const Color accent100 = Color(0xFFFFEDD5);
  static const Color accent200 = Color(0xFFFED7AA);
  static const Color accent300 = Color(0xFFFDBA74);
  static const Color accent700 = Color(0xFFC2410C);
  static const Color accent800 = Color(0xFF9A3412);
  static const Color accent900 = Color(0xFF7C2D12);

  // Secondary colors (using accent orange as secondary)
  static const Color secondaryColor = accentColor;
  static const Color secondaryLight = accentLight;
  static const Color secondaryDark = accentDark;

  // Neutral colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Role colors (using brand colors)
  static const Color patientColor = primaryColor; // Teal
  static const Color doctorColor = primaryDark; // Darker Teal
  static const Color nurseColor = accentColor; // Orange

  // Status badge colors (matching Rails admin)
  static const Map<String, Color> statusColors = {
    'pending': Color(0xFF64748B), // slate-500
    'assigned': Color(0xFF3B82F6), // blue-500
    'accepted': Color(0xFF06B6D4), // cyan-500
    'on_route': Color(0xFF8B5CF6), // violet-500
    'in_progress': Color(0xFFF59E0B), // amber-500
    'completed': Color(0xFF10B981), // emerald-500
    'cancelled': Color(0xFFEF4444), // rose-500
  };

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [accentColor, primaryColor], // Orange to Teal gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Login/Register gradient (Orange + Teal)
  static const LinearGradient authGradient = LinearGradient(
    colors: [accentColor, primaryColor], // Orange to Teal
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient doctorGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nurseGradient = LinearGradient(
    colors: [accentColor, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor, // Use orange as seed color
        brightness: Brightness.light,
        primary: accentColor, // Use orange as primary
        secondary: primaryColor, // Use teal as secondary
        surface: surfaceColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accentColor, // Use orange for buttons
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor, // Use orange for outlined buttons
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: accentColor),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor, // Use orange for text buttons
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2), // Use orange for focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: textHint),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor, // Use orange for selected items
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor, // Use orange for FAB
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textHint,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }
}

