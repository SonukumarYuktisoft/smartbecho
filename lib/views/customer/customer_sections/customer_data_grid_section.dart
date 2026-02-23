import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/views/customer/customer_sections/customer%20sub%20sections/customer_grid_states.dart';
import 'package:smartbecho/views/customer/widgets/build_compact_customer_card.dart';

/// Customer data grid section
/// Displays customer list or empty/error/loading states
class CustomerDataGridSection extends StatelessWidget {
  final CustomerController controller;

  const CustomerDataGridSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return CustomerGridStates.loading();
        }

        if (controller.hasError.value) {
          return CustomerGridStates.error(
            errorMessage: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }

        if (controller.filteredApiCustomers.isEmpty) {
          return CustomerGridStates.empty(
            onAddCustomer: () => Get.toNamed(AppRoutes.addCustomer),
          );
        }

        return BuildCompactCustomerCard();
      }),
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
}