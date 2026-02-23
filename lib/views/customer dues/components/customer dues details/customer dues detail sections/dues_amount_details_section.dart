import 'package:flutter/material.dart';
import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/app_colors.dart';

class DuesAmountDetailsSection extends StatelessWidget {
  final CustomerDueDetailsModel dueDetails;
  final bool isDark;

  const DuesAmountDetailsSection({
    Key? key,
    required this.dueDetails,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // Amount Details Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 20,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Amount Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Rows
            _buildAmountRow(
              'Total Due',
              dueDetails.totalDue,
              const Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            _buildAmountRow(
              'Total Paid',
              dueDetails.totalPaid,
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            _buildAmountRow(
              'Remaining Due',
              dueDetails.remainingDue,
              const Color(0xFFF59E0B),
            ),
            
            const SizedBox(height: 24),
            
            // Divider
            Divider(
              color: isDark 
                  ? const Color(0xFF334155) 
                  : const Color(0xFFE5E7EB),
              thickness: 1,
            ),
            
            const SizedBox(height: 20),

            // Date Details Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Date Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF1F5F9) : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Date Rows
            _buildDateTimeRow(
              'Creation Date', 
              _formatDate(dueDetails.creationDateTime),
            ),
            const SizedBox(height: 12),
            _buildDateTimeRow(
              'Payment Retriable Date', 
              _formatDate(dueDetails.paymentRetriableDateTime),
            ),
            
            // Show Approved By if available
            if (dueDetails.approvedBy != null) ...[
              const SizedBox(height: 12),
              _buildDateTimeRow(
                'Approved By', 
                dueDetails.approvedBy!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: valueColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark 
                    ? const Color(0xFF94A3B8) 
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        Text(
          '₹${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark 
                ? const Color(0xFF94A3B8) 
                : const Color(0xFF6B7280),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF334155) 
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark 
                  ? const Color(0xFFF1F5F9) 
                  : const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM, yyyy').format(date);
  }
}