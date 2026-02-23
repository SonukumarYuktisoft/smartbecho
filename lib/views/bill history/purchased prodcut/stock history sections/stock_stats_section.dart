import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';

class StockStatsSection extends StatelessWidget {
  final BillHistoryController controller;

  const StockStatsSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Obx(() {
        if (controller.isLoadingStock.value && controller.stockItems.isEmpty) {
          return Container(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return Container(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              BuildStatsCard(
                label: 'Total Items',
                value: controller.totalStockItems.value.toString(),
                icon: Icons.inventory_2,
                color: Color(0xFF3B82F6),
                width: 180,
                isAmount: false,
              ),
              BuildStatsCard(
                label: 'Total Qty',
                value: controller.totalQtyAdded.value.toString(),
                icon: Icons.add_box,
                color: Color(0xFF10B981),
                width: 180,
                isAmount: false,
              ),
              BuildStatsCard(
                label: 'Companies',
                value: controller.totalDistinctCompanies.value.toString(),
                icon: Icons.business,
                color: Color(0xFF8B5CF6),
                width: 180,
                isAmount: false,
              ),
              BuildStatsCard(
                label: 'Categories',
                value: controller.categoryOptions.length > 1
                    ? (controller.categoryOptions.length - 1).toString()
                    : '0',
                icon: Icons.category,
                color: Color(0xFFF59E0B),
                width: 180,
                isAmount: false,
              ),
            ],
          ),
        );
      }),
    );
  }
}
