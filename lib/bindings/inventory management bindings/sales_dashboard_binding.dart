import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_stock_comtroller.dart';

class SalesDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<InventorySalesStockController>(InventorySalesStockController(), permanent: false);
  }
}
