import 'package:get/get.dart';
import 'package:smartbecho/controllers/setting%20controllers/setting_controller.dart';

class ShopSettingBinding extends Bindings {
  @override
  void dependencies() {
    // Put controllers needed for home and main app
    Get.put<ShopSettingsController>(ShopSettingsController(),permanent: true);


  }
}
