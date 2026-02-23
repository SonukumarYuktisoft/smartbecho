import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  
  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  
  // Getter for theme mode
  ThemeMode get themeMode => _themeMode.value;
  
  // Observable for current theme brightness
  final RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
    
    // Listen to system theme changes
    ever(_themeMode, (ThemeMode mode) {
      _updateDarkMode();
    });
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        _themeMode.value = _parseThemeMode(savedTheme);
      }
      
      _updateDarkMode();
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  // Parse ThemeMode from string
  ThemeMode _parseThemeMode(String theme) {
    switch (theme) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }

  // Update dark mode status based on current theme and system settings
  void _updateDarkMode() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        _isDarkMode.value = false;
        break;
      case ThemeMode.dark:
        _isDarkMode.value = true;
        break;
      case ThemeMode.system:
        _isDarkMode.value = Get.isPlatformDarkMode;
        break;
    }
  }

  // Switch to light theme
  Future<void> setLightTheme() async {
    _themeMode.value = ThemeMode.light;
    Get.changeThemeMode(ThemeMode.light);
    await _saveThemeToPrefs(ThemeMode.light);
    
    Get.snackbar(
      'Theme Changed',
      'Switched to Light Theme',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.grey[100],
      colorText: Colors.black87,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Switch to dark theme
  Future<void> setDarkTheme() async {
    _themeMode.value = ThemeMode.dark;
    Get.changeThemeMode(ThemeMode.dark);
    await _saveThemeToPrefs(ThemeMode.dark);
    
    Get.snackbar(
      'Theme Changed',
      'Switched to Dark Theme',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Switch to system theme
  Future<void> setSystemTheme() async {
    _themeMode.value = ThemeMode.system;
    Get.changeThemeMode(ThemeMode.system);
    await _saveThemeToPrefs(ThemeMode.system);
    
    Get.snackbar(
      'Theme Changed',
      'Switched to System Theme',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.isPlatformDarkMode ? Colors.grey[800] : Colors.grey[100],
      colorText: Get.isPlatformDarkMode ? Colors.white : Colors.black87,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      await setDarkTheme();
    } else {
      await setLightTheme();
    }
  }

  // Get theme mode icon based on current theme
  IconData getThemeIcon() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
      default:
        return Icons.brightness_auto;
    }
  }

  // Get theme mode name
  String getThemeName() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }

  // Check if current theme is specific mode
  bool isLightTheme() => _themeMode.value == ThemeMode.light;
  bool isDarkThemeMode() => _themeMode.value == ThemeMode.dark;
  bool isSystemTheme() => _themeMode.value == ThemeMode.system;
}