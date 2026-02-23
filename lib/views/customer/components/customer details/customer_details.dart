// views/customer_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_details_controller.dart';
import 'package:smartbecho/models/customer%20management/customer_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class CustomerDetailsScreen extends StatefulWidget {
  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final CustomerDetailsController controller = Get.put(
    CustomerDetailsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Customer Details'),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }
          if (controller.hasError.value) {
            return _buildErrorState();
          }
          if (controller.customerDetails.value == null) {
            return _buildEmptyState();
          }
          return _buildSuccessState();
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // buildCustomAppBar("Customer Details", isdark: true),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryLight,
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading customer details...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        // buildCustomAppBar("Customer Details", isdark: true),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Failed to load customer details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshCustomerDetails,
                  icon: Icon(Icons.refresh, size: 20),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // buildCustomAppBar("Customer Details", isdark: true),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'No customer details found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        // buildCustomAppBar("Customer Details", isdark: true),
        Expanded(
          child: AppRefreshIndicator(
            onRefresh: controller.refreshCustomerDetails,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildCustomerHeader(),
                      _buildStatsCards(),
                      _buildTabSection(),
                    ],
                  ),
                ),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerHeader() {
    final customer = controller.customerDetails.value!;
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, Color(0xFF74B9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:Image.asset(
                          // customer.profilePhotoUrl,
                          'assets/icons/customer.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          // borderRadius: BorderRadius.circular(12),
                        ),
                      )
                // child:
                //     customer.profilePhoto != null
                //         ? ClipOval(
                //           child: Image.network(
                //             customer.profilePhoto!,
                //             width: 60,
                //             height: 60,
                //             fit: BoxFit.cover,
                //             errorBuilder: (context, error, stackTrace) {
                //               return _buildAvatarFallback(customer.name);
                //             },
                //           ),
                //         )
                //         : _buildAvatarFallback(customer.name),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: controller.getCustomerTypeColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.getCustomerTypeIcon(),
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                controller.getCustomerType(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      customer.primaryNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if(customer.email !=null && customer.email!.isNotEmpty)...[
                      Text(
                      customer.email!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    ],

                      
                    Text(
                      customer.defaultAddress,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.call,
                  label: 'Call',
                  onPressed: controller.callCustomer,
                  color: Color(0xFF51CF66),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Obx(
                  () => _buildActionButton(
                    icon:
                        controller.isNotifying.value
                            ? Icons.hourglass_empty
                            : Icons.notifications_active,
                    label:
                        controller.isNotifying.value
                            ? 'Notifying...'
                            : 'Notify',
                    onPressed:
                        controller.isNotifying.value
                            ? null
                            : controller.notifyCustomer,
                    color: AppColors.warningLight,
                    isLoading: controller.isNotifying.value,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            onPressed == null ? color.withValues(alpha: 0.6) : color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Icon(icon, size: 16),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _BuildStatsCard(
              title: 'Total Purchases',
              value: controller.formatCurrency(controller.totalPurchases.value),
              icon: Icons.shopping_cart,
              color: Color(0xFF51CF66),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _BuildStatsCard(
              title: 'Total Sales',
              value: '${controller.purchaseCount.value}',
              icon: Icons.receipt,
              color: AppColors.primaryLight,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _BuildStatsCard(
              title: 'Pending Dues',
              value: controller.formatCurrency(controller.totalDues.value),
              icon: Icons.account_balance_wallet,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _BuildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Sales History',
              index: 0,
              count: controller.salesList.length,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildTabButton(
              title: 'Dues',
              index: 1,
              count: controller.duesList.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int index,
    required int count,
  }) {
    final isSelected = controller.selectedTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      if (controller.selectedTabIndex.value == 0) {
        return _buildSalesContent();
      } else {
        return _buildDuesContent();
      }
    });
  }

  Widget _buildSalesContent() {
    if (controller.salesList.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Text(
                  'No sales history found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final sale = controller.salesList[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _buildSaleCard(sale),
        );
      }, childCount: controller.salesList.length),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Obx(() {
      final isExpanded = controller.expandedSaleId.value == sale.id;

      return GestureDetector(
        onTap: () => controller.toggleSaleExpansion(sale.id),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.receipt,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice #${sale.invoiceNumber}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                sale.formattedSaleDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.formatCurrency(sale.totalAmount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: controller.getStatusColor(sale.paid),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sale.paid ? 'Paid' : 'Unpaid',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSaleInfoChip(
                          icon: Icons.payment,
                          label: sale.paymentMode,
                          color: controller.getPaymentModeColor(
                            sale.paymentMode,
                          ),
                        ),
                        SizedBox(width: 8),
                        _buildSaleInfoChip(
                          icon: Icons.account_balance_wallet,
                          label: sale.paymentMethod,
                          color: controller.getPaymentMethodColor(
                            sale.paymentMethod,
                          ),
                        ),
                        SizedBox(width: 8),
                        _buildSaleInfoChip(
                          icon: Icons.shopping_bag,
                          label: '${controller.getTotalItemsCount(sale)} items',
                          color: Colors.grey[600]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isExpanded) _buildExpandedSaleContent(sale),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSaleInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedSaleContent(Sale sale) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: sale.items.length,
            itemBuilder: (context, index) {
              final item = sale.items[index];
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.phone_android,
                        color: AppColors.primaryLight,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            item.specifications,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Color: ${item.color}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          item.formattedPrice,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.viewInvoice(sale),
                  icon: Icon(Icons.picture_as_pdf, size: 16),
                  label: Text('View Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // SizedBox(width: 12),
              // Expanded(
              //   child: OutlinedButton.icon(
              //     onPressed: () => controller.viewSaleDetails(sale),
              //     icon: Icon(Icons.info_outline, size: 16),
              //     label: Text('Details'),
              //     style: OutlinedButton.styleFrom(
              //       foregroundColor: AppColors.primaryLight,
              //       side: BorderSide(color: AppColors.primaryLight),
              //       padding: EdgeInsets.symmetric(vertical: 8),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDuesContent() {
    if (controller.duesList.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Text(
                  'No dues found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final due = controller.duesList[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _buildDueCard(due),
        );
      }, childCount: controller.duesList.length),
    );
  }

  Widget _buildDueCard(DueDetail due) {
    return Obx(() {
      final isExpanded = controller.expandedDueId.value == due.id;
      return GestureDetector(
        onTap: () => controller.toggleDueExpansion(due.id),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: controller
                                .getDueStatusColor(due)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: controller.getDueStatusColor(due),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due #${due.id}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Created: ${due.formattedCreationDate}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              due.formattedRemainingDue,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: controller.getDueStatusColor(due),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                due.statusText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDueInfoChip(
                          icon: Icons.currency_rupee,
                          label: 'Total: ${due.formattedTotalDue}',
                          color: Colors.blue[600]!,
                        ),
                        SizedBox(width: 8),
                        _buildDueInfoChip(
                          icon: Icons.payment,
                          label: 'Paid: ${due.formattedTotalPaid}',
                          color: Color(0xFF51CF66),
                        ),
                        SizedBox(width: 8),
                        _buildDueInfoChip(
                          icon: Icons.schedule,
                          label: 'Due: ${due.formattedPaymentRetriableDate}',
                          color: Color(0xFFFF9500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isExpanded) _buildExpandedDueContent(due),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDueInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDueContent(DueDetail due) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDueDetailItem(
                  title: 'Total Due',
                  value: due.formattedTotalDue,
                  color: Colors.grey[800]!,
                ),
              ),
              Expanded(
                child: _buildDueDetailItem(
                  title: 'Total Paid',
                  value: due.formattedTotalPaid,
                  color: Color(0xFF51CF66),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDueDetailItem(
                  title: 'Remaining Due',
                  value: due.formattedRemainingDue,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              Expanded(
                child: _buildDueDetailItem(
                  title: 'Status',
                  value: due.statusText,
                  color: controller.getDueStatusColor(due),
                ),
              ),
            ],
          ),
          if (due.partialPayments.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              'Payment History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: due.partialPayments.length,
              itemBuilder: (context, index) {
                final payment = due.partialPayments[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(0xFF51CF66).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.payment,
                          color: Color(0xFF51CF66),
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment #${payment.id}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              payment.formattedPaidDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        payment.formattedPaidAmount,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF51CF66),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          SizedBox(height: 16),
          Row(
            children: [
              if (!due.paid) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.addPaymentToDue(due),
                    icon: Icon(Icons.add_circle, size: 16),
                    label: Text('Add Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF51CF66),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
              // Expanded(
              //   child: OutlinedButton.icon(
              //     onPressed: () => controller.viewDueDetails(due),
              //     icon: Icon(Icons.info_outline, size: 16),
              //     label: Text('View Details'),
              //     style: OutlinedButton.styleFrom(
              //       foregroundColor: AppColors.primaryLight,
              //       side: BorderSide(color: AppColors.primaryLight),
              //       padding: EdgeInsets.symmetric(vertical: 8),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDueDetailItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
