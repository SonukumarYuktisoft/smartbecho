import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/this_month_aaded_stock_controller.dart';

class ThisMonthStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThisMonthStockController>(() => ThisMonthStockController());
  }
}