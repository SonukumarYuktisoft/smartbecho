import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/models/inventory%20management/inventory_item_model.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';
import 'package:smartbecho/views/inventory/components/product_detail_page.dart';

class InventoryCardWidget extends StatelessWidget {
  final InventoryItem item;
  final int index;
  final InventoryController controller;

  const InventoryCardWidget({
    Key? key,
    required this.item,
    required this.index,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stockStatus = _getStockStatus(item.quantity);

    return InkWell(
      onTap: () => _navigateToDetailedView(item),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8ECFF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - White Background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Model Name + Menu + Stock Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Model : ${AppFormatterHelper.capitalizeFirst(item.model.trim())}",
                          // '${item.ram.isNotEmpty ? AppFormatterHelper.formatRamForUI(item.ram) : ''} ${item.company}'.trim(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStockBadge(item.lowStockQty ?? 2, stockStatus),
                      // PopupMenuButton<String>(
                      //   initialValue: null,
                      //      color: Color.fromARGB(255, 255, 255, 255),
                      //   icon: const Icon(
                      //     Icons.more_vert,
                      //     color: Color(0xFF94A3B8),
                      //     size: 24,
                      //   ),
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   offset: const Offset(0, 10),
                      //   onSelected: (value) {
                      //     if (value == 'delete') {
                      //       controller.deleteItem(
                      //         itemId: item.id.toString(),
                      //         index: index,
                      //       );
                      //     }
                      //     // else if (value == 'edit') {
                      //     //   // Add edit functionality
                      //     // }
                      //   },
                      //   itemBuilder: (BuildContext context) => [
                      //     // const PopupMenuItem<String>(
                      //     //   value: 'edit',
                      //     //   child: Row(
                      //     //     children: [
                      //     //       Icon(Icons.edit, size: 18, color: Color(0xFF64748B)),
                      //     //       SizedBox(width: 8),
                      //     //       Text('Edit'),
                      //     //     ],
                      //     //   ),
                      //     // ),
                      //     const PopupMenuItem<String>(
                      //       value: 'delete',
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.delete, size: 18, color: Colors.red),
                      //           SizedBox(width: 8),
                      //           Text('Delete', style: TextStyle(color: Colors.red)),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price + Unit Row
                  Row(
                    children: [
                      // People Icon + Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // 'Price-₹${AppFormatterHelper.amountFormatter(item.sellingPrice)}',
                        'Price- ₹${item.sellingPrice}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Unit ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Dotted Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: AppDottedLine(),
              ),
            ),

            // Bottom Section - Light Background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Specifications Grid
                  Row(
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.color.isNotEmpty)
                              _buildSpecRow(
                                icon: Icons.palette_outlined,
                                label: 'Color-${item.color}',
                              ),
                            const SizedBox(height: 8),
                            if (item.ram.isNotEmpty)
                              _buildSpecRow(
                                icon: Icons.memory,
                                label:
                                    'Ram: ${AppFormatterHelper.formatRamForUI(item.ram)}',
                              ),
                          ],
                        ),
                      ),

                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.source != null &&
                                item.source!.trim().isNotEmpty)
                              _buildSourceBadge(item.source!),
                            const SizedBox(height: 8),
                            if (item.rom.isNotEmpty)
                              _buildSpecRow(
                                icon: Icons.storage,
                                label:
                                    'Rom: ${AppFormatterHelper.formatRamForUI(item.rom)}',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSpecRow(
                          icon: Icons.business,
                          label: 'Company: ${item.company}',
                        ),
                      ),

                      Expanded(
                        child: _buildSpecRow(
                          icon: Icons.category,
                          label: 'Category: ${item.itemCategory}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Sell Button
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed:
                                item.quantity > 0
                                    ? () => controller.sellItem(item)
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFFE2E8F0),
                              disabledForegroundColor: const Color(0xFF94A3B8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color:
                                      item.quantity > 0
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Sell',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Return Button
                      if (item.quantity > 0)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => controller.returnItem(item),
                            
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBBF24),
                                foregroundColor: const Color(0xFF78350F),
                                elevation: 0,
                                disabledBackgroundColor: const Color(
                                  0xFFE2E8F0,
                                ),
                                disabledForegroundColor: const Color(
                                  0xFF94A3B8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.undo,
                                    size: 18,
                                    color: const Color(0xFF78350F),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Return',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (item.quantity == 0)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed:
                                  () => controller.deleteItem(
                                    itemId: item.id.toString(),
                                    index: index,
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),

                                foregroundColor: Colors.white,

                                elevation: 0,
                                disabledBackgroundColor: const Color(
                                  0xFFE2E8F0,
                                ),
                                disabledForegroundColor: const Color(
                                  0xFF94A3B8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(int quantity, StockStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(String source) {
    final isOffline = source.toLowerCase() == 'offline';
    final bgColor =
        isOffline ? const Color(0xFF0D47A1) : const Color(0xFF059669);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOffline ? Icons.access_time : Icons.wifi,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            source,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _navigateToDetailedView(InventoryItem item) {
    Get.to(() => InventoryDetailScreen(item: item));
  }

  StockStatus _getStockStatus(int quantity) {
    if (quantity == 0) {
      return StockStatus(
        label: 'Out of Stock',
        color: const Color(0xFFEF4444), // Red
      );
    } else if (quantity <= 2) {
      return StockStatus(
        label: 'Low Stock',
        color: const Color(0xFFF59E0B), // Amber/Orange
      );
    } else {
      return StockStatus(
        label: 'In Stock',
        color: const Color(0xFF10B981), // Green
      );
    }
  }
}

// Stock Status Model
class StockStatus {
  final String label;
  final Color color;

  StockStatus({required this.label, required this.color});
}
