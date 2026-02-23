import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';

class CustomerManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerController>(CustomerController(),permanent: false);
  }
}
