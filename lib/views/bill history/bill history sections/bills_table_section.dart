import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/bill_history_controller.dart';
import 'package:smartbecho/models/bill%20history/bill_history_model.dart';
import 'package:smartbecho/utils/app_colors.dart';

class BillsTableSection extends GetView<BillHistoryController> {
  const BillsTableSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(10),
      sliver: Obx(() {
        // Error State
        if (controller.error.value.isNotEmpty && controller.bills.isEmpty) {
          return SliverToBoxAdapter(child: _buildErrorState());
        }

        // Loading State
        if (controller.isLoading.value && controller.bills.isEmpty) {
          return SliverToBoxAdapter(child: _buildLoadingState());
        }

        // Empty State
        if (controller.bills.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        // Table
        return SliverToBoxAdapter(child: _buildTable());
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading bills...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No bills found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.resetFilters(),
            // onPressed: () => controller.loadBills(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Obx(
              () => Text(
                controller.error.value,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.loadBills(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildTableRows(),
          if (controller.isLoadingMore.value) _buildLoadingMore(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerText('Bill ID')),
          Expanded(flex: 3, child: _headerText('Distributor Name')),
          Expanded(flex: 2, child: _headerText('Date', center: true)),
          Expanded(flex: 2, child: _headerText('Amount', center: true)),
        ],
      ),
    );
  }

  Widget _headerText(String text, {bool center = false}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      textAlign: center ? TextAlign.center : TextAlign.start,
    );
  }

  Widget _buildTableRows() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.bills.length,
      separatorBuilder:
          (context, index) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder:
          (context, index) => _buildTableRow(controller.bills[index], index),
    );
  }

  Widget _buildTableRow(Bill bill, int index) {
    final rowColor = index.isEven ? Colors.white : Color(0xFFF5F5F5);

    return GestureDetector(
      onTap: () => controller.navigateToBillDetails(bill),
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: rowColor,
        child: Row(
          children: [
            // Bill ID
            Expanded(
              flex: 2,
              child: Text(
                '${bill.billId}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Distributor Name
            Expanded(
              flex: 3,
              child: Text(
                bill.companyName.isNotEmpty ? bill.companyName : 'N/A',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                bill.formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),

            // Amount
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bill.formattedAmount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (bill.dues > 0) ...[
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, size: 10, color: Colors.orange),
                        SizedBox(width: 2),
                        Text(
                          bill.formattedDues,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
        ),
      ),
    );
  }
}
