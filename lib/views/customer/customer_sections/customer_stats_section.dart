import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';

/// Horizontal scrolling stats cards section
/// Shows total customers, repeat customers, and new customers this month
class CustomerStatsSection extends StatelessWidget {
  final CustomerController controller;

  const CustomerStatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Obx(() {
        if (controller.isLoadingState.value) {
          return _buildLoadingState();
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _getStatsData().length,
          itemBuilder: (context, index) {
            final stat = _getStatsData()[index];
            return FeatureVisitor(
              featureKey: FeatureKeys.CUSTOMER.getStatsCustomer,

              child: BuildStatsCard(
                label: stat['title'] as String,
                value: stat['value'] as String,
                icon: stat['icon'] as IconData,
                color: stat['color'] as Color,
                onTap: stat['onTap'] as VoidCallback,
                isAmount: false,
              ),
            );
          },
        );
      }),
    );
  }

  /// Build loading state with progress indicator
  Widget _buildLoadingState() {
    return Center(
      child: Container(
        height: 130,
        width: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  /// Get stats data configuration
  List<Map<String, dynamic>> _getStatsData() {
    return [
      {
        'title': 'Total Customers',
        'value': controller.totalCustomers.value.toString(),
        'icon': Icons.people_outline,
        'color': AppColors.primaryLight,
        'onTap': () => _handleTotalCustomersTap(),
      },
      {
        'title': 'Repeat Customers',
        'value': controller.repeatedCustomers.value.toString(),
        'icon': Icons.refresh_outlined,
        'color': const Color(0xFFFF9500),
        'onTap': () => controller.showRepeatedCustomersModal(),
      },
      {
        'title': 'New This Month',
        'value': controller.newCustomersThisMonth.value.toString(),
        'icon': Icons.person_add_outlined,
        'color': const Color(0xFF51CF66),
        'onTap': () => _handleNewCustomersTap(),
      },
    ];
  }

  /// Handle total customers card tap
  void _handleTotalCustomersTap() {
    // Add implementation for total customers action
    print('Total customers tapped');
  }

  /// Handle new customers card tap
  void _handleNewCustomersTap() {
    // Add implementation for new customers action
    print('New this month tapped');
  }
}
