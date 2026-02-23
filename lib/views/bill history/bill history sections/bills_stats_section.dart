import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/this_month_aaded_stock_controller.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';
import 'package:smartbecho/views/bill%20history/components/show_stats_info.dart';

class BillsStatsSection extends GetView<BillHistoryController> {
  const BillsStatsSection({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      height: 140,
      child: Obx(() {
        if (controller.isLoadingStats.value) {
          return _buildLoading();
        }

        final stats = controller.stockStats.value;
       
        if (stats == null) return  SizedBox.shrink();

        return _buildStatsList(context, stats);
      }),
    );
  }

  Widget _buildLoading() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: CircularProgressIndicator(
          
        ),
      ),
    );
  }

  Widget _buildStatsList(BuildContext context, dynamic stats) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        BuildStatsCard(
          label: 'Total available\nStock',
          value: stats.totalStocks.toString(),
          icon: Icons.inventory_2,
          color: Colors.black,
            isAmount:  false,
        ),
        SizedBox(width: 12),
        BuildStatsCard(
          label: 'Last Month\nadded stock',
          value: stats.lastMonthStock.toString(),
          icon: Icons.calendar_month,
          color: Colors.deepPurpleAccent,
            isAmount:  false,

        ),
        SizedBox(width: 12),
        BuildStatsCard(
          label: 'Today Added\nstock',
          value: stats.todayStock.toString(),
          icon: Icons.today,
            isAmount:  false,
          color: Colors.green,
          onTap: () => showStockItemsDialog(
            context,
            stats,
            StockWhenAdded.today,
          ),
        ),
        SizedBox(width: 12),
        BuildStatsCard(
          label: 'This Month\nadded stock',
          value: stats.thisMonthStock.toString(),
          icon: Icons.date_range,
            isAmount:  false,
          color: Colors.blue,
          onTap: () => showStockItemsDialog(
            context,
            stats,
            StockWhenAdded.thisMonth,
          ),
        ),
        SizedBox(width: 12),
        BuildStatsCard(
          label: 'This Month\nonline Added Stock',
          icon: Icons.arrow_forward_ios,
            isAmount:  false,
          color: Colors.deepOrange,
          onTap: () => controller.navigateToThisMonthStock(),
          value: controller.formateOnlineStockTotal,
          

        ),

      ],
    );
  }
}