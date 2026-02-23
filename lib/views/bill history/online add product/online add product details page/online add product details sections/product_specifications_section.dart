import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';
import 'package:smartbecho/models/bill%20history/online_added_product_model.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class ProductSpecificationsSection extends StatelessWidget {
  final Product product;

  const ProductSpecificationsSection({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineProductsController>();
    final companyColor = controller.getCategoryColor(product.itemCategory);

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
              'Product Information',
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
            child: _buildItemCard(companyColor),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemCard(Color companyColor) {
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
                  '${AppFormatterHelper.capitalizeFirst(product.company)} - ${product.model.toUpperCase()}',
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
            'Model: ${product.model}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),

          // Price and Quantity Row
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        ' Selling  ${product.formattedSellingPrice} /Unite',
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
                        'Quantity - ${product.qty}',
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

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      size: 12,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 6),

                  Text(
                    'Purchase ${product.formattedPurchasePrice}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
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
              if (product.ram != null && product.ram!.isNotEmpty)
                _buildSpecChip(
                  icon: Icons.memory,
                  label:
                      'RAM: ${AppFormatterHelper.formatRamForUI(product.ram!)}',
                ),
              if (product.rom != null && product.rom!.isNotEmpty)
                _buildSpecChip(
                  icon: Icons.storage,
                  label:
                      'ROM: ${AppFormatterHelper.formatRamForUI(product.rom!)}',
                ),
              if (product.color.isNotEmpty)
                _buildSpecChip(
                  icon: Icons.palette_outlined,
                  label:
                      'Color: ${AppFormatterHelper.capitalizeFirst(product.color)}',
                ),
            ],
          ),

          // Additional Info - IMEI
          if (product.imei != null && product.imei!.isNotEmpty) ...[
            const SizedBox(height: 12),
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: AppDottedLine(),
            ),
            const SizedBox(height: 12),
            _buildInfoText(label: 'IMEI', value: product.imei!),
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

  Widget _buildInfoText({required String label, required String value}) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
