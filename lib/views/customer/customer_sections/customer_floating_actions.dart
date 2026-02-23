import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';

/// Floating action buttons for customer actions
/// Provides quick access to add customer and refresh actions
class CustomerFloatingActions extends StatelessWidget {
  final CustomerController controller;

  const CustomerFloatingActions({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      spacing: 12,
      spaceBetweenChildren: 12,
      buttonSize: const Size(56, 56),
      childrenButtonSize: const Size(56, 56),
      animationCurve: Curves.easeInOutCubic,
      animationDuration: const Duration(milliseconds: 300),
      children: _buildSpeedDialChildren(),
    );
  }

  /// Build list of speed dial children
  List<SpeedDialChild> _buildSpeedDialChildren() {
    return [
      _buildAddCustomerAction(),
      _buildRefreshAction(),
    ];
  }

  /// Build add customer action
  SpeedDialChild _buildAddCustomerAction() {
    return SpeedDialChild(
      child: const Icon(Icons.person_add_outlined, size: 24),
      label: 'Add New Customer',
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      onTap: () => Get.toNamed(AppRoutes.addCustomer),
    );
  }

  /// Build refresh action
  SpeedDialChild _buildRefreshAction() {
    return SpeedDialChild(
      child: const Icon(Icons.refresh_outlined, size: 24),
      label: 'Refresh',
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: const Color(0xFF8B7ED8),
      foregroundColor: Colors.white,
      onTap: controller.refreshData,
    );
  }
}