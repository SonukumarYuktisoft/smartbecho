import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/customer/customer_sections/customer_data_grid_section.dart';
import 'package:smartbecho/views/customer/customer_sections/customer_floating_actions.dart';
import 'package:smartbecho/views/customer/customer_sections/customer_load_more_button.dart';
import 'package:smartbecho/views/customer/customer_sections/customer_search_filter_section.dart';
import 'package:smartbecho/views/customer/customer_sections/customer_stats_section.dart';

/// Main screen for customer management
/// Displays customer list with search, filters, and analytics
class CustomerManagementScreen extends StatelessWidget {
  final CustomerController controller = Get.put(CustomerController());

  CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.grey[50],
      floatingActionButton: CustomerFloatingActions(controller: controller),
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: CustomerStatsSection(controller: controller),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyHeaderDelegate(
                  child: CustomerSearchFilterSection(controller: controller),
                  minHeight: 80,
                  maxHeight: 80,
                ),
              ),
              SliverToBoxAdapter(
                child: CustomerDataGridSection(controller: controller),
              ),
              SliverToBoxAdapter(
                child: CustomerLoadMoreButton(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom app bar with navigation and analytics button
  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: "Customer Management",
      onPressed: () {
        Get.find<BottomNavigationController>().setIndex(0);
        Get.back();
      },
      actionItem: [
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.customerAnalytics),
          icon: const Icon(Icons.analytics_outlined),
          tooltip: 'Customer Analytics',
        ),
      ],
    );
  }

  /// Handle pull-to-refresh action
  Future<void> _handleRefresh() async {
    await Future.wait([
      controller.loadCustomersFromApi(),
      controller.getTopCardStats(),
    ]);
  }
}

/// Sticky header delegate for search and filter section
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}