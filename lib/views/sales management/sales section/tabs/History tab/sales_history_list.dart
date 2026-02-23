// FILE: lib/views/sales_management/sections/sales_history_list.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/widgets/sales_card_widget.dart';

class SalesHistoryList extends StatelessWidget {
  final SalesManagementController controller;

  const SalesHistoryList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError.value && controller.allSales.isEmpty) {
        return SliverToBoxAdapter(child: _buildErrorState());
      }

      if (controller.isLoading.value && controller.allSales.isEmpty) {
        return SliverToBoxAdapter(child: _buildLoadingState());
      }

      if (controller.allSales.isEmpty) {
        return SliverToBoxAdapter(child: _buildEmptyState());
      }

      return SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Loading indicator at end
              if (index == controller.allSales.length) {
                return controller.isLoadingMore.value
                    ? Container(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryLight,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              }

              final sale = controller.allSales[index];
              return SalesCardWidget(
                sale: sale,
                controller: controller,
              );
            },
            childCount:
                controller.allSales.length +
                (controller.isLoadingMore.value ? 1 : 0),
          ),
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          SizedBox(height: 16),
          Text(
            'Error Loading Sales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshData(),
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading sales history...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Sales Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'No sales match your search criteria'
                : 'No sales available',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          if (controller.searchQuery.value.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => controller.clearSearch(),
              icon: Icon(Icons.clear),
              label: Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}