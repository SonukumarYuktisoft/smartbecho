import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/controllers/auth%20controllers/otp_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  
  }
}
