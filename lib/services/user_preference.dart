import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  // Keys for different view preferences
  static const String _isTopStatGridViewKey = 'is_top_stat_grid_view';
  static const String _isInventorySummaryGridViewKey = 'is_inventory_summary_grid_view';
  
  static UserPreferences? _instance;
  static SharedPreferences? _prefs;
  
  UserPreferences._();
  
  static Future<UserPreferences> getInstance() async {
    _instance ??= UserPreferences._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // TOP STATS PREFERENCES
  // Get top stats grid view preference (default to true for grid view)
  bool get isTopStatGridView => _prefs?.getBool(_isTopStatGridViewKey) ?? true;
  
  // Set top stats grid view preference
  Future<bool> setTopStatGridView(bool value) async {
    return await _prefs?.setBool(_isTopStatGridViewKey, value) ?? false;
  }
  
  // Toggle between grid and list view for top stats
  Future<bool> toggleTopStatViewMode() async {
    bool currentMode = isTopStatGridView;
    return await setTopStatGridView(!currentMode);
  }
  
  // INVENTORY SUMMARY PREFERENCES
  // Get inventory summary grid view preference (default to true for grid view)
  bool get isInventorySummaryGridView => _prefs?.getBool(_isInventorySummaryGridViewKey) ?? true;
  
  // Set inventory summary grid view preference
  Future<bool> setInventorySummaryGridView(bool value) async {
    return await _prefs?.setBool(_isInventorySummaryGridViewKey, value) ?? false;
  }
  
  // Toggle between grid and list view for inventory summary
  Future<bool> toggleInventorySummaryViewMode() async {
    bool currentMode = isInventorySummaryGridView;
    return await setInventorySummaryGridView(!currentMode);
  }
}