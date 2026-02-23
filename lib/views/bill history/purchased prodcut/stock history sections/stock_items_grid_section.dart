
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock%20history%20sections/stock_item_card.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock%20history%20sections/stock_state_widgets.dart' hide StockItemCard;

class StockItemsGridSection extends StatelessWidget {
  final BillHistoryController controller;

  const StockItemsGridSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: Obx(() {
        if (controller.stockError.value.isNotEmpty &&
            controller.stockItems.isEmpty) {
          return SliverToBoxAdapter(
            child: StockErrorState(controller: controller),
          );
        }

        if (controller.isLoadingStock.value && controller.stockItems.isEmpty) {
          return SliverToBoxAdapter(
            child: StockLoadingState(),
          );
        }

        if (controller.stockItems.isEmpty) {
          return SliverToBoxAdapter(
            child: StockEmptyState(controller: controller),
          );
        }

        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final stockItem = controller.stockItems[index];
              return StockItemCard(
                stockItem: stockItem,
                controller: controller,
              );
            },
            childCount: controller.stockItems.length,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
        );
      }),
    );
  }
}
