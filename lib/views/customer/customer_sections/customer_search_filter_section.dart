import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/views/customer/customer_sections/customer%20sub%20sections/filter_bottom_sheet.dart';

/// Search bar and filter button section
/// Provides search functionality and filter options
class CustomerSearchFilterSection extends StatelessWidget {
  final CustomerController controller;

  const CustomerSearchFilterSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return    CommonSearchBar(
      controller: TextEditingController(),
      onChanged: controller.onSearchChanged,
        hintText: 'Search by name, phone, location...',
      searchQuery: RxString(''),
      clearFilters: controller.resetFilters,
      hasFilters: false,
      onFilter: () => _showFilterBottomSheet(context),
    );
  }

  /// Build container decoration with shadow
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.08),
          spreadRadius: 0,
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Build search bar row with filter button
  Widget _buildSearchRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSearchField(),
        ),
        const SizedBox(width: 8),
        _buildFilterButton(context),
      ],
    );
  }

  /// Build search text field
  Widget _buildSearchField() {
    return TextFormField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search by name, phone, location...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey[500],
        ),
        prefixIcon: _buildSearchIcon(),
        suffixIcon: _buildClearButton(),
        border: _buildBorder(focused: false),
        focusedBorder: _buildBorder(focused: true),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Build search icon
  Widget _buildSearchIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Icon(
        Icons.search,
        size: 18,
        color: AppColors.primaryLight,
      ),
    );
  }

  /// Build clear button (shown when search is active)
  Widget _buildClearButton() {
    return Obx(() {
      if (controller.searchKeyword.value.isEmpty) {
        return const SizedBox();
      }

      return IconButton(
        onPressed: controller.clearSearch,
        icon: Icon(
          Icons.clear,
          size: 16,
          color: Colors.grey[600],
        ),
        tooltip: 'Clear search',
      );
    });
  }

  /// Build input border
  OutlineInputBorder _buildBorder({required bool focused}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: focused
            ? AppColors.primaryLight
            : AppColors.primaryLight.withValues(alpha: 0.3),
        width: focused ? 2 : 1,
      ),
      gapPadding: 0.0,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Build filter button with active indicator
  Widget _buildFilterButton(BuildContext context) {
    return Obx(() {
      final hasActiveFilters =
          controller.selectedFilter.value != 'All Customers';

      return Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? AppColors.primaryLight
              : AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: IconButton(
          onPressed: () => _showFilterBottomSheet(context),
          icon: Icon(
            Icons.tune,
            size: 20,
            color: hasActiveFilters ? Colors.white : AppColors.primaryLight,
          ),
          tooltip: 'Filter customers',
        ),
      );
    });
  }

  /// Show filter options bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) => FilterBottomSheet(controller: controller),
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: Colors.white,
    );
  }
}