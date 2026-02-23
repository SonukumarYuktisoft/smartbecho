import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/common_date_feild.dart';
import 'package:smartbecho/utils/common_month_year_dropdown.dart';

class DuesSearchFilterSection extends StatelessWidget {
  final CustomerDuesController controller;

  const DuesSearchFilterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonSearchBar(
      controller: TextEditingController(),
      onChanged: controller.onSearchChanged,
      hintText: 'Search by name or ID...',
      searchQuery: RxString(''),
      clearFilters: controller.resetFilters,
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
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Time Period
              Obx(
                () => _buildStyledDropdown(
                  labelText: 'Time Period',
                  hintText: 'Select Period',
                  value: controller.timePeriodType.value,
                  items: controller.timePeriodOptions,
                  onChanged: controller.onTimePeriodTypeChanged,
                ),
              ),
              SizedBox(height: 16),

             // Date Selection
              Obx(() {
                if (controller.timePeriodType.value == 'Month/Year') {
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
              }), // Sort
              Obx(
                () => _buildStyledDropdown(
                  labelText: 'Sort By',
                  hintText: 'Select Sort Field',
                  value: controller.sortBy.value,
                  items: controller.sortOptions,
                  onChanged:
                      (value) =>
                          controller.onSortChanged(value ?? 'creationDate'),
                ),
              ),
              SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetFilters();
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
              ),
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
  Widget _buildStyledDropdown({
    required String labelText,
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hintText,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
