import 'package:flutter/material.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class SaleItemsSoldSection extends StatelessWidget {
  final SaleDetailResponse sale;

  const SaleItemsSoldSection({Key? key, required this.sale}) : super(key: key);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Items Sold',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Total: ${sale.items.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items List
          ...sale.items.map((item) => _buildItemCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemCard(SaleItem item) {
    final companyColor = _getCompanyColor(item.company ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  item.company != null
                      ? '${AppFormatterHelper.capitalizeFirst(item.company!)} - ${item.model.toUpperCase()}'
                      : item.model.toUpperCase(),
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
            'Model: ${item.model}',
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
                    'Price - ${item.formattedPrice}/Unit',
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
                    'Quantity - ${item.quantity}',
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
              if (item.ram.isNotEmpty)
                _buildSpecChip(icon: Icons.memory, label: 'RAM: ${item.ram}'),
              if (item.rom.isNotEmpty)
                _buildSpecChip(icon: Icons.storage, label: 'ROM: ${item.rom}'),
              if (item.color.isNotEmpty)
                _buildSpecChip(
                  icon: Icons.palette_outlined,
                  label:
                      'Color: ${AppFormatterHelper.capitalizeFirst(item.color)}',
                ),
            ],
          ),
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
}
