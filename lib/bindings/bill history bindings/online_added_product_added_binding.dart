import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';
import 'package:smartbecho/controllers/inventory%20controllers/add_new_stock_operation_controller.dart';

class OnlineAddedProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<OnlineProductsController>(OnlineProductsController(), permanent: false);
  }
}
