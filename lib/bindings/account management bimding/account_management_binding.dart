import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/controllers/account%20management%20controller/commission_received_controller.dart';
import 'package:smartbecho/controllers/account%20management%20controller/emi_settlement_controller.dart';
import 'package:smartbecho/controllers/account%20management%20controller/gst_ledger_controller.dart';
import 'package:smartbecho/controllers/account%20management%20controller/pay_bill_controller.dart';
import 'package:smartbecho/controllers/account%20management%20controller/view_history_controller.dart';
import 'package:smartbecho/controllers/account%20management%20controller/withdraw_history_controller.dart';

class AccountManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AccountManagementController>(
      AccountManagementController(),
      permanent: false,
    );
    Get.put<ViewHistoryController>(ViewHistoryController(), permanent: false);
    Get.put<PayBillsController>(PayBillsController(), permanent: false);
    Get.put<WithdrawController>(WithdrawController(), permanent: false);
    Get.put<CommissionReceivedController>(
      CommissionReceivedController(),
      permanent: false,
    );
    Get.put<EmiSettlementController>(
      EmiSettlementController(),
      permanent: false,
    );
    Get.put<GstLedgerController>(GstLedgerController(), permanent: false);
  }
}
