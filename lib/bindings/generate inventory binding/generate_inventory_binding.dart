import 'package:get/get.dart';
import 'package:smartbecho/controllers/generate%20inventory%20controller/generate_inventory_controller.dart';


class GenerateInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<GenerateInventoryController>(GenerateInventoryController(),permanent: false);
  }
}
