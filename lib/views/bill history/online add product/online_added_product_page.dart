import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20sections/online_products_floating_actions.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20sections/online_products_grid_section.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20sections/online_products_search_section.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20sections/online_products_stats_section.dart';
class OnlineProductsPage extends GetView<OnlineProductsController> {
  OnlineProductsPage({Key? key}) : super(key: key);

  final BillHistoryController billHistoryController =
      Get.put(BillHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Online Added Products'),
      floatingActionButton: OnlineProductsFloatingActions(
        billHistoryController: billHistoryController,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: controller.refreshProducts,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              slivers: [
                _buildLoadingIndicator(),
                SliverToBoxAdapter(
                  child: OnlineProductsStatsSection(controller: controller),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: StickyHeaderDelegate(
                    child: OnlineProductsSearchSection(controller: controller),
                    minHeight: 80,
                    maxHeight: 80,
                  ),
                ),
                OnlineProductsGridSection(controller: controller),
                _buildLoadingMoreIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle scroll notifications for infinite scroll
  bool _handleScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 200 &&
        !controller.isLoadingMore.value &&
        !controller.isLoading.value) {
      controller.loadMoreProducts();
    }
    return false;
  }

  /// Build top loading indicator
  Widget _buildLoadingIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return LinearProgressIndicator(
        
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  /// Build bottom loading more indicator
  Widget _buildLoadingMoreIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoadingMore.value) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
              
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
