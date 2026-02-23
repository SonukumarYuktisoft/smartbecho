import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';

class InventoryManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<InventoryController>(InventoryController(), permanent: false);
  }
}
