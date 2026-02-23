// FILE: lib/views/customer_dues/sections/dues_tab_content_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/models/customer%20dues%20management/all_customer_dues_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/views/customer%20dues/components/customer_dues_sections/dues_customer_card.dart';

class DuesTabContentSection extends StatelessWidget {
  final CustomerDuesController controller;
  final TabController tabController;
  final ScrollController scrollController;

  const DuesTabContentSection({
    required this.controller,
    required this.tabController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [_buildDuesTab(), _buildPaidTab()],
    );
  }

  Widget _buildDuesTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingIndicator();
      }

      final duesCustomers = controller.allDues;

      if (duesCustomers.isEmpty) {
        return SingleChildScrollView(
          child: _buildEmptyState(
            'No dues found',
            'All customers have paid their dues',
          ),
        );
      }

      return AppRefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildCustomerList(duesCustomers, isDuesSection: true),
              _buildLoadMoreIndicator(),
              SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPaidTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingIndicator();
      }

      final paidCustomers = controller.paidDues;

      if (paidCustomers.isEmpty) {
        return SingleChildScrollView(
          child: _buildEmptyState(
            'No paid customers',
            'Customers who have paid will appear here',
          ),
        );
      }

      return AppRefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildCustomerList(paidCustomers, isDuesSection: false),
              _buildLoadMoreIndicator(),
              SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }

  // Widget _buildCustomerGrid(
  //   List<CustomerDue> customers, {
  //   required bool isDuesSection,
  // }) {
  //   return Container(
  //     margin: EdgeInsets.all(16),
  //     child: GridView.builder(
  //       shrinkWrap: true,
  //       physics: NeverScrollableScrollPhysics(),
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 2,
  //         crossAxisSpacing: 12,
  //         mainAxisSpacing: 12,
  //         childAspectRatio: 0.75,
  //       ),
  //       itemCount: customers.length,
  //       itemBuilder: (context, index) {
  //         final customer = customers[index];
  //         return DuesCustomerCard(
  //           customer: customer,
  //           controller: controller,
  //           isDuesSection: isDuesSection,
  //         );
  //       },
  //     ),
  //   );
  // }

   Widget _buildCustomerList(
    List<CustomerDue> customers, {
    required bool isDuesSection,
  }) {
    return Container(
      margin: EdgeInsets.all(16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return DuesCustomerCard(
            customer: customer,
            controller: controller,
            isDuesSection: isDuesSection,
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryLight, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading dues...',
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

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryLight,
                  strokeWidth: 2,
                ),
                SizedBox(height: 8),
                Text(
                  'Loading more...',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
