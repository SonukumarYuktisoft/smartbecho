import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/views/bill%20history/bill%20history%20sections/bills_fab.dart';
import 'package:smartbecho/views/bill%20history/bill%20history%20sections/bills_filter_sheet.dart';
import 'package:smartbecho/views/bill%20history/bill%20history%20sections/bills_stats_section.dart';
import 'package:smartbecho/views/bill%20history/bill%20history%20sections/bills_table_section.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';

class BillsHistoryPage extends GetView<BillHistoryController> {
  const BillsHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.grey[50],
      body: _buildBody(),
      floatingActionButton: BillsFAB(),
    );
  }

  // ==================== AppBar ====================
  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Purchase Bills',
      onPressed: () => Get.find<BottomNavigationController>().setIndex(0),
      actionItem: [
        IconButton(
          onPressed: controller.showAnalyticsModal,
          icon: const Icon(Icons.analytics_outlined),
        ),
      ],
    );
  }

  // ==================== Body ====================
  Widget _buildBody() {
    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) => _handleScroll(scrollInfo),
        child: AppRefreshIndicator(
          onRefresh: controller.refreshBills,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildLoadingIndicator(),
              _buildStatsSection(),
              _buildStickySearchBar(),
              _buildBillsTable(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Scroll Handler ====================
  bool _handleScroll(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 &&
        !controller.isLoadingMore.value &&
        !controller.isLoading.value) {
      controller.loadMoreBills();
    }
    return false;
  }

  // ==================== Loading Indicator ====================
  Widget _buildLoadingIndicator() {
    return SliverToBoxAdapter(
      child: Obx(
        () =>
            controller.isLoading.value && controller.bills.isEmpty
                ? const LinearProgressIndicator(
                
                )
                : const SizedBox.shrink(),
      ),
    );
  }

  // ==================== Stats Section ====================
  Widget _buildStatsSection() {
    return SliverToBoxAdapter(child: BillsStatsSection());
  }

  // ==================== Sticky Search Bar ====================
  Widget _buildStickySearchBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        child: CommonSearchBar(
          readOnly: true,
          controller: controller.searchheadController,
          onTap: () => _showFilterBottomSheet(),
          searchQuery: controller.searchQuery,
          hintText: 'Filter your bills by vendor, invoice...',
          onChanged: controller.onSearchChanged,
          onFilter: () => _showFilterBottomSheet(),
        ),
        minHeight: 80,
        maxHeight: 80,
      ),
    );
  }

  // ==================== Bills Table ====================
  Widget _buildBillsTable() {
    return BillsTableSection();
  }

  // ==================== Show Filter Sheet ====================
  void _showFilterBottomSheet() {
    BillsFilterSheet.show(controller);
  }
}
