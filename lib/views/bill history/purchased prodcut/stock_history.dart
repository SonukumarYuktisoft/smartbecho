import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock%20history%20sections/stock_filter_bottom_sheet.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock%20history%20sections/stock_floating_action_button.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock%20history%20sections/stock_items_grid_section.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock%20history%20sections/stock_stats_section.dart';

class StockHistoryPage extends GetView<BillHistoryController> {
  const StockHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Purchased Items'),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: () => controller.refreshStockItems(),
          child: NotificationListener(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200 &&
                  !controller.isLoadingMoreStock.value &&
                  !controller.isLoadingStock.value) {
                controller.loadMoreStockItems();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: <Widget>[
                // Stats section
                SliverToBoxAdapter(
                  child: StockStatsSection(controller: controller),
                ),

                // Search bar
                SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: StickyHeaderDelegate(
                    child: CommonSearchBar(
                      controller: controller.searchController,
                      searchQuery: RxString(''),
                      hintText: 'Search by model, company...',
                      onFilter: () => showStockFilterBottomSheet(context, controller),
                      onChanged: (value) => controller.onSearchChanged(value),
                    ),
                    minHeight: 80,
                    maxHeight: 80,
                  ),
                ),

                // Stock items grid
                StockItemsGridSection(controller: controller),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: buildStockFloatingActionButtons(),
    );
  }
}
