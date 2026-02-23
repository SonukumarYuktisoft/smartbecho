import 'package:get/get.dart';
import 'package:smartbecho/services/user_preference.dart';

class UserPrefsController extends GetxController{
   // Existing variable for top stats
  RxBool isTopStatGridView = true.obs;
  
  // New variable for inventory summary
  RxBool isInventorySummaryGridView = true.obs;
  
  // Initialize preferences method
  Future<void> initializePreferences() async {
    final prefs = await UserPreferences.getInstance();
    
    // Initialize both view preferences
    isTopStatGridView.value = prefs.isTopStatGridView;
    isInventorySummaryGridView.value = prefs.isInventorySummaryGridView;
  }
  
  // Toggle method for top stats (update your existing method)
  Future<void> toggleTopStatViewMode() async {
    final prefs = await UserPreferences.getInstance();
    await prefs.toggleTopStatViewMode();
    isTopStatGridView.value = prefs.isTopStatGridView;
  }
  
  // New toggle method for inventory summary
  Future<void> toggleInventorySummaryViewMode() async {
    final prefs = await UserPreferences.getInstance();
    await prefs.toggleInventorySummaryViewMode();
    isInventorySummaryGridView.value = prefs.isInventorySummaryGridView;
  }
  
  @override
  void onInit() {
    super.onInit();
    initializePreferences();
  }
}