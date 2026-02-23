import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';
import 'package:smartbecho/services/payment_types.dart';
import 'package:smartbecho/utils/common_textfield.dart';

void showAddDuesPaymentBottomSheet({
  required CustomerDueDetailsModel dueDetails,
  required BuildContext context,
  required CustomerDuesController controller,
  
  required int dueId,
}) {
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
              color: Colors.white,
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
                            color: const Color(0xFF374151),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.grey[700]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Remaining Due Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining Due',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${_formatAmount(remainingDue)}',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 243, 92, 92),
                              // color: const Color(0xFF374151),
                              fontSize: 20,
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
                          dropdownColor: Colors.white,
                          style: TextStyle(
                            color: const Color(0xFF374151),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: const Color(0xFF475569)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[700],
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
                                          dueId,
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
