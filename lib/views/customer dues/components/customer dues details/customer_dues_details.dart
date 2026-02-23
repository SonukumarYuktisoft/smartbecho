import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/professional_invoice_controller.dart';
import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/services/payment_types.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/services/whatsapp_chat_launcher.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/common_textfield.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/services/configs/theme_config.dart';
import 'package:smartbecho/views/customer%20dues/components/customer%20dues%20details/customer%20dues%20detail%20sections/dues_action_buttons_section.dart';
import 'package:smartbecho/views/customer%20dues/components/customer%20dues%20details/customer%20dues%20detail%20sections/dues_amount_details_section.dart';
import 'package:smartbecho/views/customer%20dues/components/customer%20dues%20details/customer%20dues%20detail%20sections/dues_customer_header_section.dart';
import 'package:smartbecho/views/customer%20dues/components/customer%20dues%20details/customer%20dues%20detail%20sections/dues_payment_history_section.dart';
import 'package:smartbecho/views/customer%20dues/components/customer%20dues%20details/customer%20dues%20detail%20sections/dues_show_payment_bottomsheet.dart'
    hide PaymentTypes;

class CustomerDueDetailsScreen extends StatefulWidget {
  final int dueId;

  CustomerDueDetailsScreen({required this.dueId});

  @override
  _CustomerDueDetailsScreenState createState() =>
      _CustomerDueDetailsScreenState();
}

class _CustomerDueDetailsScreenState extends State<CustomerDueDetailsScreen> {
  late CustomerDuesController controller;
  late InvoiceSettingsController invoiceSettingsController;
  final RxBool isPaymentHistoryExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CustomerDuesController>();

    if (Get.isRegistered<InvoiceSettingsController>()) {
      invoiceSettingsController = Get.find<InvoiceSettingsController>();
    } else {
      invoiceSettingsController = Get.put(InvoiceSettingsController());
    }

