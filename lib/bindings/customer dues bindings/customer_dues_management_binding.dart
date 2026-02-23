import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';

class CustomerDuesManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerDuesController>(CustomerDuesController(),permanent: false);
  }
}
