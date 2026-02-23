import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';

class BillHistoryBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<BillHistoryController>(BillHistoryController(),permanent: false);
  }
}
