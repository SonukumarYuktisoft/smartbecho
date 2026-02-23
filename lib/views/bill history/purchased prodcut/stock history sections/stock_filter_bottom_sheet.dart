
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';

void showStockFilterBottomSheet(
  BuildContext context,
  BillHistoryController controller,
) {
  Get.bottomSheet(
    SafeArea(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildFilterHeader(controller),

            SizedBox(height: 20),

            // Company and Category Row
            _buildCompanyCategoryRow(controller),

            // Sort Option
            Obx(
              () => buildStyledDropdown(
                labelText: 'Sort By',
                hintText: 'Select Sort Field',
                value: controller.stockSortBy.value,
                items: controller.stockSortOptions,
                onChanged: (value) =>
                    controller.onStockSortChanged(value ?? 'createdDate'),
                suffixIcon: Icon(
                  controller.stockSortDir.value == 'asc'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(controller),

            SizedBox(height: MediaQuery.of(Get.context!).viewInsets.bottom),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _buildFilterHeader(BillHistoryController controller) {
  return Row(
    children: [
      Text(
        'Filter & Sort Stock',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      Spacer(),
      SizedBox(width: 8),
      IconButton(
        onPressed: () => controller.refreshStockItems(),
        icon: Obx(
          () => controller.isLoadingStock.value
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1E293B),
                  ),
                )
              : Icon(
                  Icons.refresh,
                  size: 18,
                  color: Color(0xFF1E293B),
                ),
        ),
        tooltip: 'Refresh',
      ),
      IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.close),
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
    ],
  );
}

Widget _buildCompanyCategoryRow(BillHistoryController controller) {
  return Row(
    children: [
      Expanded(
        child: Obx(
          () => buildStyledDropdown(
            labelText: 'Company',
            hintText: 'Select Company',
            value: controller.selectedStockCompany.value == 'All'
                ? null
                : controller.selectedStockCompany.value,
            items: controller.stockCompanyOptions,
            onChanged: controller.onStockCompanyChanged,
          ),
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: Obx(
          () => buildStyledDropdown(
            labelText: 'Category',
            hintText: 'Select Category',
            value: controller.selectedCategory.value == 'All'
                ? null
                : controller.selectedCategory.value,
            items: controller.categoryOptions,
            onChanged: controller.onCategoryChanged,
          ),
        ),
      ),
    ],
  );
}

Widget _buildActionButtons(BillHistoryController controller) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: controller.resetStockFilters,
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF1E293B),
            side: BorderSide(color: AppColors.primaryLight),
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Reset'),
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Apply'),
        ),
      ),
    ],
  );
}