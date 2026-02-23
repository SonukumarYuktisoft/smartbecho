import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';
import 'package:intl/intl.dart';

class PaymentHistorySection extends StatelessWidget {
  final CustomerDueDetailsModel dueDetails;
  final bool isDark;
  final RxBool isExpanded;

  const PaymentHistorySection({
    Key? key,
    required this.dueDetails,
    required this.isExpanded,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dueDetails.partialPayments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            spreadRadius: 0,
            blurRadius: isDark ? 8 : 20,
            offset: Offset(0, isDark ? 4 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    isExpanded.value = !isExpanded.value;
                  },
                  child: Obx(() => Icon(
                    isExpanded.value 
                        ? Icons.keyboard_arrow_up_rounded 
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF5B6CF6),
                    size: 24,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Items
            Obx(() {
              final paymentsToShow = isExpanded.value
                  ? dueDetails.partialPayments.reversed.toList()
                  : dueDetails.partialPayments.reversed.take(3).toList();

              return Column(
                children: paymentsToShow
                    .map((payment) => _buildPaymentItem(payment))
                    .toList(),
              );
            }),

            // Show More/Less Button
            if (dueDetails.partialPayments.length > 3) ...[
              const SizedBox(height: 12),
              Obx(() => GestureDetector(
                onTap: () {
                  isExpanded.value = !isExpanded.value;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6CF6).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF5B6CF6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isExpanded.value 
                          ? 'Show Less' 
                          : 'Show More (${dueDetails.partialPayments.length - 3})',
                      style: const TextStyle(
                        color: Color(0xFF5B6CF6),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(PartialPaymentDetail payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF5B6CF6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5B6CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5B6CF6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Payment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAmount(payment.paidAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid on ${_formatDate(payment.paidDateTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}