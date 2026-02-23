import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_stock_comtroller.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/inventory/components/company_stock_grid.dart';
import 'package:smartbecho/views/inventory/components/low_stock_alert_card.dart';
import 'package:smartbecho/views/inventory/widgets/sales_dashboard_shimmer.dart';

class SalesStockDashboard extends StatelessWidget {
  final InventorySalesStockController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Sales & Inventory Dashboard'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: controller.fetchInventoryData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works
            child: Column(
              children: [
                // buildCustomAppBar("Sales & Inventory Dashboard", isdark: true),

                // Single Obx to handle all loading states
                Obx(() {
                  // Show shimmer only when BOTH main loading states are true
                  final isMainLoading = controller.isLoading.value;
                  final isSummaryLoading = controller.isbusinessSummaryCardsLoading.value;
                  final shouldShowShimmer = isMainLoading && isSummaryLoading;

                  if (shouldShowShimmer) {
                    return ShimmerDashboardLoading();
                  }

                  // Show content when data is available or loading is complete
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Summary Section
                      BusinessSummaryCard(),
                      const SizedBox(height: 20),

                      // Low Stock Alerts Section
                      LowStockAlertsCard(),
                      const SizedBox(height: 20),

                      // Company Stock Grid Section
                      CompanyStockGrid(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// widgets/business_summary_card.dart
class BusinessSummaryCard extends StatelessWidget {
  final InventorySalesStockController controller =
      Get.find<InventorySalesStockController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state for business summary only
      if (controller.isbusinessSummaryCardsLoading.value) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Business Overview',
                      style: AppStyles.custom(
                        color: Color(0xFF1A1A1A),
                        size: 20,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Loading indicator
              Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Loading business overview...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // Show error state if there's an error
      if (controller.hasbusinessSummaryCardsError.value) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Business Overview',
                      style: AppStyles.custom(
                        color: Color(0xFF1A1A1A),
                        size: 20,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load business summary',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.businessSummaryCardsErrorMessage.value,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchBusinesssummaryegories(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Show main content when data is loaded
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF4CAF50),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Business Overview',
                    style: AppStyles.custom(
                      color: Color(0xFF1A1A1A),
                      size: 20,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metric Cards Grid (2 cards per row) - Fixed responsive layout
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.business_outlined,
                        title: 'Companies',
                        value: '${controller.totalCompaniesAvailable}',
                        color: const Color(0xFF8B5CF6),
                        subtitle: 'Active',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.phone_android_outlined,
                        title: 'Models',
                        value: '${controller.totalModelsAvailable}',
                        color: const Color(0xFF06B6D4),
                        subtitle: 'Available',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.inventory_outlined,
                        title: 'Stock',
                        value: '${controller.totalStockAvailable}',
                        color: const Color(0xFF10B981),
                        subtitle: 'In inventory',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.trending_up_outlined,
                        title: 'Sold Units',
                        value: '${controller.monthlyPhoneSold}',
                        color: const Color(0xFFF59E0B),
                        subtitle: 'Total sales',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.emoji_events_outlined,
                        title: 'Top Brand',
                        value: controller.topSellingBrandAndModel.isEmpty 
                            ? 'N/A' 
                            : controller.topSellingBrandAndModel,
                        color: const Color(0xFFEF4444),
                        subtitle: 'Best seller',
                        isTextValue: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.currency_rupee_outlined,
                        title: 'Revenue',
                        value: '₹${controller.totalRevenue.toStringAsFixed(0)}',
                        color: const Color(0xFF8B5CF6),
                        subtitle: 'Total earnings',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Add your download/print functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Download Sales Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
    bool isTextValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: isTextValue ? 14 : 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color(0xFF6B7280).withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}