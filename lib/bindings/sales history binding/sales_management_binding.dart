import 'package:get/get.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/add_mobile_sales_controller.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/controllers/user_prefs_controller.dart';

class SalesManagementBinding extends Bindings {
  @override
  void dependencies() {
    // Put controllers needed for home and main app
    Get.put<SalesManagementController>(SalesManagementController());
    Get.put<SalesCrudOperationController>(SalesCrudOperationController());



  }
}
