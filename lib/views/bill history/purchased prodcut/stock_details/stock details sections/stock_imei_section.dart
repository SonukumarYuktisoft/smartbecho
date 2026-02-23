import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/stock_history_item_response.dart';

class StockImeiSection extends StatelessWidget {
  final StockItem stockItem;

  const StockImeiSection({
    Key? key,
    required this.stockItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorImeiMap = stockItem.parsedColorImeiMapping;
    if (colorImeiMap == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'IMEI Numbers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: ${stockItem.totalImeiCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: colorImeiMap.entries.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final entry = colorImeiMap.entries.elementAt(index);
              return _buildImeiColorCard(entry.key, entry.value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImeiColorCard(String colorName, List<String> imeiList) {
    Color colorBadge = _getColorBadgeColor(colorName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x15D1D0D0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colorBadge,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorBadge.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                colorName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorBadge.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorBadge.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${imeiList.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorBadge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...imeiList.asMap().entries.map((imeiEntry) {
            final index = imeiEntry.key;
            final imei = imeiEntry.value;

            return Padding(
              padding: EdgeInsets.only(top: index > 0 ? 6 : 0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorBadge.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorBadge,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      imei,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 14),
                    color: Colors.grey[600],
                    onPressed: () => _copyToClipboard(imei, 'IMEI'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getColorBadgeColor(String colorName) {
    switch (colorName.toUpperCase()) {
      case 'RED':
        return const Color(0xFFEF4444);
      case 'BLUE':
        return const Color(0xFF3B82F6);
      case 'GREEN':
        return const Color(0xFF10B981);
      case 'BLACK':
        return const Color(0xFF1E293B);
      case 'WHITE':
        return const Color(0xFF94A3B8);
      case 'GOLD':
        return const Color(0xFFF59E0B);
      case 'SILVER':
        return const Color(0xFF6B7280);
      case 'PINK':
        return const Color(0xFFEC4899);
      case 'PURPLE':
        return const Color(0xFF8B5CF6);
      case 'YELLOW':
        return const Color(0xFFEAB308);
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