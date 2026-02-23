import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/todays_due_retrieval_controller.dart';

class TodaysRetrievalDuesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<RetrievalDueController>(RetrievalDueController(),permanent: false);
  }
}
