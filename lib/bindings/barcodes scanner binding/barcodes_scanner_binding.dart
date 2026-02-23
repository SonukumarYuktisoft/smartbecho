import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/utils/BarcodeScanner/Barcodes_scanner.dart';

class BarcodesScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BarcodeScannerController>(BarcodeScannerController(),permanent: false);
  }
}
