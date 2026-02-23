import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterOption {
  final String label;
  final String value;
  final List<String> options;
  final String selectedValue;
  final Function(String) onChanged;

  FilterOption({
    required this.label,
    required this.value,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });
}

class CommonFilterWidget extends StatelessWidget {
  final List<FilterOption> filterOptions;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;
  final bool showSortBy;
  final String? sortLabel;
  final List<String>? sortOptions;
  final String? selectedSort;
  final Function(String)? onSortChanged;

  const CommonFilterWidget({
    Key? key,
    required this.filterOptions,
    required this.onApplyFilters,
    required this.onClearFilters,
    this.showSortBy = false,
    this.sortLabel,
    this.sortOptions,
    this.selectedSort,
    this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                splashRadius: 20,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Filter options
          ...filterOptions.map((filter) => _buildFilterDropdown(filter)),

          // Sort by section (if enabled)
          if (showSortBy && sortOptions != null) ...[
            const SizedBox(height: 16),
            _buildSortBySection(),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    onApplyFilters();
                    Get.back();
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(FilterOption filter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filter.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: filter.selectedValue.isEmpty ? null : filter.selectedValue,
                hint: Text(
                  'Select ${filter.label}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                isExpanded: true,
                items: filter.options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    filter.onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sortLabel ?? 'Sort By',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSort?.isEmpty == true ? null : selectedSort,
              hint: Text(
                'Select Sort Option',
                style: TextStyle(color: Colors.grey[600]),
              ),
              isExpanded: true,
              items: sortOptions!.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null && onSortChanged != null) {
                  onSortChanged!(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}