// FILE: lib/views/inventory/sections/inventory_filters_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/BarcodeScanner/Barcodes_scanner.dart';

class InventoryFiltersSection extends StatelessWidget {
  final InventoryController controller;

  const InventoryFiltersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final BarcodeScannerController barcodeScannerController = Get.put(
      BarcodeScannerController(),
    );

    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFCFD8F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Icon
          Icon(Icons.search_rounded, color: Color(0xFF9DB4CE), size: 26),

          SizedBox(width: 12),

          // Search Field
          Expanded(
            child: TextFormField(
              controller: controller.searchTextController,
              onChanged: (value) => controller.searchQuery.value = value,
              textAlignVertical: TextAlignVertical.center,

              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFBFD3E6),
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: Obx(
                  () =>
                      controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              controller.searchQuery.value = '';
                              controller.searchTextController.clear();
                              controller.clearFilters();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF9DB4CE),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          )
                          : SizedBox.shrink(),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 0,
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Scanner Button
          InkWell(
            onTap: () async {
              final scannedData =
                  await barcodeScannerController.openBarcodeScanner();
              if (scannedData != null) {
                barcodeScannerController.setBarcode(scannedData);
                controller.searchQuery.value = scannedData;
                controller.searchTextController.text = scannedData;
              } else {
                barcodeScannerController.clearBarcode();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF9DB4CE),
                size: 24,
              ),
            ),
          ),

          SizedBox(width: 12),

          // Filter Button
          Obx(() {
            int activeFilters = _getActiveFiltersCount();
            return InkWell(
              onTap: () => _showFilterBottomSheet(controller),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.tune_rounded,
                  size: 24,
                  color:
                      activeFilters > 0
                          ? AppColors.primaryLight
                          : Color(0xFF9DB4CE),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _getActiveFiltersCount() {
    return controller.getActiveFiltersCount();
  }

  void _showFilterBottomSheet(InventoryController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          height: Get.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Bottom sheet header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: AppColors.primaryLight, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Filter Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    Obx(() {
                      int activeFilters = controller.getActiveFiltersCount();
                      return activeFilters > 0
                          ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$activeFilters Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : SizedBox.shrink();
                    }),
                    SizedBox(width: 8),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => controller.refreshData(),
                      icon: Obx(
                        () =>
                            controller.isFiltersLoading.value
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
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Filter content
              Expanded(
                child: Obx(() {
                  if (controller.isFiltersLoading.value) {
                    return Container(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading filters...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.hasFiltersError.value) {
                    return Container(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error Loading Filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            controller.filtersErrorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: controller.fetchFiltersData,
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info text about cascading filters
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primaryLight,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Select Company/Category first, then Model, then specifications',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Filter Section 1: Company and Category
                        Text(
                          'Basic Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDynamicFilterDropdown(
                                'Company',
                                controller.selectedCompany,
                                controller.availableCompanies,
                                onChanged: controller.onCompanyFilterChanged,
                                filterType: 'company',
                                controller: controller,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildDynamicFilterDropdown(
                                'Category',
                                controller.selectedCategory,
                                controller.availableCategories,
                                onChanged: controller.onCategoryFilterChanged,
                                filterType: 'category',
                                controller: controller,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Filter Section 2: Model
                        Text(
                          'Model Selection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildDynamicFilterDropdown(
                          'Model',
                          controller.selectedModel,
                          controller.availableModels,
                          onChanged: controller.onModelFilterChanged,
                          filterType: 'model',
                          controller: controller,
                        ),
                        SizedBox(height: 20),

                        // Filter Section 3: Specifications
                        Text(
                          'Specifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDynamicFilterDropdown(
                                'RAM',
                                controller.selectedRAM,
                                controller.availableRAMs,
                                onChanged: controller.onRAMFilterChanged,
                                filterType: 'ram',
                                controller: controller,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildDynamicFilterDropdown(
                                'Storage',
                                controller.selectedROM,
                                controller.availableROMs,
                                onChanged: controller.onROMFilterChanged,
                                filterType: 'rom',
                                controller: controller,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildDynamicFilterDropdown(
                          'Color',
                          controller.selectedColor,
                          controller.availableColors,
                          onChanged: controller.onColorFilterChanged,
                          filterType: 'color',
                          controller: controller,
                        ),
                        SizedBox(height: 20),

                        // Show current filter path
                        Obx(() {
                          List<String> filterPath = [];
                          if (controller.selectedCompany.value.isNotEmpty) {
                            filterPath.add(controller.selectedCompany.value);
                          }
                          if (controller.selectedCategory.value.isNotEmpty) {
                            filterPath.add(controller.selectedCategory.value);
                          }
                          if (controller.selectedModel.value.isNotEmpty) {
                            filterPath.add(controller.selectedModel.value);
                          }

                          if (filterPath.isNotEmpty) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.filter_alt_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Current Filter Path:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    filterPath.join(' → '),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        }),
                        SizedBox(height: 100), // Extra space for bottom buttons
                      ],
                    ),
                  );
                }),
              ),
              // Bottom action buttons
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.clearFilters();
                          Get.back();
                        },
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                          side: BorderSide(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.applyFilters();
                          Get.back();
                        },
                        icon: Icon(Icons.search, size: 18),
                        label: Text('Apply Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

Widget _buildDynamicFilterDropdown(
  String hint,
  RxString selectedValue,
  RxList<String> options, {
  required InventoryController controller,
  required Function(String) onChanged,
  String filterType = '',
}) {
  return Obx(() {
    bool isEnabled = controller.isFilterEnabled(filterType);
    bool isLoading = controller.isFilterLoading(filterType);

    // Create options list with 'All' as first option
    final List<String> dropdownOptions = ['All', ...options.toSet().toList()];

    // Determine if current selected value is valid
    final String? validSelectedValue =
        dropdownOptions.contains(selectedValue.value) &&
                selectedValue.value.isNotEmpty &&
                selectedValue.value != 'All'
            ? selectedValue.value
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          hint,
          style: TextStyle(
            color: !isEnabled ? Colors.grey[400] : AppColors.primaryLight,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  !isEnabled
                      ? Colors.grey.withValues(alpha: 0.3)
                      : selectedValue.value.isNotEmpty &&
                          selectedValue.value != 'All'
                      ? AppColors.primaryLight
                      : AppColors.primaryLight.withValues(alpha: 0.2),
              width:
                  selectedValue.value.isNotEmpty && selectedValue.value != 'All'
                      ? 1.5
                      : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            color:
                !isEnabled
                    ? Colors.grey[100]
                    : selectedValue.value.isNotEmpty &&
                        selectedValue.value != 'All'
                    ? AppColors.primaryLight.withValues(alpha: 0.05)
                    : Colors.grey[50],
          ),
          child:
              isLoading
                  ? Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading $hint...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: validSelectedValue,
                      hint: Row(
                        children: [
                          Expanded(
                            child: Text(
                              !isEnabled
                                  ? '$hint (Select ${_getRequiredFilter(filterType)} first)'
                                  : hint,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    !isEnabled
                                        ? Colors.grey[400]
                                        : AppColors.primaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items:
                          !isEnabled || isLoading
                              ? []
                              : dropdownOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value == 'All' ? null : value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          value == 'All'
                                              ? Colors.grey[600]
                                              : Colors.black87,
                                      fontWeight:
                                          value == 'All'
                                              ? FontWeight.normal
                                              : FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                      onChanged:
                          !isEnabled || isLoading
                              ? null
                              : (String? newValue) {
                                if (newValue == null) {
                                  // 'All' was selected, clear the filter
                                  onChanged('');
                                } else {
                                  onChanged(newValue);
                                }
                              },
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedValue.value.isNotEmpty &&
                              selectedValue.value != 'All' &&
                              isEnabled)
                            GestureDetector(
                              onTap: () => onChanged(''),
                              child: Container(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.clear,
                                  color: AppColors.primaryLight,
                                  size: 14,
                                ),
                              ),
                            ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color:
                                !isEnabled
                                    ? Colors.grey[400]
                                    : AppColors.primaryLight,
                            size: 16,
                          ),
                        ],
                      ),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
        ),
      ],
    );
  });
}

String _getRequiredFilter(String filterType) {
  switch (filterType) {
    case 'model':
      return 'Company or Category';
    case 'ram':
    case 'rom':
    case 'color':
      return 'Model';
    default:
      return '';
  }
}
