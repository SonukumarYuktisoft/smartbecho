import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_stock_comtroller.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/views/inventory/components/stock_alert_detail_page.dart';

class LowStockAlertsCard extends StatelessWidget {
  final InventorySalesStockController controller =
      Get.find<InventorySalesStockController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final alerts = controller.lowStockAlerts.value;
      const int maxItemsToShow = 5;

      // Show loading state if data is still being fetched
      if (controller.isLoading.value || alerts == null) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Low Stock Alerts',
                    style: AppStyles.custom(
                      color: Color(0xFF1A1A1A),
                      size: 20,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '...',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading stock alerts...',
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

      // Show empty state if no alerts
      if (controller.totalAlerts == 0) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Low Stock Alerts',
                    style: AppStyles.custom(
                      color: Color(0xFF1A1A1A),
                      size: 20,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '0',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All Stock Levels Good!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No low stock alerts at the moment.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      // Show alerts when data is available
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low Stock Alerts',
                  style: AppStyles.custom(
                    color: Color(0xFF1A1A1A),
                    size: 20,
                    weight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.totalAlerts}',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Critical Alerts (Show max 5)
            if (alerts.payload.critical.isNotEmpty) ...[
              _buildSectionHeader(
                'Critical Stock',
                alerts.payload.critical.length,
                maxItemsToShow,
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: 8),
              ...alerts.payload.critical
                  .take(maxItemsToShow)
                  .map(
                    (alert) => _buildAlertItem(
                      alert,
                      const Color(0xFFEF4444),
                      '',
                      Icons.error_outline,
                    ),
                  ),
              if (alerts.payload.critical.length > maxItemsToShow)
                _buildViewMoreButton(
                  'Critical',
                  alerts.payload.critical.length - maxItemsToShow,
                  const Color(0xFFEF4444),
                  () => _navigateToDetailPage(
                    context,
                    'Critical',
                    alerts.payload.critical,
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Low Stock Alerts (Show max 5)
            if (alerts.payload.low.isNotEmpty) ...[
              _buildSectionHeader(
                'Low Stock',
                alerts.payload.low.length,
                maxItemsToShow,
                const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 8),
              ...alerts.payload.low
                  .take(maxItemsToShow)
                  .map(
                    (alert) => _buildAlertItem(
                      alert,
                      const Color(0xFFF59E0B),
                      '',
                      Icons.warning_amber_outlined,
                    ),
                  ),
              if (alerts.payload.low.length > maxItemsToShow)
                _buildViewMoreButton(
                  'Low Stock',
                  alerts.payload.low.length - maxItemsToShow,
                  const Color(0xFFF59E0B),
                  () => _navigateToDetailPage(
                    context,
                    'Low Stock',
                    alerts.payload.low,
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Out of Stock Alerts (Show max 5)
            if (alerts.payload.outOfStock.isNotEmpty) ...[
              _buildSectionHeader(
                'Out of Stock',
                alerts.payload.outOfStock.length,
                maxItemsToShow,
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: 8),
              ...alerts.payload.outOfStock
                  .take(maxItemsToShow)
                  .map(
                    (alert) => _buildAlertItem(
                      alert,
                      const Color(0xFFEF4444),
                      '',
                      Icons.cancel_outlined,
                    ),
                  ),
              if (alerts.payload.outOfStock.length > maxItemsToShow)
                _buildViewMoreButton(
                  'Out of Stock',
                  alerts.payload.outOfStock.length - maxItemsToShow,
                  const Color(0xFFEF4444),
                  () => _navigateToDetailPage(
                    context,
                    'Out of Stock',
                    alerts.payload.outOfStock,
                  ),
                ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'See Restock Reminder',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(
    String title,
    int totalCount,
    int maxShow,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Showing ${totalCount > maxShow ? maxShow : totalCount} of $totalCount',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildViewMoreButton(
    String category,
    int remainingCount,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.expand_more, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              'View $remainingCount more $category items',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(
    String text,
    Color color,
    String prefix,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$prefix $text',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailPage(
    BuildContext context,
    String category,
    List<String> items,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockAlertsDetailPage(category: category, items: items),
      ),
    );
  }
}