import 'package:flutter/material.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';

class SalePricingDetailsSection extends StatelessWidget {
  final SaleDetailResponse sale;

  const SalePricingDetailsSection({Key? key, required this.sale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 20,
                  color:AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pricing Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price Breakdown
          _buildPriceRow('Subtotal (Without SST)', sale.formattedWithoutGst),
          const SizedBox(height: 8),
          _buildPriceRow(
            'SGST(${(sale.gst / 2).toStringAsFixed(0)}%)',
            '₹${((sale.withGst - sale.withoutGst) / 2).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'CGST(${(sale.gst / 2).toStringAsFixed(0)}%)',
            '₹${((sale.withGst - sale.withoutGst) / 2).toStringAsFixed(2)}',
          ),

          if (sale.accessoriesCost > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Accessories', sale.formattedAccessoriesCost),
          ],

          if (sale.extraCharges > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Extra Charges', sale.formattedExtraCharges),
          ],

          if (sale.repairCharges > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Repair Charges', sale.formattedRepairCharges),
          ],

          if (sale.totalDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Discount',
              '- ${sale.formattedTotalDiscount}',
              valueColor: Colors.red,
            ),
          ],

          const SizedBox(height: 16),

          // Dotted Divider
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: AppDottedLine(),
            ),

          const SizedBox(height: 16),

          // Total Amount
          _buildPriceRow(
            'Total Amount',
            sale.formattedTotalAmount,
            isTotal: true,
          ),

          if (sale.downPayment > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              'Down Payment',
              sale.formattedDownPayment,
              valueColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 8),
            _buildPriceRow(
              'Remaining Balance',
              '₹${(sale.totalAmount - sale.downPayment).toStringAsFixed(2)}',
              valueColor: const Color(0xFFF59E0B),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black87 : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isTotal ? const Color(0xFF10B981) : Colors.black87),
          ),
        ),
      ],
    );
  }
}
