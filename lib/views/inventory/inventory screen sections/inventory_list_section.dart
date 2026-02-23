import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/views/inventory/inventory%20screen%20sections/inventory_card_widget.dart';

class InventoryListSection extends StatelessWidget {
  final InventoryController controller;

  const InventoryListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isInventoryDataLoading.value
          ? _buildShimmerList()
          : controller.hasInventoryDataError.value
              ? _buildErrorWidget()
              : _buildInventoryList(),
    );
  }

  Widget _buildInventoryList() {
    return Obx(() {
      if (controller.inventoryItems.isEmpty &&
          !controller.isInventoryDataLoading.value) {
        return _buildEmptyState();
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 100) {
            if (!controller.isLoadingMore.value &&
                controller.hasMoreData.value &&
                controller.searchQuery.value.trim().isEmpty &&
                !controller.isInventoryDataLoading.value) {
              controller.loadMoreData();
            }
          }
          return false;
        },
        child: AppRefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
          },
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: controller.inventoryItems.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.inventoryItems.length) {
                return _buildLoadingMoreCard();
              }

              final item = controller.inventoryItems[index];
              return InventoryCardWidget(
                item: item,
                index: index,
                controller: controller,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildLoadingMoreCard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryLight,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Spacer(),
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 150,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No inventory items found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your filters or add new items',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              controller.inventoryDataerrorMessage.value,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.refreshData,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}