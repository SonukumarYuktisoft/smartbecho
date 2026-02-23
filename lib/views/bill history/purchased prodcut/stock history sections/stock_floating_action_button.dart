
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_speed_dial_fl_button_widegt.dart';

Widget buildStockFloatingActionButtons() {
  final controller = Get.find<BillHistoryController>();

  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
    elevation: 8,
    shape: const CircleBorder(),
    children: [
      buildSpeedDialChild(
        label: 'View Online added Products',
        backgroundColor: const Color(0xFF51CF66),
        icon: Icons.inventory_2,
        onTap: () => Get.toNamed(AppRoutes.onlineAddedProducts),
      ),
      buildSpeedDialChild(
        label: 'Bill History',
        backgroundColor: const Color(0xFF00CEC9),
        icon: Icons.inventory_2,
        onTap: () => Get.toNamed(AppRoutes.billHistory),
      ),
      buildSpeedDialChild(
        label: 'Add New Stock',
        backgroundColor: const Color(0xFF00CEC9),
        icon: Icons.add,
        onTap: () => controller.addNewStocks(),
      ),
    ],
  );
}