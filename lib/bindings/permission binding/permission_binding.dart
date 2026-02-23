
import 'package:get/get.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/feature_controller.dart';

class PermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FeatureController>(FeatureController(), permanent: true);
  }
}