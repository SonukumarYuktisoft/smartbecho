import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';

class BillsFAB extends GetView<BillHistoryController> {
  const BillsFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: const CircleBorder(),
      children: [
        _buildSpeedDialChild(
          label: 'View Purchased Item',
          backgroundColor: const Color(0xFF51CF66),
          icon: Icons.inventory_2,
          onTap: () => Get.toNamed(AppRoutes.stockList),
        ),
        _buildSpeedDialChild(
          label: 'View Online added Products',
          backgroundColor: const Color(0xFF00CEC9),
          icon: Icons.inventory_2,
          onTap: () => Get.toNamed(AppRoutes.onlineAddedProducts),
        ),
        _buildSpeedDialChild(
          label: 'Add New Stock',
          backgroundColor: const Color(0xFF00CEC9),
          icon: Icons.add,
          onTap: () => controller.addNewStocks(),
        ),
      ],
    );
  }

  SpeedDialChild _buildSpeedDialChild({
    required String label,
    required Color backgroundColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SpeedDialChild(
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      child: Icon(icon),
      onTap: onTap,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelBackgroundColor: Colors.white,
      labelShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}