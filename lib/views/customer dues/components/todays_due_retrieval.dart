import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/todays_due_retrieval_controller.dart';
import 'package:smartbecho/models/customer%20dues%20management/todays_due_retrival_model.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/common_search_field.dart';
import 'package:smartbecho/views/dashboard/widgets/error_cards.dart';

class TodaysRetrievalDuesScreen extends StatelessWidget {
  final RetrievalDueController controller = Get.put(RetrievalDueController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Today's Retrieval Dues"),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // buildCustomAppBar("Today's Retrieval Dues", isdark: true),
            _buildSummaryCards(context),
            Expanded(child: _buildDuesContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Obx(
      () =>
          controller.isLoading.value
              ? _buildShimmerSummaryCards()
              : controller.hasError.value
              ? buildErrorCard(
                controller.errorMessage,
                AppConfig.screenWidth,
                AppConfig.screenHeight,
                AppConfig.isSmallScreen,
              )
              : Container(
                height: 120,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final stats = [
                      {
                        'title': 'Total Customers',
                        'value': controller.totalCount.toString(),
                        'subtitle': 'Customers with dues',
                        'icon': Icons.people,
                        'color': Color(0xFF6C5CE7),
                        'gradient': [Color(0xFF6C5CE7), Color(0xFF9C88FF)],
                      },
                      {
                        'title': 'Total Due Amount',
                        'value':
                            '₹${controller.totalDueAmount.value.toStringAsFixed(0)}',
                        'subtitle': 'Total amount due',
                        'icon': Icons.account_balance_wallet,
                        'color': Color(0xFFFF9500),
                        'gradient': [Color(0xFFFF9500), Color(0xFFFFB347)],
                      },
                      {
                        'title': 'Remaining Due',
                        'value':
                            '₹${controller.totalRemainingAmount.value.toStringAsFixed(0)}',
                        'subtitle': 'Amount pending',
                        'icon': Icons.money_off,
                        'color': Color(0xFFFF6B6B),
                        'gradient': [Color(0xFFFF6B6B), Color(0xFFFF9A9A)],
                      },
                      {
                        'title': 'Overdue Count',
                        'value': controller.overdueCount.toString(),
                        'subtitle': 'Overdue payments',
                        'icon': Icons.warning,
                        'color': Color(0xFFE74C3C),
                        'gradient': [Color(0xFFE74C3C), Color(0xFFFF6B6B)],
                      },
                    ];

                    return Container(
                      width: 180,
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
                      child: BuildStatsCard(
                     label:    stats[index]['title'] as String,
                      value:   stats[index]['value'] as String,
                      icon:   stats[index]['icon'] as IconData,
                      color:   stats[index]['color'] as Color,
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _BuildStatsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    List<Color> gradient,
  ) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withValues(alpha:0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuesContent() {
    return Obx(
      () =>
          controller.isLoading.value
              ? _buildShimmerGrid()
              : controller.hasError.value
              ? buildErrorCard(
                controller.errorMessage,
                AppConfig.screenWidth,
                AppConfig.screenHeight,
                AppConfig.isSmallScreen,
              )
              : _buildDuesGrid(),
    );
  }

  Widget _buildDuesGrid() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDuesHeader(),
          Expanded(
            child: Obx(() {
              if (controller.customers.isEmpty) {
                return _buildEmptyState();
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return _buildDueCard(customer);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDuesHeader() {
    return Obx(
      () => Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Customers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Showing ${controller.customers.length} customers',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            IconButton(
              onPressed: controller.refreshData,
              icon: Icon(Icons.refresh, color: Color(0xFF6C5CE7)),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueCard(RetrievalDueCustomer customer) {
    Color statusColor = Color(
      int.parse('0xFF${customer.statusColor.substring(1)}'),
    );

    return InkWell(
      onTap: () => _showCustomerDetails(customer),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(color: statusColor.withValues(alpha:0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:AppColors.primaryGradientLight,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha:0.3)),
                  ),
                  child: Text(
                    customer.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),

            // Customer name
            Text(
              customer.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),

            // Phone number
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.primaryPhone,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Due amount section
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Due',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${customer.dues.totalDue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${customer.dues.remainingDue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),

            // Due date
            Text(
              'Due: ${customer.dues.formattedPaymentRetriableDate}',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),

            // Days overdue (if applicable)
            if (customer.dues.daysSinceDue > 0) ...[
              SizedBox(height: 4),
              Text(
                '${customer.dues.daysSinceDue} days overdue',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFE74C3C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed:
                          () => controller.openDialer(customer.primaryPhone),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        side: BorderSide(
                          color: AppColors.primaryLight.withValues(alpha:0.3),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, size: 14),
                          SizedBox(width: 4),
                          Text('Call', style: TextStyle(fontSize: 12,
                            color: AppColors.primaryLight
            
                          ), ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Expanded(
                //   child: SizedBox(
                //     height: 32,
                //     child: ElevatedButton(
                //       onPressed: customer.dues.remainingDue > 0
                //           ? () => _showPaymentDialog(customer)
                //           : null,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: customer.dues.remainingDue > 0
                //             ? Color(0xFF6C5CE7)
                //             : Colors.grey[300],
                //         foregroundColor: Colors.white,
                //         padding: EdgeInsets.symmetric(horizontal: 8),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         elevation: 0,
                //       ),
                //       child: Text(
                //         customer.dues.remainingDue > 0 ? 'Pay' : 'Paid',
                //         style: TextStyle(
                //           fontSize: 12,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed:
                          customer.dues.remainingDue > 0
                              ? () {
                                controller.notifyCustomer(
                                  customer.id,
                                  customer.name,
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            customer.dues.remainingDue > 0
                                ?  AppColors.primaryLight
                                : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Notify",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFF6C5CE7).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.search_off,
              size: 60,
              color: Color(0xFF6C5CE7).withValues(alpha:0.5),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSummaryCards() {
    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  height: 24,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Container(
      margin: EdgeInsets.all(12),
      child: Column(
        children: [
          // Shimmer header
          Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
          // Shimmer grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha:0.08),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 11,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                Container(
                                  height: 11,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 12,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                Container(
                                  height: 14,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(RetrievalDueCustomer customer) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 20),
        
              // Customer Info
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF9C88FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : 'C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          customer.email??"",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
        
              // Contact Info
              _buildDetailRow(Icons.phone, 'Phone', customer.primaryPhone),
              _buildDetailRow(Icons.location_on, 'Location', customer.location),
              _buildDetailRow(Icons.home, 'Address', customer.primaryAddress),
        
              SizedBox(height: 20),
        
              // Due Details
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(
                      int.parse('0xFF${customer.statusColor.substring(1)}'),
                    ).withValues(alpha:0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDueDetailRow(
                      'Total Due',
                      '₹${customer.dues.totalDue.toStringAsFixed(0)}',
                    ),
                    _buildDueDetailRow(
                      'Total Paid',
                      '₹${customer.dues.totalPaid.toStringAsFixed(0)}',
                    ),
                    _buildDueDetailRow(
                      'Remaining Due',
                      '₹${customer.dues.remainingDue.toStringAsFixed(0)}',
                    ),
                    _buildDueDetailRow(
                      'Due Date',
                      customer.dues.formattedPaymentRetriableDate,
                    ),
                    if (customer.dues.daysSinceDue > 0)
                      _buildDueDetailRow(
                        'Days Overdue',
                        '${customer.dues.daysSinceDue} days',
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
        
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => controller.openDialer(customer.primaryPhone),
                      icon: Icon(Icons.phone),
                      label: Text('Call Customer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF6C5CE7),
                        side: BorderSide(color: Color(0xFF6C5CE7)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(width: 12),
                  // Expanded(
                  //   child: ElevatedButton.icon(
                  //     onPressed:
                  //         customer.dues.remainingDue > 0
                  //             ? () {
                  //               Get.back();
                  //               _showPaymentDialog(customer);
                  //             }
                  //             : null,
                  //     icon: Icon(Icons.payment),
                  //     label: Text(
                  //       customer.dues.remainingDue > 0
                  //           ? 'Record Payment'
                  //           : 'Paid',
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor:
                  //           customer.dues.remainingDue > 0
                  //               ? Color(0xFF6C5CE7)
                  //               : Colors.grey[300],
                  //       foregroundColor: Colors.white,
                  //       padding: EdgeInsets.symmetric(vertical: 12),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFF6C5CE7)),
          SizedBox(width: 12),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(RetrievalDueCustomer customer) {
    final TextEditingController amountController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Customer: ${customer.name}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Remaining Due: ₹${customer.dues.remainingDue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  prefixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (amountController.text.isNotEmpty) {
                          double amount =
                              double.tryParse(amountController.text) ?? 0;
                          if (amount > 0 &&
                              amount <= customer.dues.remainingDue) {
                            controller.markPaymentReceived(
                              customer.dues.id,
                              customer.id,
                            );
                            Get.back();
                          } else {
                            Get.snackbar(
                              'Invalid Amount',
                              'Please enter a valid amount',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      child: Text('Record Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
