// FILE: lib/views/sales_management/sections/sales_tabs_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/app_colors.dart';

class SalesTabsSection extends StatelessWidget {
  final SalesManagementController controller;

  const SalesTabsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTabButton('dashboard', 'Dashboard', Icons.dashboard),
            _buildTabButton('history', 'Sales History', Icons.history),
            _buildTabButton('insights', 'Sales Insights', Icons.insights),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabValue, String label, IconData icon) {
    bool isSelected = controller.selectedTab.value == tabValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabChanged(tabValue),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 16,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}