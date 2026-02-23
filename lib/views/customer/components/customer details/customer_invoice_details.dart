// pages/invoice_details_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_invoice_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class InvoiceDetailsPage extends StatelessWidget {
  final InvoiceDetailsController controller = Get.put(
    InvoiceDetailsController(),
    permanent: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Invoice Details'),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // buildCustomAppBar("Invoice Details", isdark: true),
            // Loading indicator
            Obx(
              () =>
                  controller.isLoading.value
                      ? LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        color: Color(0xFF6C5CE7),
                      )
                      : SizedBox(),
            ),
            // Main content
            Expanded(
              child: Obx(() {
                if (controller.hasError.value) {
                  return _buildErrorState();
                }
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                }
                if (controller.invoiceDetails.value == null) {
                  return _buildEmptyState();
                }
                return _buildInvoiceContent();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvoiceHeader(),
          SizedBox(height: 16),
          _buildCustomerInfo(),
          SizedBox(height: 16),
          _buildItemsList(),
          SizedBox(height: 16),
          _buildPaymentStatus(),
          SizedBox(height: 16),
          _buildPaymentHistory(),
          SizedBox(height: 16),
          _buildActionButtons(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    final invoice = controller.invoiceDetails.value!;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF5A4FCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C5CE7).withValues(alpha: 0.3),
            spreadRadius: 0,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INVOICE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    invoice.invoiceNumber,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.shopName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Shop ID: ${invoice.shopId}',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Date: ${invoice.formattedSaleDate}',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final invoice = controller.invoiceDetails.value!;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Color(0xFF6C5CE7), size: 20),
              SizedBox(width: 8),
              Text(
                'BILL TO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            invoice.customerName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Customer ID: ${invoice.saleId}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final invoice = controller.invoiceDetails.value!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.inventory, color: Color(0xFF6C5CE7), size: 20),
                SizedBox(width: 8),
                Text(
                  'ITEMS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C5CE7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: invoice.items.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final item = invoice.items[index];
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.model,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          item.formattedTotalPrice,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: controller
                                .getSpecificationColor(item.model)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.specifications,
                            style: TextStyle(
                              fontSize: 12,
                              color: controller.getSpecificationColor(
                                item.model,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              controller.getAccessoryIcon(
                                item.accessoryIncluded,
                              ),
                              size: 16,
                              color: controller.getAccessoryColor(
                                item.accessoryIncluded,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              item.accessoryName,
                              style: TextStyle(
                                fontSize: 12,
                                color: controller.getAccessoryColor(
                                  item.accessoryIncluded,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Qty: ${item.quantity} × ${item.formattedPrice}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${invoice.totalQuantity} items)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '₹${invoice.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus() {
    final invoice = controller.invoiceDetails.value!;
    final dues = invoice.dues;

    if (dues == null) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                controller.getPaymentStatusIcon(),
                color: controller.getPaymentStatusColor(),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'PAYMENT STATUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: controller.getPaymentStatusColor(),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    dues.formattedTotalDue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Amount Paid',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    dues.formattedTotalPaid,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF51CF66),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining Due',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    dues.formattedRemainingDue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          dues.remainingDue > 0
                              ? Color(0xFFFF6B6B)
                              : Color(0xFF51CF66),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: controller.getPaymentStatusColor().withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.paymentStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: controller.getPaymentStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          if (dues.remainingDue > 0) ...[
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Progress',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      controller.getPaymentProgressPercentage(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: controller.getPaymentProgress(),
                  backgroundColor: Colors.grey[200],
                  color: Color(0xFF6C5CE7),
                  minHeight: 6,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    if (!controller.hasPaymentHistory()) {
      return SizedBox();
    }

    final paymentHistory = controller.getValidPaymentHistory();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.togglePaymentHistoryExpansion(),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: Color(0xFF6C5CE7), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'PAYMENT HISTORY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C5CE7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Icon(
                      controller.isPaymentHistoryExpanded.value
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () =>
                controller.isPaymentHistoryExpanded.value
                    ? Column(
                      children: [
                        Divider(height: 1, color: Colors.grey[200]),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: paymentHistory.length,
                          separatorBuilder:
                              (context, index) =>
                                  Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final payment = paymentHistory[index];
                            return Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        payment.formattedPaidAmount,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        payment.formattedPaidDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: controller
                                          .getPaymentMethodColor(
                                            payment.paymentMethod,
                                          )
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      controller.getPaymentMethodDisplayName(
                                        payment.paymentMethod,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: controller.getPaymentMethodColor(
                                          payment.paymentMethod,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    )
                    : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isNotifying.value
                          ? null
                          : () => controller.notifyCustomer(),
                  icon:
                      controller.isNotifying.value
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Icon(Icons.email, size: 18),
                  label: Text(
                    controller.isNotifying.value ? 'Notifying...' : 'Notify',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        controller.isNotifying.value
                            ? AppColors.warningLight.withValues(alpha: 0.7)
                            : AppColors.warningLight,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // if (controller.invoiceDetails.value?.dues?.remainingDue != null &&
        //     controller.invoiceDetails.value!.dues!.remainingDue > 0) ...[
        //   SizedBox(height: 12),
        //   Row(
        //     children: [
        //       Expanded(
        //         child: ElevatedButton.icon(
        //           onPressed: () => controller.addPayment(),
        //           icon: Icon(Icons.payment, size: 18),
        //           label: Text('Add Payment'),
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: Color(0xFF6C5CE7),
        //             foregroundColor: Colors.white,
        //             padding: EdgeInsets.symmetric(vertical: 12),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //           ),
        //         ),
        //       ),
        //       SizedBox(width: 12),
        //       Expanded(
        //         child: Obx(() => ElevatedButton.icon(
        //           onPressed: controller.isNotifying.value
        //               ? null
        //               : () => controller.notifyCustomer(),
        //           icon: controller.isNotifying.value
        //               ? SizedBox(
        //                   width: 18,
        //                   height: 18,
        //                   child: CircularProgressIndicator(
        //                     strokeWidth: 2,
        //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //                   ),
        //                 )
        //               : Icon(Icons.notifications, size: 18),
        //           label: Text(controller.isNotifying.value ? 'Notifying...' : 'Notify Customer'),
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: controller.isNotifying.value
        //                 ? Color(0xFF51CF66).withValues(alpha:0.7)
        //                 : Color(0xFF51CF66),
        //             foregroundColor: Colors.white,
        //             padding: EdgeInsets.symmetric(vertical: 12),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //           ),
        //         )),
        //       ),
        //     ],
        //   ),
        // ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6C5CE7)),
          SizedBox(height: 16),
          Text(
            'Loading invoice details...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
            'Error Loading Invoice',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            controller.errorMessage.value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshInvoiceDetails(),
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No Invoice Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The requested invoice could not be found.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back),
            label: Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
