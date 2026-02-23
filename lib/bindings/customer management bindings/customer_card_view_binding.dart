import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_card_view_controller.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_details_controller.dart';

class CustomerCardViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerCardsController>(CustomerCardsController(),permanent: false);
  }
}
