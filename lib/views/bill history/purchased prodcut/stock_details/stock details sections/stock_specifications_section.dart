import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/stock_history_item_response.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class StockSpecificationsSection extends StatelessWidget {
  final StockItem stockItem;

  const StockSpecificationsSection({
    Key? key,
    required this.stockItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color companyColor = _getCompanyColor(stockItem.company);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Specifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          // Item Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildItemCard(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemCard() {
    final companyColor = _getCompanyColor(stockItem.company);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x15D1D0D0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Name with Color Badge
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: companyColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${AppFormatterHelper.capitalizeFirst(stockItem.company)} - ${stockItem.model.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Model Name
          Text(
            'Model: ${stockItem.model}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),

          // Price and Quantity Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      size: 12,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Price - ${stockItem.formattedPrice}/Unit',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),

              // Quantity
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Quantity - ${stockItem.qty}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dotted Divider
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: AppDottedLine(),
          ),
          const SizedBox(height: 8),

          // Specs Row
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (stockItem.ram > 0)
                _buildSpecChip(
                  icon: Icons.memory,
                  label: 'RAM: ${stockItem.ram}GB',
                ),
              if (stockItem.rom > 0)
                _buildSpecChip(
                  icon: Icons.storage,
                  label: 'ROM: ${stockItem.rom}GB',
                ),
              if (stockItem.color.isNotEmpty)
                _buildSpecChip(
                  icon: Icons.palette_outlined,
                  label: 'Color: ${AppFormatterHelper.capitalizeFirst(stockItem.color)}',
                ),
              _buildSpecChip(
                icon: Icons.category_outlined,
                label: 'Category: ${stockItem.categoryDisplayName}',
              ),
            ],
          ),

          // Additional Info - IMEI
          if (stockItem.imei != null && stockItem.imei!.isNotEmpty) ...[
            const SizedBox(height: 12),
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: AppDottedLine(),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              label: 'IMEI',
              value: stockItem.imei!,
              icon: Icons.qr_code,
              copyable: true,
            ),
          ],

          // Additional Info - HSN Code
          if (stockItem.hsnCode != null && stockItem.hsnCode!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              label: 'HSN Code',
              value: stockItem.hsnCode!,
              icon: Icons.code,
              copyable: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    bool copyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              color: Colors.grey[600],
              onPressed: () => _copyToClipboard(value, label),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Color _getCompanyColor(String company) {
    switch (company.toLowerCase()) {
      case 'apple':
        return const Color(0xFF1E293B);
      case 'samsung':
        return const Color(0xFF3B82F6);
      case 'xiaomi':
        return const Color(0xFFF59E0B);
      case 'mix':
      case 'mixu':
        return const Color(0xFF16A085);
      case 'oppo':
        return const Color(0xFF10B981);
      case 'vivo':
        return const Color(0xFFEF4444);
      case 'oneplus':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
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