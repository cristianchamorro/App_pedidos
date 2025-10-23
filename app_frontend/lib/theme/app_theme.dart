import 'package:flutter/material.dart';

/// Tema de la aplicación con colores azules frescos
/// Este archivo centraliza todos los colores y estilos de la app
class AppTheme {
  // ============= COLORES PRINCIPALES =============
  
  /// Color primario - Azul vibrante y fresco
  static const Color primaryColor = Color(0xFF1E88E5); // Azul brillante
  
  /// Color primario claro - Para gradientes y fondos
  static const Color primaryLightColor = Color(0xFF64B5F6); // Azul claro
  
  /// Color primario oscuro - Para contraste
  static const Color primaryDarkColor = Color(0xFF1565C0); // Azul oscuro
  
  /// Color de acento - Azul cyan para elementos destacados
  static const Color accentColor = Color(0xFF00BCD4); // Cyan
  
  /// Color de fondo - Azul muy claro
  static const Color backgroundColor = Color(0xFFE3F2FD); // Azul suave
  
  // ============= COLORES SECUNDARIOS =============
  
  /// Color de éxito - Verde
  static const Color successColor = Color(0xFF4CAF50);
  
  /// Color de advertencia - Naranja
  static const Color warningColor = Color(0xFFFF9800);
  
  /// Color de error - Rojo
  static const Color errorColor = Color(0xFFF44336);
  
  /// Color de información - Azul claro
  static const Color infoColor = Color(0xFF03A9F4);
  
  // ============= COLORES PARA ROLES =============
  
  /// Color para módulo de cajero - Azul
  static const Color cashierColor = Color(0xFF1E88E5);
  
  /// Color para módulo de cocinero - Verde azulado
  static const Color cookColor = Color(0xFF00897B);
  
  /// Color para módulo de domiciliario - Cyan
  static const Color deliveryColor = Color(0xFF00BCD4);
  
  /// Color para usuario normal - Azul claro
  static const Color userColor = Color(0xFF42A5F5);
  
  // ============= GRADIENTES =============
  
  /// Gradiente principal de la app
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente secundario
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, primaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente para cajero
  static const LinearGradient cashierGradient = LinearGradient(
    colors: [cashierColor, primaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente para cocinero
  static const LinearGradient cookGradient = LinearGradient(
    colors: [cookColor, Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente para domiciliario
  static const LinearGradient deliveryGradient = LinearGradient(
    colors: [deliveryColor, Color(0xFF4DD0E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============= TEMA MATERIAL =============
  
  /// Tema principal de la aplicación
  static ThemeData get theme {
    return ThemeData(
      // Colores principales
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // Color scheme
      colorScheme: const ColorScheme(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryDarkColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryDarkColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: primaryColor.withOpacity(0.2),
        thickness: 1,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: primaryLightColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: primaryDarkColor),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  // ============= DECORACIONES REUTILIZABLES =============
  
  /// Decoración para AppBar con gradiente
  static BoxDecoration appBarDecoration = const BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(20),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  /// Decoración para cards con gradiente suave
  static BoxDecoration cardGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        primaryLightColor.withOpacity(0.2),
        Colors.white,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(15),
  );
  
  /// Shadow para elementos elevados
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Decoración para botones con gradiente
  static BoxDecoration buttonGradientDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // ============= ESTILOS DE TEXTO =============
  
  /// Estilo para títulos de AppBar
  static const TextStyle appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    letterSpacing: 1.2,
  );
  
  /// Estilo para botones principales
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  /// Estilo para títulos de secciones
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryDarkColor,
  );
  
  /// Estilo para subtítulos
  static TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey.shade600,
  );
  
  // ============= MÉTODOS DE UTILIDAD =============
  
  /// Obtiene el color según el rol del usuario
  static Color getColorByRole(String role) {
    switch (role.toLowerCase()) {
      case 'cajero':
        return cashierColor;
      case 'cocinero':
        return cookColor;
      case 'domiciliario':
        return deliveryColor;
      case 'user':
      case 'usuario':
        return userColor;
      default:
        return primaryColor;
    }
  }
  
  /// Obtiene el gradiente según el rol del usuario
  static LinearGradient getGradientByRole(String role) {
    switch (role.toLowerCase()) {
      case 'cajero':
        return cashierGradient;
      case 'cocinero':
        return cookGradient;
      case 'domiciliario':
        return deliveryGradient;
      default:
        return primaryGradient;
    }
  }
  
  /// Crea un contenedor con icono circular
  static Widget iconContainer({
    required IconData icon,
    Color? color,
    double size = 24,
    double padding = 12,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: (color ?? primaryColor).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color ?? primaryColor,
        size: size,
      ),
    );
  }
  
  /// Crea un badge con contador
  static Widget badge({
    required String count,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? errorColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
