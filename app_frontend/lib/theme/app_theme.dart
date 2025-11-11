import 'package:flutter/material.dart';

/// App Theme for Food Delivery Application
/// Uses warm colors representative of the local restaurant
class AppTheme {
  // Primary Colors - Warm Red Theme (typical for restaurants/food businesses)
  static const Color primary = Color(0xFFD32F2F); // Deep Red
  static const Color primaryLight = Color(0xFFEF5350); // Light Red
  static const Color primaryDark = Color(0xFFC62828); // Dark Red
  static const Color primaryVeryLight = Color(0xFFFFEBEE); // Very Light Red
  
  // Secondary Colors - Warm Orange/Yellow for food-related actions
  static const Color secondary = Color(0xFFFFA726); // Warm Orange
  static const Color secondaryLight = Color(0xFFFFB74D); // Light Orange
  static const Color secondaryDark = Color(0xFFF57C00); // Dark Orange
  
  // Accent Colors - Golden/Yellow for highlights
  static const Color accent = Color(0xFFFFB300); // Amber/Golden
  static const Color accentLight = Color(0xFFFFCA28); // Light Amber
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green 500
  static const Color warning = Color(0xFFFFA726); // Warm Orange
  static const Color error = Color(0xFFD32F2F); // Red (matching primary)
  static const Color info = Color(0xFFFFB300); // Golden (matching accent)
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5); // Grey 100
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFFAFAFA); // Grey 50
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Grey 900
  static const Color textSecondary = Color(0xFF757575); // Grey 600
  static const Color textHint = Color(0xFF9E9E9E); // Grey 500
  static const Color textOnPrimary = Colors.white;
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0); // Grey 300
  static const Color divider = Color(0xFFBDBDBD); // Grey 400

  /// Main App Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: primaryLight,
        secondary: secondary,
        secondaryContainer: secondaryLight,
        tertiary: accent,
        tertiaryContainer: accentLight,
        surface: surface,
        surfaceContainerHighest: surfaceVariant,
        error: error,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onError: textOnPrimary,
      ),
      
      // Primary Color Swatch
      primaryColor: primary,
      primaryColorLight: primaryLight,
      primaryColorDark: primaryDark,
      
      // Scaffold
      scaffoldBackgroundColor: background,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textOnPrimary,
        titleTextStyle: TextStyle(
          color: textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        iconTheme: IconThemeData(color: textOnPrimary),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: textOnPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textHint),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: primaryVeryLight,
        deleteIconColor: primary,
        labelStyle: const TextStyle(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primaryVeryLight,
        circularTrackColor: primaryVeryLight,
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: textSecondary,
        textColor: textPrimary,
      ),
    );
  }

  /// Helper method to create gradient for AppBars and Cards
  static LinearGradient get primaryGradient {
    return const LinearGradient(
      colors: [primary, primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Helper method to create gradient for secondary elements
  static LinearGradient get secondaryGradient {
    return const LinearGradient(
      colors: [secondary, secondaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Helper method to create light background gradient
  static LinearGradient get backgroundGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primaryVeryLight, surface],
    );
  }

  /// Helper method for shadow decorations
  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Helper method for elevated shadow decorations
  static List<BoxShadow> get elevatedShadow {
    return [
      BoxShadow(
        color: primary.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textHint,
  );
}
