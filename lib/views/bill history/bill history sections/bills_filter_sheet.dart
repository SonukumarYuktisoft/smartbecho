// ============================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common_date_feild.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';

class BillsFilterSheet {
  static void show(BillHistoryController controller) {
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
          child: _FilterSheetContent(controller: controller),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _FilterSheetContent extends StatelessWidget {
  final BillHistoryController controller;

  const _FilterSheetContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 20),
        _buildFilters(),
        SizedBox(height: 16),
        _buildDateSelection(context),
        SizedBox(height: 16),
        _buildSortOption(),
        SizedBox(height: 24),
        _buildActionButtons(),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
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
          onPressed: () => controller.refreshBills(),
          icon: Obx(
            () =>
                controller.isLoading.value
                    ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1E293B),
                      ),
                    )
                    : Icon(Icons.refresh, size: 18, color: Color(0xFF1E293B)),
          ),
          tooltip: 'Refresh',
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'Distributor',
              hintText: 'Distributor',
              value:
                  controller.selectedCompany.value == 'All'
                      ? null
                      : controller.selectedCompany.value,
              items: controller.companyOptions,
              onChanged: controller.onCompanyChanged,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'Time Period',
              hintText: 'Select Period',
              value: controller.timePeriodType.value,
              items: controller.timePeriodOptions,
              onChanged: controller.onTimePeriodTypeChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    return Obx(() {
      if (controller.timePeriodType.value == 'Month/Year') {
        return _buildMonthYearSelection();
      }
      return _buildCustomDateSelection(context);
    });
  }

  Widget _buildMonthYearSelection() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'Month',
              hintText: 'Select Month',
              value: controller.getMonthName(controller.selectedMonth.value),
              items: List.generate(
                12,
                (index) => controller.getMonthName(index + 1),
              ),
              onChanged: (value) {
                if (value != null) {
                  final monthIndex =
                      List.generate(
                        12,
                        (index) => controller.getMonthName(index + 1),
                      ).indexOf(value) +
                      1;
                  controller.onMonthChanged(monthIndex);
                }
              },
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'Year',
              hintText: 'Select Year',
              value: controller.selectedYear.value.toString(),
              items:
                  List.generate(
                    11,
                    (index) => (2020 + index).toString(),
                  ).reversed.toList(),
              onChanged: (value) {
                if (value != null) controller.onYearChanged(int.parse(value));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDateSelection(BuildContext context) {
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

  Widget _buildSortOption() {
    return Obx(() {
      return _buildDropdown(
        labelText: 'Sort By',
        hintText: 'Select Sort Field',
        value: controller.sortBy.value,
        items: controller.sortOptions,
        onChanged: (value) {
          if (value != null) {
            controller.sortBy.value = value;
            controller.onSortChanged(value);
          }
        },
        suffixIcon: Icon(
          controller.sortDir.value == 'asc'
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          size: 16,
          color: const Color(0xFF1E293B),
        ),
      );
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetFilters,
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

  void _resetFilters() {
    controller.selectedCompany.value = 'All';
    controller.timePeriodType.value = 'Month/Year';
    controller.selectedMonth.value = DateTime.now().month;
    controller.selectedYear.value = DateTime.now().year;
    controller.startDate.value = null;
    controller.endDate.value = null;
    controller.startDateController.clear();
    controller.endDateController.clear();
    controller.sortBy.value = 'billId';
    controller.sortDir.value = 'desc';
    controller.loadBills(refresh: true);
    Get.back();
  }

  Widget _buildDropdown({
    required String labelText,
    required String hintText,
    required String? value, // API value
    required List<SortOption> items,
    required Function(String?) onChanged,
    Widget? suffixIcon,
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
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 250,
            hint: Text(
              hintText,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
            items:
                items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.value, // ✅ API value
                    child: Text(item.label), // ✅ UI label
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
