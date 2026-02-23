import 'package:flutter/material.dart';
import 'package:smartbecho/models/bill%20history/stock_history_item_response.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';

class StockAmountSection extends StatelessWidget {
  final StockItem stockItem;

  const StockAmountSection({
    Key? key,
    required this.stockItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // Header with Icon
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    size: 20,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Amount Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Amount Breakdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildAmountRow(
                  label: 'Subtotal (Without GST)',
                  amount: stockItem.formattedWithoutGst,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(height: 12),
                _buildAmountRow(
                  label: 'GST (${stockItem.gstPercentage.toStringAsFixed(1)}%)',
                  amount: stockItem.formattedGstAmount,
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dotted Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: AppDottedLine(),
            ),
          ),

          // Total Amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  stockItem.formattedWithGst,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}