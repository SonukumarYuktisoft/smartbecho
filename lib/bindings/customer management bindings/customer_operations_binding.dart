import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_opeartions_controller.dart';

class CustomerOperationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerOperationsController>(CustomerOperationsController(),permanent: false);
  }
}
