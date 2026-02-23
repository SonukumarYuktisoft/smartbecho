import 'package:flutter/material.dart';
import 'package:smartbecho/services/configs/theme_config.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF203668);
  // static const Color primaryLight = Color(0xFF4C5EEB);
  static const Color primaryVariantLight = Color(0xFFA29BFE);
  static const Color secondaryLight = Color(0xFF00CEC9);
  static const Color secondaryVariantLight = Color(0xFF55EFC4);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color cardLight = Color(0xFFF8F9FA);
  static const Color onPrimaryLight = Colors.white;
  static const Color onSecondaryLight = Colors.white;
  static const Color onBackgroundLight = Color(0xFF1A1A1A);
  static const Color onSurfaceLight = Color(0xFF2D3436);
  static const Color errorLight = Color(0xFFFF7675);
  static const Color successLight = Color(0xFF00B894);
  static const Color warningLight = Color(0xFFFFB347);
  static const Color infoLight = Color(0xFF74B9FF);

  static const Color authColor = Color(0xFF203668);
  static const Color authColor2 = Color(0xffF47D1B);


  static const Color primary = Color(0xFF4C5EEB);
  static const Color secondary = Color(0xFF6366F1);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimaryC = Color(0xFF1A1A1A);
  static const Color textSecondaryC = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);


   static const MaterialColor primarySwatch = MaterialColor(
    0xFF4C5EEB,
    <int, Color>{
      50:  Color(0xFFEFF1FF),
      100: Color(0xFFD7DBFF),
      200: Color(0xFFB5BCFF),
      300: Color(0xFF939CFF),
      400: Color(0xFF7682FF),
      500: Color(0xFF4C5EEB), // primary
      600: Color(0xFF4456D6),
      700: Color(0xFF3A4BC0),
      800: Color(0xFF303FAA),
      900: Color(0xFF1F2E8C),
    },
  );

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF8B7CF6);
  static const Color primaryVariantDark = Color(0xFFB4A7F7);
  static const Color secondaryDark = Color(0xFF14B8A6);
  static const Color secondaryVariantDark = Color(0xFF5EEAD4);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color onPrimaryDark = Colors.white;
  static const Color onSecondaryDark = Colors.white;
  static const Color onBackgroundDark = Color(0xFFF1F5F9);
  static const Color onSurfaceDark = Color(0xFFE2E8F0);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color successDark = Color(0xFF10B981);
  static const Color warningDark = Color(0xFFF59E0B);
  static const Color infoDark = Color(0xFF3B82F6);

  // Gradient Colors
  static const List<Color> primaryGradientLight = [
    AppColors.primaryLight,
    Color.fromARGB(255, 5, 18, 47),
  ];
  static const List<Color> secondaryGradientLight = [
    Color(0xFF00CEC9),
    Color(0xFF55EFC4),
  ];
  static const List<Color> errorGradientLight = [
    Color(0xFFFF7675),
    Color(0xFFFF9F9F),
  ];
  static const List<Color> successGradientLight = [
    Color(0xFF00B894),
    Color(0xFF55EFC4),
  ];
  static const List<Color> infoGradientLight = [
    Color(0xFF74B9FF),
    Color(0xFF00B894),
  ];

  static const List<Color> primaryGradientDark = [
    Color(0xFF8B7CF6),
    Color(0xFFB4A7F7),
  ];
  static const List<Color> secondaryGradientDark = [
    Color(0xFF14B8A6),
    Color(0xFF5EEAD4),
  ];
  static const List<Color> errorGradientDark = [
    Color(0xFFEF4444),
    Color(0xFFF87171),
  ];
  static const List<Color> successGradientDark = [
    Color(0xFF10B981),
    Color(0xFF6EE7B7),
  ];
  static const List<Color> infoGradientDark = [
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
  ];

  // Border Colors
  static Color borderLight = Colors.grey[300]!;
  static Color borderDark = const Color(0xFF475569);

  // Text Colors
  static Color textPrimaryLight = Colors.black;
  static Color textSecondaryLight = Colors.grey[600]!;
  static Color textHintLight = Colors.grey[500]!;

  static Color textPrimaryDark = const Color(0xFFF1F5F9);
  static Color textSecondaryDark = const Color(0xFFCBD5E1);
  static Color textHintDark = const Color(0xFF94A3B8);

  // Shadow Colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.05);
  static Color shadowDark = Colors.black.withValues(alpha: 0.3);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: surfaceLight,
      background: backgroundLight,
      error: errorLight,
      onPrimary: onPrimaryLight,
      onSecondary: onSecondaryLight,
      onSurface: onSurfaceLight,
      onBackground: onBackgroundLight,
      onError: Colors.white,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: onSurfaceLight,
      elevation: 0,
      shadowColor: shadowLight,
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderLight, width: 1),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      hintStyle: TextStyle(color: textHintLight, fontWeight: FontWeight.w400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: onPrimaryLight,
        elevation: 2,
        shadowColor: shadowLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: onPrimaryLight,
      elevation: 4,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textPrimaryLight,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textPrimaryLight,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: textPrimaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: textSecondaryLight,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: textSecondaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: textHintLight,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Icon Theme
    iconTheme: IconThemeData(color: textPrimaryLight, size: 24),

    // Divider Theme
    dividerTheme: DividerThemeData(color: borderLight, thickness: 1, space: 1),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      background: backgroundDark,
      error: errorDark,
      onPrimary: onPrimaryDark,
      onSecondary: onSecondaryDark,
      onSurface: onSurfaceDark,
      onBackground: onBackgroundDark,
      onError: Colors.white,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: onSurfaceDark,
      elevation: 0,
      shadowColor: shadowDark,
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textPrimaryDark),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 4,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderDark, width: 1),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
      hintStyle: TextStyle(color: textHintDark, fontWeight: FontWeight.w400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: onPrimaryDark,
        elevation: 4,
        shadowColor: shadowDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: onPrimaryDark,
      elevation: 6,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textPrimaryDark,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textPrimaryDark,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: textPrimaryDark,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: textSecondaryDark,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: textSecondaryDark,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: textHintDark,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Icon Theme
    iconTheme: IconThemeData(color: textPrimaryDark, size: 24),

    // Divider Theme
    dividerTheme: DividerThemeData(color: borderDark, thickness: 1, space: 1),
  );

  // Utility methods for gradients
  static LinearGradient getPrimaryGradient(bool isDark) {
    return LinearGradient(
      colors: isDark ? primaryGradientDark : primaryGradientLight,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSecondaryGradient(bool isDark) {
    return LinearGradient(
      colors: isDark ? secondaryGradientDark : secondaryGradientLight,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getErrorGradient(bool isDark) {
    return LinearGradient(
      colors: isDark ? errorGradientDark : errorGradientLight,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSuccessGradient(bool isDark) {
    return LinearGradient(
      colors: isDark ? successGradientDark : successGradientLight,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getInfoGradient(bool isDark) {
    return LinearGradient(
      colors: isDark ? infoGradientDark : infoGradientLight,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Custom BoxShadow
  static List<BoxShadow> getCardShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? shadowDark : shadowLight,
        spreadRadius: 0,
        blurRadius: isDark ? 8 : 10,
        offset: Offset(0, isDark ? 4 : 2),
      ),
    ];
  }

  static List<BoxShadow> getElevatedShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? shadowDark : shadowLight,
        spreadRadius: 0,
        blurRadius: isDark ? 12 : 15,
        offset: Offset(0, isDark ? 6 : 4),
      ),
    ];
  }

  // Helper method to get current theme colors
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getTextPrimary(BuildContext context) {
    return isDarkMode(context) ? textPrimaryDark : textPrimaryLight;
  }

  static Color getTextSecondary(BuildContext context) {
    return isDarkMode(context) ? textSecondaryDark : textSecondaryLight;
  }

  static Color getTextHint(BuildContext context) {
    return isDarkMode(context) ? textHintDark : textHintLight;
  }

  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context) ? borderDark : borderLight;
  }

  static Color getShadowColor(BuildContext context) {
    return isDarkMode(context) ? shadowDark : shadowLight;
  }

  static Color backgroundColor(BuildContext context) =>
      ThemeController().isDarkMode ? Colors.grey[900]! : Colors.white;

  static Color cardBackground(BuildContext context) =>
      ThemeController().isDarkMode ? Colors.grey[850]! : Colors.grey[50]!;

  static Color textPrimary(BuildContext context) =>
      ThemeController().isDarkMode ? Colors.white : Colors.black87;

  static Color textSecondary(BuildContext context) =>
      ThemeController().isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

  static Color borderColor(BuildContext context) =>
      ThemeController().isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

  static Color shadowColor(BuildContext context) =>
      ThemeController().isDarkMode
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.05);

  static Color accentColor(BuildContext context) =>
      ThemeController().isDarkMode ? Color(0xFFA29BFE) : primaryLight;

  // Gradient colors for cards and buttons
  static List<Color> statCardGradient(
    BuildContext context,
    List<Color> lightColors,
  ) {
    if (ThemeController().isDarkMode) {
      return lightColors
          .map((color) => Color.lerp(color, Colors.black, 0.3)!)
          .toList();
    }
    return lightColors;
  }

  static List<Color> actionButtonGradient(
    BuildContext context,
    List<Color> lightColors,
  ) {
    if (ThemeController().isDarkMode) {
      return lightColors
          .map((color) => Color.lerp(color, Colors.black, 0.2)!)
          .toList();
    }
    return lightColors;
  }
}
