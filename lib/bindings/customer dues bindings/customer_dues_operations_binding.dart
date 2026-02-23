import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_due_operations_controller.dart';

class CustomerDuesOperationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddDuesController>(AddDuesController(),permanent: false);
  }
}
