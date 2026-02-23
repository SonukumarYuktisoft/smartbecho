import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';

/// Bottom sheet for customer filtering options
/// Provides filter chips for customer types
class FilterBottomSheet extends StatelessWidget {
  final CustomerController controller;

  const FilterBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: const BoxDecoration(
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
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchActiveBanner(),
            _buildFilterSection(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Build header with title and search indicator
  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Filter Customers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        _buildSearchActiveIndicator(),
      ],
    );
  }

  /// Build search active indicator badge
  Widget _buildSearchActiveIndicator() {
    return Obx(() {
      if (controller.searchKeyword.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Search Active',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  /// Build info banner when search is active
  Widget _buildSearchActiveBanner() {
    return Obx(() {
      if (controller.searchKeyword.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Filters will be combined with search results',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Build filter chips section
  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _buildFilterChips(),
        ),
      ],
    );
  }

  /// Build list of filter chips
  List<Widget> _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'All Customers'},
      {'label': 'New', 'value': 'New Customers'},
      {'label': 'Regular', 'value': 'Regular Customers'},
      {'label': 'Repeated', 'value': 'Repeated Customers'},
      {'label': 'VIP', 'value': 'VIP Customers'},
    ];

    return filters
        .map((filter) => _buildFilterChip(
              filter['label']!,
              filter['value']!,
            ))
        .toList();
  }

  /// Build individual filter chip
  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;

      return FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          controller.onFilterChanged(value);
          Get.back();
        },
        selectedColor: AppColors.primaryLight,
        backgroundColor: Colors.grey[100],
        checkmarkColor: Colors.white,
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    });
  }

  /// Build action buttons (Clear All and Apply)
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              controller.resetFilters();
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }
}