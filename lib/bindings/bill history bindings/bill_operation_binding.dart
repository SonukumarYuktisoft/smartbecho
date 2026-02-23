import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/add_new_stock_operation_controller.dart';

class AddNewStockOperationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddNewStockOperationController>(AddNewStockOperationController(),permanent: false);
  }
}
