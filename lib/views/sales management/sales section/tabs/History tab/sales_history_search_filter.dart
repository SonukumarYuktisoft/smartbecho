// FILE: lib/views/sales_management/sections/sales_history_search_filter.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/common_date_feild.dart';
import 'package:smartbecho/utils/common_month_year_dropdown.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';

class SalesHistorySearchFilter extends StatelessWidget {
  final SalesManagementController controller;

  const SalesHistorySearchFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonSearchBar(
      controller: controller.searchController,
      onChanged: (_) => controller.onSearchChanged(),
      hintText: 'Search sales by customer, invoice...',
      searchQuery: controller.searchQuery,
      clearFilters: controller.clearSearch,
      onFilter: () => _showFilterBottomSheet(context),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
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
              Row(
                children: [
                  Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => controller.refreshData(),
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: Color(0xFF1E293B),
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
              ),
              SizedBox(height: 20),

              // Item Category and Company
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => buildStyledDropdown(
                        labelText: 'Item Category',
                        hintText: 'Select Category',
                        value:
                            controller.selectedItemCategory.value?.isEmpty ==
                                    true
                                ? null
                                : controller.selectedItemCategory.value,
                        items: controller.itemCategoryOptions,
                        onChanged: controller.onItemCategoryChanged,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => buildStyledDropdown(
                        labelText: 'Company',
                        hintText: 'Select Company',
                        value:
                            controller.selectedCompany.value?.isEmpty == true
                                ? null
                                : controller.selectedCompany.value,
                        items: controller.companyOptions,
                        onChanged: controller.onCompanyChanged,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Payment Method and Mode
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => buildStyledDropdown(
                        labelText: 'Payment Method',
                        hintText: 'Select Method',
                        value:
                            controller.selectedPaymentMethod.value?.isEmpty ==
                                    true
                                ? null
                                : controller.selectedPaymentMethod.value,
                        items: controller.paymentMethodOptions,
                        onChanged: controller.onPaymentMethodChanged,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => buildStyledDropdown(
                        labelText: 'Payment Mode',
                        hintText: 'Select Mode',
                        value:
                            controller.selectedPaymentMode.value?.isEmpty ==
                                    true
                                ? null
                                : controller.selectedPaymentMode.value,
                        items: controller.paymentModeOptions,
                        onChanged: controller.onPaymentModeChanged,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Date Filter Type
              Obx(
                () => buildStyledDropdown(
                  labelText: 'Date Filter Type',
                  hintText: 'Select Date Type',
                  value: controller.dateFilterType.value,
                  items: ['Month/Year', 'Date Range'],
                  onChanged: controller.onDateFilterTypeChanged, 
                ),
              ),
              SizedBox(height: 16),

              // Date Selection
              Obx(() {
                if (controller.dateFilterType.value == 'Month/Year') {
                  return MonthYearDropdown(
                    selectedMonth: controller.selectedMonth.value,
                    selectedYear: controller.selectedYear.value,
                    onMonthChanged: controller.onMonthChanged,
                    onYearChanged: controller.onYearChanged,
                    showAllOption: true,
                    monthLabel: 'Month',
                    yearLabel: 'Year',
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: buildDateField(
                          labelText: 'Start Date',
                          controller: controller.startDateController,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: buildDateField(
                          labelText: 'End Date',
                          controller: controller.endDateController,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  );
                }
              }),
              SizedBox(height: 16),

              // Sort By
              Obx(
                () => buildStyledDropdown(
                  labelText: 'Sort By',
                  hintText: 'Select Sort Field',
                  value: controller.selectedSortBy.value,
                  items: controller.sortByOptions,
                  onChanged: controller.onSortByChanged,
                ),
              ),
              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetAllFilters();
                        Get.back();
                      },
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
                      onPressed: () {
                        controller.applyFilters();
                        Get.back();
                      },
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
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      if (isStartDate) {
        controller.onStartDateChanged(picked);
      } else {
        controller.onEndDateChanged(picked);
      }
    }
  }
}
