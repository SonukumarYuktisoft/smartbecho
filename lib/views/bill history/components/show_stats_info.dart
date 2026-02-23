import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/models/bill%20history/stock_stats_reponse_model.dart';

enum StockWhenAdded { today, thisMonth }

void showStockItemsDialog(BuildContext context, StockStats stockStats, StockWhenAdded query) {
  final items = query == StockWhenAdded.today 
      ? stockStats.todayItems 
      : stockStats.thisMonthItems;
  
  final title = query == StockWhenAdded.today 
      ? "Today's Added Stock" 
      : "This Month's Added Stock";

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      query == StockWhenAdded.today ? Icons.today : Icons.date_range,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "${items.length} items found",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              // Content - Scrollable List
              Expanded(
                child: items.isEmpty 
                    ? _buildEmptyState(query)
                    : _buildScrollableItemList(items),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildEmptyState(StockWhenAdded query) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 64,
          color: Colors.grey[300],
        ),
        SizedBox(height: 16),
        Text(
          "No items found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
        Text(
          query == StockWhenAdded.today 
              ? "No stock was added today" 
              : "No stock was added this month",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildScrollableItemList(List<StockItemModel> items) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return _buildStockItemCard(item, index);
    },
  );
}
Widget _buildStockItemCard(StockItemModel item, int index) {
  String dateFormatted = item.createdDate.isNotEmpty
      ? DateFormat('dd MMM yyyy').format(DateTime.parse(item.createdDate))
      : "N/A";

  Color companyColor = _getCompanyColor(item.company);

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 0,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: companyColor.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: InkWell(
      onTap: () {
        // Optional: Add item detail navigation here
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Quantity Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: companyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: companyColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // Quantity (kitni quantity available hai)
                    item.qty.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: companyColor,
                    ),
                  ),
                  Text(
                    "QTY",
                    style: TextStyle(
                      fontSize: 8,
                      color: companyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model Name
                  Text(
                    'Model: ${item.model}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Company
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: companyColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Company: ${item.company.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Color, RAM, ROM
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Color: ${item.color}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'RAM: ${item.ram}GB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ROM: ${item.rom}GB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Selling Price and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          Text(
                            'Price: ${item.sellingPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 11,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            dateFormatted,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    ),
  );
}
Color _getCompanyColor(String company) {
  switch (company.toLowerCase()) {
    case 'apple':
      return Color(0xFF1E293B);
    case 'samsung':
      return Color(0xFF3B82F6);
    case 'xiaomi':
    case 'redmi':
      return Color(0xFFF59E0B);
    case 'oneplus':
      return Color(0xFFEF4444);
    case 'vivo':
      return Color(0xFF4338CA);
    case 'oppo':
      return Color(0xFF059669);
    default:
      return Color(0xFF6B7280);
  }
}