import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/controllers/subscription%20controller/payment_controller.dart';
import 'package:smartbecho/models/subscription%20models/payment_models/payment_history_model.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentController _controller = Get.put(PaymentController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.getPaymentHistory(page: 0, refresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMorePaymentHistory();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Payment History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_controller.historyLoading.value &&
            _controller.paymentHistory.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          );
        }

        if (_controller.paymentHistory.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _controller.getPaymentHistory(
            page: 0,
            refresh: true,
          ),
          color: AppColors.primaryLight,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _controller.paymentHistory.length + 1,
            itemBuilder: (context, index) {
              if (index == _controller.paymentHistory.length) {
                return _buildLoadMoreIndicator();
              }

              final payment = _controller.paymentHistory[index];
              return _buildPaymentCard(payment,_controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: AppColors.primaryLight.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Payment History Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment transactions will appear here\nonce you make your first subscription',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Subscribe to a plan to see transactions here',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (!_controller.hasMorePages.value) {
        return const SizedBox.shrink();
      }

      if (_controller.historyLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildPaymentCard(PaymentHistory payment , PaymentController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: payment.isSuccess
                  ? Colors.green[50]
                  : payment.isPending
                      ? Colors.orange[50]
                      : Colors.red[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: payment.isSuccess
                            ? Colors.green[100]
                            : payment.isPending
                                ? Colors.orange[100]
                                : Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        payment.isSuccess
                            ? Icons.check_circle
                            : payment.isPending
                                ? Icons.schedule
                                : Icons.cancel,
                        color: payment.isSuccess
                            ? Colors.green[700]
                            : payment.isPending
                                ? Colors.orange[700]
                                : Colors.red[700],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription #${payment.subscriptionId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: payment.isSuccess
                        ? Colors.green[100]
                        : payment.isPending
                            ? Colors.orange[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    payment.paymentStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: payment.isSuccess
                          ? Colors.green[900]
                          : payment.isPending
                              ? Colors.orange[900]
                              : Colors.red[900],
                    ),
                  ),
                ),

                   if (payment.receiptUrl != null) 
                      // Download Button
                      Container(
                        decoration: BoxDecoration(
                          color:Colors.green[900],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.downloadInvoice(payment),
                            borderRadius: BorderRadius.circular(50),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Amount Section
                _buildDetailRow(
                  'Plan Period',
                  payment.formattedPeriod,
                ),
                const SizedBox(height: 8),

                _buildDetailRow(
                  'Base Amount',
                  payment.formattedBaseAmount,
                ),
                const SizedBox(height: 8),

                if (payment.discountAmount != null &&
                    payment.discountAmount! > 0) ...[
                  _buildDetailRow(
                    'Discount',
                    '- ₹${payment.discountAmount!.toStringAsFixed(2)}',
                    valueColor: Colors.green[700],
                  ),
                  const SizedBox(height: 8),
                ],

                // GST Section
                if (payment.gstAmount != null && payment.gstAmount! > 0) ...[
                  _buildDetailRow(
                    'GST Amount',
                    payment.formattedGstAmount,
                    valueColor: Colors.orange[700],
                  ),
                  if (payment.gstBreakdown.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text(
                        '  ${payment.gstBreakdown}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: AppDottedLine(),
                  ),
                ),
                const SizedBox(height: 8),

                // Total Amount
                _buildDetailRow(
                  'Total Amount Paid',
                  payment.formattedAmount,
                  isTotal: true,
                ),
                const SizedBox(height: 12),

                // Transaction Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: AppDottedLine(),
                  ),
                ),
                const SizedBox(height: 12),

                if (payment.txnId != null)
                  _buildDetailRow(
                    'Transaction ID',
                    payment.transactionIdShort,
                    isSmall: true,
                  ),

                if (payment.txnId != null) const SizedBox(height: 8),

                if (payment.razorpayOrderId != null)
                  _buildDetailRow(
                    'Order ID',
                    payment.razorpayOrderId!,
                    isSmall: true,
                  ),

                if (payment.razorpayOrderId != null) const SizedBox(height: 8),

                if (payment.razorpayPaymentId != null)
                  _buildDetailRow(
                    'Payment ID',
                    payment.razorpayPaymentId!,
                    isSmall: true,
                  ),

                if (payment.razorpayPaymentId != null) const SizedBox(height: 8),

                _buildDetailRow(
                  'Payment Method',
                  payment.paymentMethod,
                  isSmall: true,
                ),

                
                   
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
    bool isSmall = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 12 : (isTotal ? 16 : 14),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 12 : (isTotal ? 18 : 14),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor ??
                  (isTotal ? AppColors.primaryLight : Colors.black87),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}