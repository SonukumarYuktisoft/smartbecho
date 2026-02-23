// FILE: lib/views/customer_dues/customer_dues_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/customer%20dues/components/customer_dues_sections/dues_search_filter_section.dart';
import 'package:smartbecho/views/customer%20dues/components/customer_dues_sections/dues_summary_section.dart';
import 'package:smartbecho/views/customer%20dues/components/customer_dues_sections/dues_tab_content_section.dart';
import 'package:smartbecho/views/customer%20dues/components/customer_dues_sections/dues_tabs_section.dart';

class CustomerDuesManagementScreen extends StatefulWidget {
  @override
  _CustomerDuesManagementScreenState createState() =>
      _CustomerDuesManagementScreenState();
}

class _CustomerDuesManagementScreenState
    extends State<CustomerDuesManagementScreen>
    with SingleTickerProviderStateMixin {
  final CustomerDuesController controller = Get.find<CustomerDuesController>();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.onTabChanged(_tabController.index == 0 ? 'dues' : 'paid');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.loadMoreDues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Dues Management",
        onPressed: () {
          Get.find<BottomNavigationController>().setIndex(0);
        },
        actionItem: [
          IconButton(
            onPressed: controller.showAnalyticsModal,
            icon: Icon(Icons.analytics_outlined),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Summary Cards Section
            DuesSummarySection(controller: controller),

            // Search & Filter Section
            DuesSearchFilterSection(controller: controller),

            // Tabs Section
            DuesTabsSection(
              controller: controller,
              tabController: _tabController,
            ),

            // Tab Content Section
            Expanded(
              child: DuesTabContentSection(
                controller: controller,
                tabController: _tabController,
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: controller.createDueEntry,
      backgroundColor: AppColors.primaryLight,
      label: Text(
        'Add Due',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      icon: Icon(Icons.add, color: Colors.white),
    );
  }
}