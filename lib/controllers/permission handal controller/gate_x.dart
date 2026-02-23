import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:smartbecho/controllers/permission%20handal%20controller/feature_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_status.dart';

class GateX {
  static final FeatureController _c = Get.find();

  static bool allow(String feature) {
    return _c.statusOf(feature) == FeatureStatus.allowed;
  }

  static bool locked(String feature) {
    return _c.statusOf(feature) == FeatureStatus.locked;
  }
}
