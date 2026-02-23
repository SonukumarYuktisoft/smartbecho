import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/common_speed_dial_fl_button_widegt.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';

/// Floating action buttons for online products
/// Provides quick actions for stock management
class OnlineProductsFloatingActions extends StatelessWidget {
  final BillHistoryController billHistoryController;

  const OnlineProductsFloatingActions({
    super.key,
    required this.billHistoryController,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: const CircleBorder(),
      children: [
        buildSpeedDialChild(
          label: 'View Purchased Item',
          backgroundColor: const Color(0xFF51CF66),
          icon: Icons.inventory_2,
          onTap: () => Get.toNamed(AppRoutes.stockList),
        ),
        buildSpeedDialChild(
          label: 'Bill History',
          backgroundColor: const Color(0xFF00CEC9),
          icon: Icons.receipt_long,
          onTap: () => Get.toNamed(AppRoutes.billHistory),
        ),
        buildSpeedDialChild(
          label: 'Add New Stock',
          backgroundColor: const Color(0xFF6366F1),
          icon: Icons.add,
          onTap: () => billHistoryController.addNewStocks(),
        ),
      ],
    );
  }
}