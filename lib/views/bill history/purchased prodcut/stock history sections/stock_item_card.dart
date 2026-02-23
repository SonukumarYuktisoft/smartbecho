
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/models/bill%20history/stock_history_item_response.dart';
import 'package:smartbecho/views/bill%20history/purchased%20prodcut/stock_details/stock_item_details_page.dart';

class StockItemCard extends StatelessWidget {
  final StockItem stockItem;
  final BillHistoryController controller;

  const StockItemCard({
    Key? key,
    required this.stockItem,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => StockItemDetailsPage(stockItem: stockItem),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 300),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: controller
                .getCategoryColor(stockItem.itemCategory)
                .withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),

                    // Category
                    if (stockItem.categoryDisplayName.isNotEmpty)
                      _buildSpecRow(
                        label: "Category",
                        value: stockItem.categoryDisplayName,
                      ),

                    // Company
                    if (stockItem.company.isNotEmpty)
                      _buildSpecRow(
                        label: "Company",
                        value: stockItem.company.toUpperCase(),
                      ),

                    // Model
                    _buildSpecRow(label: "Model", value: stockItem.model),

                    // Date
                    _buildSpecRow(
                      label: "Date",
                      value: stockItem.formattedDate,
                    ),

                    // Storage (RAM/ROM)
                    if (stockItem.ramRomDisplay.isNotEmpty)
                      _buildSpecRow(
                        label: "Storage",
                        value: stockItem.ramRomDisplay,
                      ),

                    // Color
                    _buildSpecRow(label: "Color", value: stockItem.color),

                    // Quantity
                    _buildSpecRow(
                      label: "Quantity",
                      value: stockItem.qty.toString(),
                    ),

                    // Bill Reference
                    _buildSpecRow(
                      label: "Bill Item",
                      value: '#${stockItem.billMobileItem}',
                    ),

                    Spacer(),

                    // Price
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            stockItem.formattedPrice,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
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
        ),
      ),
    );
  }

  Widget _buildSpecRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label :",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

