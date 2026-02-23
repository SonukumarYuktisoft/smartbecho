// FILE: lib/views/sales_management/sections/sales_history_tab.dart
import 'package:flutter/material.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/History%20tab/sales_history_list.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/History%20tab/sales_history_search_filter.dart';

class SalesHistoryTab extends StatelessWidget {
  final SalesManagementController controller;

  const SalesHistoryTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent &&
            !controller.isLoadingMore.value &&
            !controller.isLoading.value) {
          controller.loadMoreSales();
        }
        return false;
      },
      child: AppRefreshIndicator(
        onRefresh: controller.refreshData,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              floating: true,
              pinned: true,
              delegate: StickyHeaderDelegate(
                child: SalesHistorySearchFilter(controller: controller),
                minHeight: 80,
                maxHeight: 80,
              ),
            ),
            SalesHistoryList(controller: controller),
          ],
        ),
      ),
    );
  }
}
