import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/product_return_controller.dart';

class ProductReturnBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProductReturnController>(ProductReturnController(), permanent: false);
  }
}

