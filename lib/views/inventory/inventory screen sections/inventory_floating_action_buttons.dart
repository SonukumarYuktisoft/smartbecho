import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';

class InventoryFloatingActionButtons extends StatelessWidget {
  final InventoryController controller;

  const InventoryFloatingActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Scroll to Top Button (shows when scrolled down)
          if (controller.showScrollToTop.value)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryLight,
                elevation: 4,
                onPressed: controller.scrollToTop,
                heroTag: "scrollToTop",
                child: Icon(Icons.keyboard_arrow_up, size: 28),
              ),
            ),

          // Main Speed Dial
          SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: CircleBorder(),
            children: [
              SpeedDialChild(
                child: Icon(Icons.add, color: Colors.white),
                backgroundColor: Color(0xFF51CF66),
                label: 'Add Online Product',
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onTap: controller.addNewItem,
              ),
              // SpeedDialChild(
              //   child: Icon(Icons.upload_file, color: Colors.white),
              //   backgroundColor: Color(0xFF00CEC9),
              //   label: 'Bulk Upload',
              //   labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              //   onTap: controller.bulkUpload,
              // ),
              // SpeedDialChild(
              //   child: Icon(Icons.download, color: Colors.white),
              //   backgroundColor: Color(0xFFFF9500),
              //   label: 'Export Data',
              //   labelStyle: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w500,
              //   ),
              //   onTap: null,
              //   //controller.exportData,
              // ),
              SpeedDialChild(
                child: Icon(Icons.inventory_rounded, color: Colors.white),
                backgroundColor: AppColors.primaryLight,
                label: 'Add New Stock',
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onTap: controller.addNewStocks,
              ),
            ],
          ),
        ],
      ),
    );
  }
}