    controller.fetchCustomerDueDetails(widget.dueId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController().isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(title: 'Due Customer Details'),
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          if (controller.isDetailsLoading.value) {
            return _buildLoadingState(isDark);
          }

          if (controller.hasDetailsError.value) {
            return _buildErrorState(isDark);
          }

          if (controller.customerDueDetails.value == null) {
            return _buildEmptyState(isDark);
          }

          final dueDetails = controller.customerDueDetails.value!;
          return _buildContent(dueDetails, isDark);
        }),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? const Color(0xFF14B8A6) : const Color(0xFF5B6CF6),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading customer details...',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? const Color(0xFFEF4444) : Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load customer details',
            style: TextStyle(
              color: isDark ? const Color(0xFFF1F5F9) : Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.detailsErrorMessage.value,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.fetchCustomerDueDetails(widget.dueId),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF14B8A6) : const Color(0xFF5B6CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? const Color(0xFF475569) : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Customer details not found',
            style: TextStyle(
              color: isDark ? const Color(0xFFF1F5F9) : Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CustomerDueDetailsModel dueDetails, bool isDark) {
    return AppRefreshIndicator(
      onRefresh: () => controller.fetchCustomerDueDetails(widget.dueId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Customer Header
            DuesCustomerHeaderSection(dueDetails: dueDetails),
            // Action Buttons
            DuesActionButtonsSection(
              onCallPressed:
                  () => _makePhoneCall(dueDetails.customer.primaryPhone ?? ""),
              onWhatsAppPressed: () => _openWhatsApp(dueDetails),
              onSharePressed: () => _shareDetails(dueDetails),

              isDark: isDark,
            ),

            const SizedBox(height: 10),

            // Amount Details
            DuesAmountDetailsSection(dueDetails: dueDetails, isDark: isDark),

            // Payment History
            PaymentHistorySection(
              dueDetails: dueDetails,
              isExpanded: isPaymentHistoryExpanded,
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            // Main Action Buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (dueDetails.remainingDue > 0 &&
                      dueDetails.remainingDue > 0) ...[
                    FeatureVisitor(
                      featureKey: FeatureKeys.DUES.updateDues,

                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              dueDetails.remainingDue > 0
                                  ? () =>
                                  // _showAddPaymentDialog(dueDetails, isDark)
                                  showAddDuesPaymentBottomSheet(
                                    dueDetails: dueDetails,
                                    context: context,
                                    controller: controller,
                                    dueId: widget.dueId,
                                  )
                                  : null,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Add Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B6CF6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FeatureVisitor(
                    featureKey: FeatureKeys.DUES.notifyCustomersDue,

                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showNotifyDialog(dueDetails, isDark),
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF5B6CF6),
                          size: 20,
                        ),
                        label: const Text(
                          'Send Reminder',
                          style: TextStyle(
                            color: Color(0xFF5B6CF6),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF5B6CF6),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog(CustomerDueDetailsModel dueDetails, bool isDark) {
    final TextEditingController amountController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String selectedPaymentMode = 'CASH';

    /// Remove commas & get numeric remaining due
    final double remainingDue = double.parse(
      dueDetails.remainingDue.toString().replaceAll(',', ''),
    );

    /// Only digit count (no comma)
    final int maxDigits =
        dueDetails.remainingDue
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), '')
            .length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Payment',
                            style: TextStyle(
                              color:
                                  isDark
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFF374151),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color:
                                  isDark
                                      ? const Color(0xFF94A3B8)
                                      : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// Remaining Due Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining Due',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? const Color(0xFF94A3B8)
                                        : Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '₹${_formatAmount(remainingDue)}',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? const Color(0xFFF1F5F9)
                                        : const Color(0xFF374151),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Amount Field
                      buildStyledTextField(
                        labelText: 'Payment Amount',
                        controller: amountController,
                        hintText: 'Enter Amount',
                        keyboardType: TextInputType.number,
                        maxLength: maxDigits,
                        digitsOnly: true,
                        prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }

                          final amount = double.tryParse(value);

                          if (amount == null) {
                            return 'Invalid amount';
                          }

                          if (amount <= 0) {
                            return 'Amount must be greater than zero';
                          }

                          if (amount > remainingDue) {
                            return 'Amount cannot exceed remaining due';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// Payment Mode Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Mode',
                            style: TextStyle(
                              color: const Color(0xFF374151),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedPaymentMode,
                            dropdownColor:
                                isDark ? const Color(0xFF334155) : Colors.white,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFF374151),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Select Payment Mode',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.payment, size: 20),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2563EB),
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            items:
                                PaymentTypes.paymentMethods
                                    .map(
                                      (mode) => DropdownMenuItem(
                                        value: mode,
                                        child: Text(mode),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              selectedPaymentMode = value!;
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? const Color(0xFF475569)
                                          : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? const Color(0xFF94A3B8)
                                          : Colors.grey[700],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed:
                                    controller.isPartialAddedloading.value
                                        ? null
                                        : () async {
                                          /// Validate on tap
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          final amount = double.parse(
                                            amountController.text,
                                          );

                                          await controller.addPartialPayment(
                                            dueDetails.duesId,
                                            amount,
                                            selectedPaymentMode,
                                          );

                                          Navigator.pop(context);

                                          controller.fetchCustomerDueDetails(
                                            widget.dueId,
                                          );
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child:
                                    controller.isPartialAddedloading.value
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Text(
                                          'Add Payment',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
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
              ),
            ),
          ),
    );
  }

  /// Helper function to format amount
  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showNotifyDialog(CustomerDueDetailsModel dueDetails, bool isDark) {
    showDialog(
      context: context,
      builder:
          (context) => Theme(
            data: ThemeData(
              brightness: isDark ? Brightness.dark : Brightness.light,
              dialogBackgroundColor:
                  isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
            child: AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: Text(
                'Send Reminder',
                style: TextStyle(
                  color: isDark ? const Color(0xFFF1F5F9) : Colors.black87,
                ),
              ),
              content: Text(
                'Send payment reminder to ${dueDetails.customer.name}?',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color:
                          isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
                    ),
                  ),
                ),
                Obx(() {
                  return ElevatedButton(
                    onPressed: () async {
                      await controller.notifyCustomer(
                        dueDetails.customer.id ?? 0,
                        dueDetails.customer.name ?? "",
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF5B6CF6),
                    ),
                    child:
                        controller.isNotifying.value
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Send Reminder',
                              style: TextStyle(color: Colors.white),
                            ),
                  );
                }),
              ],
            ),
          ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    controller.callCustomer(phoneNumber);
  }

  void _openWhatsApp(CustomerDueDetailsModel customerDue) async {
    final businessName = await SharedPreferencesHelper.getShopStoreName();
    bool success = await WhatsAppService.sendDueMessage(
      customerDue: customerDue,
      businessName: businessName ?? "N/A",
      detailed: true,
    );
    if (success) {
      print('WhatsApp opened successfully');
    } else {
      print('Failed to open WhatsApp');
    }
  }

  void _shareDetails(CustomerDueDetailsModel dueDetails) async {
    final now = DateTime.now();
    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    await invoiceSettingsController.fetchInvoiceSettings();

    String paymentQRSection = '';
    if (invoiceSettingsController.hasQRScanner ||
        invoiceSettingsController.upiId.value.isNotEmpty) {
      paymentQRSection = '''

💳 PAYMENT INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

      if (invoiceSettingsController.hasQRScanner) {
        paymentQRSection += '''
📱 Scan QR Code for Payment:
${invoiceSettingsController.scannerImageUrl.value}

''';
      }

      if (invoiceSettingsController.upiId.value.isNotEmpty) {
        paymentQRSection += '''
💰 UPI ID: ${invoiceSettingsController.upiId.value}
💳 Accepted: PhonePe | GPay | Paytm | UPI Apps

''';
      }

      paymentQRSection += '━━━━━━━━━━━━━━━━━━━━━━━━━━';
    }

    final shareText = '''
━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 CUSTOMER DUE DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 CUSTOMER INFORMATION
├─ Name: ${dueDetails.customer.name ?? 'N/A'}
├─ Customer ID: ${dueDetails.customer.id ?? 'N/A'}
├─ Phone: ${dueDetails.customer.primaryPhone ?? 'N/A'}
├─ Email: ${dueDetails.customer.email ?? 'N/A'}
└─ Address: ${dueDetails.customer.primaryAddress ?? 'N/A'}

💳 DUE INFORMATION
├─ Due ID: #${dueDetails.duesId}
├─ Created: ${_formatDate(dueDetails.creationDateTime)}
├─ Status: ${dueDetails.isFullyPaid
        ? '✅ PAID'
        : dueDetails.isOverpaid
        ? '💚 OVERPAID'
        : '⏳ PENDING'}
└─ Progress: ${dueDetails.paymentProgress.toStringAsFixed(1)}%

💵 AMOUNT DETAILS
├─ Total Due: ₹${_formatAmount(dueDetails.totalDue)}
├─ Total Paid: ₹${_formatAmount(dueDetails.totalPaid)}
└─ Remaining: ₹${_formatAmount(dueDetails.remainingDue)}

${dueDetails.partialPayments.isNotEmpty ? '''
📊 PAYMENT HISTORY
${dueDetails.partialPayments.map((payment) => '├─ ₹${_formatAmount(payment.paidAmount)} - ${_formatDate(payment.paidDateTime)}').join('\n')}
''' : ''}$paymentQRSection
━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Generated: ${dateFormatter.format(now)} at ${timeFormatter.format(now)}
💼 SmartBecho - Smart Business Management

${dueDetails.remainingDue > 0 ? '\n⚠️ Payment Due: Please clear the remaining amount of ₹${_formatAmount(dueDetails.remainingDue)} at your earliest convenience.' : '\n✅ Account Settled: All dues have been cleared. Thank you!'}
━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    Rect? sharePositionOrigin;

    if (box != null) {
      sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
    } else {
      final size = MediaQuery.of(context).size;
      sharePositionOrigin = Rect.fromLTWH(
        size.width / 2,
        size.height / 2,
        10,
        10,
      );
    }

    Share.share(
      shareText,
      subject:
          'Customer Due Details - ${dueDetails.customer.name} (#${dueDetails.duesId})',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  // String _formatAmount(double amount) {
  //   final formatter = NumberFormat('#,##,###');
  //   return formatter.format(amount);
  // }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
