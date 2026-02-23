import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/stock_history_item_response.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/constant/app_images_string.dart';

class StockHeaderSection extends StatelessWidget {
  final StockItem stockItem;

  const StockHeaderSection({
    Key? key,
    required this.stockItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            AppImagesString.detailsPagePatternImage,
          ),
          fit: BoxFit.cover,
        ),
        gradient: const LinearGradient(
          colors: AppColors.primaryGradientLight,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge at Top Right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),

          // Company Name (Center)
          Center(
            child: Column(
              children: [
                Text(
                  'Company',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stockItem.company.isNotEmpty
                      ? stockItem.company.toUpperCase()
                      : 'N/A',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Item ID and Model Row (Bottom)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                label: 'Item ID',
                value: stockItem.billMobileItem.toString(),
                onTap: () => _copyToClipboard(
                  stockItem.billMobileItem.toString(),
                  'Item ID',
                ),
              ),
              _buildInfoItem(
                label: 'Model',
                value: stockItem.model.toUpperCase(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor =
        stockItem.qty > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    IconData statusIcon =
        stockItem.qty > 0 ? Icons.check_circle : Icons.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            stockItem.qty > 0 ? 'In Stock' : 'Out of Stock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.copy,
                  color: Colors.white.withOpacity(0.7),
                  size: 14,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      '$label copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      icon: const Icon(Icons.copy, color: Colors.white),
      margin: const EdgeInsets.all(16),
    );
  }
}