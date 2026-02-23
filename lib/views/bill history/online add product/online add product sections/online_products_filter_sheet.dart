import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';

class OnlineProductsFilterSheet extends StatelessWidget {
  final OnlineProductsController controller;

  const OnlineProductsFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCategoryBrandRow(),
              const SizedBox(height: 16),
              _buildModelDropdown(),
              const SizedBox(height: 16),
              _buildRamRomRow(),
              const SizedBox(height: 16),
              _buildColorDropdown(),
              const SizedBox(height: 16),
              _buildSortDropdown(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with title and close button
  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Filter & Sort Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  /// Build category and brand row
  Widget _buildCategoryBrandRow() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'Category',
              hintText: 'Select Category',
              value:
                  controller.selectedCategory.value == 'All'
                      ? null
                      : controller.selectedCategory.value,
              items: controller.categoryOptions,
              onChanged: controller.onCategoryChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'Brand',
              hintText: 'Select Brand',
              value:
                  controller.selectedBrand.value == 'All'
                      ? null
                      : controller.selectedBrand.value,
              items: controller.brandOptions,
              onChanged: controller.onBrandChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// Build model dropdown
  Widget _buildModelDropdown() {
    return Obx(
      () => buildStyledDropdown(
        labelText: 'Model',
        hintText: 'Select Model',
        value:
            controller.selectedModel.value == 'All'
                ? null
                : controller.selectedModel.value,
        items: controller.modelOptions,
        onChanged: controller.onModelChanged,
      ),
    );
  }

  /// Build RAM and ROM row
  Widget _buildRamRomRow() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'RAM',
              hintText: 'Select RAM',
              value:
                  controller.selectedRam.value == 'All'
                      ? null
                      : controller.selectedRam.value,
              items: controller.ramOptions,
              onChanged: controller.onRamChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => buildStyledDropdown(
              labelText: 'ROM',
              hintText: 'Select ROM',
              value:
                  controller.selectedRom.value == 'All'
                      ? null
                      : controller.selectedRom.value,
              items: controller.romOptions,
              onChanged: controller.onRomChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// Build color dropdown
  Widget _buildColorDropdown() {
    return Obx(
      () => buildStyledDropdown(
        labelText: 'Color',
        hintText: 'Select Color',
        value:
            controller.selectedColor.value == 'All'
                ? null
                : controller.selectedColor.value,
        items: controller.colorOptions,
        onChanged: controller.onColorChanged,
      ),
    );
  }

  /// Build sort dropdown with direction icon
  Widget _buildSortDropdown() {
    return Obx(
      () => buildStyledDropdown(
        labelText: 'Sort By',
        hintText: 'Select Sort Field',
        value: controller.sortBy.value,
        items: controller.sortOptions,
        onChanged: (value) => controller.onSortChanged(value ?? 'createdDate'),
        suffixIcon: Icon(
          controller.sortOrder.value == 'asc'
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          size: 16,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.resetFilters,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E293B),
              side: BorderSide(color: AppColors.primaryLight),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset'),
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
