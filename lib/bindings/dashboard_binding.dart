import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/controllers/user_prefs_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Put controllers needed for home and main app
    Get.put<DashboardController>(DashboardController());
    Get.put<UserPrefsController>(UserPrefsController(), permanent: true);
    Get.put<AuthController>(AuthController());
    // Add other controllers as needed
  }
}
