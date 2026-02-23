// FILE: lib/views/inventory/sections/inventory_stats_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';

class InventoryStatsSection extends StatelessWidget {
  final InventoryController controller;

  const InventoryStatsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          controller.isSummaryCardsLoading.value
              ? _buildShimmerStatList()
              : controller.hasSummaryCardsError.value
              ? _buildErrorCard()
              : _buildStatsList(),
    );
  }

  Widget _buildStatsList() {
    final stats = [
      {
        'title': 'Total Stock',
        'value': controller.totalStockAvailable.toString(),
        'icon': Icons.inventory_2,
        'color': Color(0xFFFF9500),
        'gradient': [Color(0xFFF59E0B), Color(0xFFF59E0B)],
      },
      {
        'title': 'Total Companies',
        'value': controller.totalCompaniesAvailable.toString(),
        'icon': Icons.business,
        'color': Color(0xFF00BAD1),
        'gradient': [Color(0xFF06B6D4), Color(0xFF06B6D4)],
      },
      {
        'title': 'Low Stock Alert',
        'value': controller.lowStockAlert.toString(),
        'icon': Icons.sell,
        'color': Color(0xFFFF6B6B),
        'gradient': [Color(0xFFEF4444), Color(0xFFEF4444)],
      },
      {
        'title': 'Monthly Sold',
        'value': controller.monthlyPhoneSold.toString(),
        'icon': Icons.trending_up,
        'color': Color(0xFF51CF66),
        'gradient': [Color(0xFF10B981), Color(0xFF10B981)],
      },
    ];

    return Container(
      height: 130,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return FeatureVisitor(
             featureKey: FeatureKeys.INVENTORY.getMobilesShopSummary,
            child: BuildStatsCard(
              label: stats[index]['title'] as String,
              value: stats[index]['value'].toString(),
              icon: stats[index]['icon'] as IconData,
              color: stats[index]['color'] as Color,
              isAmount: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerStatList() {
    return Container(
      height: 130,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder:
            (context, index) => Container(
              width: 180,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.summaryCardsErrorMessage.value,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
