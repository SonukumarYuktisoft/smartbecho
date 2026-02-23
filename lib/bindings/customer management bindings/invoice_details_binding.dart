import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_invoice_controller.dart';

class InvoiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<InvoiceDetailsController>(InvoiceDetailsController(),permanent: false);
  }
}
