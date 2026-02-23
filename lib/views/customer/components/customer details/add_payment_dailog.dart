// widgets/payment_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_details_controller.dart';
import 'package:smartbecho/models/customer%20management/customer_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';

class PaymentDialog extends StatefulWidget {
  final DueDetail dueDetail;
  final String customerName;

  const PaymentDialog({
    Key? key,
    required this.dueDetail,
    required this.customerName,
  }) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final CustomerDetailsController controller =
      Get.find<CustomerDetailsController>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _selectedPaymentMethod = 'Cash';
  final List<String> _paymentMethods = ['Cash', 'Card', 'UPI', 'Bank Transfer'];

  double get _paymentAmount {
    final text = _amountController.text.trim();
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  double get _remainingAfterPayment {
    return widget.dueDetail.remainingDue - _paymentAmount;
  }

  bool get _isValidAmount {
    return _paymentAmount > 0 &&
        _paymentAmount <= widget.dueDetail.remainingDue;
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.dueDetail.remainingDue.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payment, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Process Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Payment Details'),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _infoColumn('Customer Name', widget.customerName),
                        SizedBox(width: 16),
                        _infoColumn(
                          'Invoice Number',
                          'DUE-${widget.dueDetail.id}',
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _infoColumn(
                          'Total Due',
                          '₹${widget.dueDetail.totalDue.toStringAsFixed(0)}',
                        ),
                        _infoColumn(
                          'Already Paid',
                          '₹${widget.dueDetail.totalPaid.toStringAsFixed(0)}',
                          color: Color(0xFF4CAF50),
                        ),
                        _infoColumn(
                          'Remaining Due',
                          '₹${widget.dueDetail.remainingDue.toStringAsFixed(0)}',
                          color: Color(0xFFFF6B6B),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _sectionTitle('Enter Payment Information'),
                    SizedBox(height: 12),
                    _paymentAmountField(),
                    SizedBox(height: 4),
                    _paymentMethodDropdown(),
                    SizedBox(height: 8),
                    Text(
                      'Remarks (Optional)',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _remarksController,
                        maxLines: 3,
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add any remarks here...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _sectionTitle('Payment Summary'),
                    SizedBox(height: 12),
                    _summaryRow(
                      'Payment Amount:',
                      '₹${_paymentAmount.toStringAsFixed(0)}',
                      Color(0xFF4CAF50),
                    ),
                    SizedBox(height: 8),
                    _paymentMethodSummary(),
                    SizedBox(height: 8),
                    _summaryRow(
                      'Remaining After Payment:',
                      '₹${_remainingAfterPayment.toStringAsFixed(0)}',
                      _remainingAfterPayment <= 0
                          ? Color(0xFF4CAF50)
                          : Color(0xFFFF9500),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey[400]!),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => ElevatedButton(
                              onPressed:
                                  _isValidAmount &&
                                          !controller.isProcessingPayment.value
                                      ? _processPayment
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4CAF50),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  controller.isProcessingPayment.value
                                      ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Pay ₹${_paymentAmount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _infoColumn(String title, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Amount',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isValidAmount ? Colors.grey[300]! : Colors.red,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              hintText: '50',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: Colors.black87),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Maximum ₹${widget.dueDetail.remainingDue.toStringAsFixed(0)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
        ),
      ],
    );
  }

  Widget _paymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.payments, color: Colors.white, size: 12),
              ),
            ),
            dropdownColor: Colors.white,
            style: TextStyle(color: Colors.black87, fontSize: 14),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black87),
            items:
                _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedPaymentMethod = value!);
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Payment Method:',
          style: TextStyle(color: Colors.grey[800], fontSize: 14),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payments, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                _selectedPaymentMethod.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _processPayment() async {
    if (!_isValidAmount) return;

    try {
      await controller.processPartialPayment(
        widget.dueDetail.id,
        _paymentAmount,
        _selectedPaymentMethod,
        _remarksController.text.trim(),
      );

      Get.back();
    } catch (_) {}
  }
}

void showPaymentDialog({
  required DueDetail dueDetail,
  required String customerName,
}) {
  Get.dialog(
    PaymentDialog(dueDetail: dueDetail, customerName: customerName),
    barrierDismissible: false,
  );
}
