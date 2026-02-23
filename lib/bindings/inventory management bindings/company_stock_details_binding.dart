import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/company_stock_detail_controller.dart';

class CompanyStockDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CompanyStockDetailsController>(CompanyStockDetailsController(), permanent: false);
  }
}
