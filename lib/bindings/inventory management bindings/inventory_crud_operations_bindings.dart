import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/Inventory_crud_operation_controller.dart';

class InventoryCrudOperationsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<InventoryCrudOperationController>(InventoryCrudOperationController(), permanent: false);
  }
}
