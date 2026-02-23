import 'package:flutter/material.dart';
import 'package:smartbecho/models/bill%20history/bill_history_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';

class BillAmountDetailsSection extends StatelessWidget {
  final Bill bill;

  const BillAmountDetailsSection({
    Key? key,
    required this.bill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate GST amounts
    final gstAmount = bill.amount - bill.withoutGst;
    final sgstAmount = gstAmount / 2;
    final cgstAmount = gstAmount / 2;
    final totalGstPercent = bill.gst;
    final sgstPercent = totalGstPercent / 2;
    final cgstPercent = totalGstPercent / 2;

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
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    size: 20,
                    color: Color(0xFF5B68F4),
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
                  amount: bill.withoutGst.toStringAsFixed(0),
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(height: 12),
                _buildAmountRow(
                  label: 'CGST(${cgstPercent.toStringAsFixed(1)}%)',
                  amount: cgstAmount.toStringAsFixed(0),
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                _buildAmountRow(
                  label: 'SGST(${sgstPercent.toStringAsFixed(1)}%)',
                  amount: sgstAmount.toStringAsFixed(0),
                  color: const Color(0xFF06B6D4),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
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
                  bill.formattedAmount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),

          // Outstanding Dues (if any)
          if (bill.dues > 0) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outstanding Dues',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bill.formattedDues,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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