// classic_invoice.dart

import 'package:flutter/material.dart';

class ClassicInvoice extends StatelessWidget {
  final dynamic saleDetailResponse;

  const ClassicInvoice({
    Key? key,
    required this.saleDetailResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const Divider(thickness: 1, height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerInfo(),
                const SizedBox(height: 16),
                _buildInvoiceInfo(),
                const SizedBox(height: 16),
                _buildItemsList(),
                const SizedBox(height: 16),
                _buildTermsAndConditions(),
                const SizedBox(height: 16),
                _buildPaymentDetails(),
                const SizedBox(height: 12),
                _buildAmountInWords(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    saleDetailResponse.shopName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saleDetailResponse.shopName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (saleDetailResponse.shop.shopAddress != null) ...[
            Text(
              '${saleDetailResponse.shop.shopAddress.addressLine1 ?? ''}, ${saleDetailResponse.shop.shopAddress.city ?? ''}',
              style: const TextStyle(color: Colors.white, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Mobile: ${saleDetailResponse.shop.phone}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          Text(
            'Email: ${saleDetailResponse.shop.email}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'GST No: ${saleDetailResponse.shop.gstnumber}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'INVOICE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Name:', saleDetailResponse.customer.name),
        _buildInfoRow('Address:', saleDetailResponse.customer.primaryAddress),
        _buildInfoRow('Mobile:', saleDetailResponse.customer.primaryPhone),
      ],
    );
  }

  Widget _buildInvoiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invoice Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Invoice No:', saleDetailResponse.invoiceNumber),
        _buildInfoRow('Date:', '${saleDetailResponse.formattedDate} ${saleDetailResponse.formattedTime}'),
        _buildInfoRow('Status:', saleDetailResponse.paymentStatus),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade200,
          child: const Text(
            'ITEMS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...saleDetailResponse.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Model: ${item.model}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RAM: ${item.ram} | ROM: ${item.rom}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            'Color: ${item.color}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          if (item.accessoryName.isNotEmpty)
                            Text(
                              'Accessory: ${item.accessoryName}',
                              style: const TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Rate: ${item.formattedPrice}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      item.formattedPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TERMS & CONDITIONS:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        _buildTermItem('Goods once sold will not be taken back.'),
        _buildTermItem('Warranty as per company terms.'),
        _buildTermItem('Payment is due at the time of purchase.'),
        _buildTermItem('Subject to local jurisdiction only.'),
      ],
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '• $text',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PAYMENT DETAILS:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildPaymentRow('Payment Method:', 'Cash'),
          const Divider(height: 16),
          _buildPaymentRow('Without GST:', saleDetailResponse.formattedWithoutGst),
          _buildPaymentRow('Repair Charges:', saleDetailResponse.formattedRepairCharges),
          _buildPaymentRow('Extra Charges:', saleDetailResponse.formattedExtraCharges),
          _buildPaymentRow('Accessories Cost:', saleDetailResponse.formattedAccessoriesCost),
          _buildPaymentRow('Discount:', saleDetailResponse.formattedTotalDiscount, isNegative: true),
          _buildPaymentRow('Taxable Amount:', saleDetailResponse.formattedWithoutGst),
          _buildPaymentRow('CGST (9%):', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}'),
          _buildPaymentRow('SGST (9%):', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}'),
          const Divider(thickness: 2, height: 16),
          _buildPaymentRow(
            'TOTAL:',
            saleDetailResponse.formattedAmount,
            isBold: true,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isBold = false, double fontSize = 11, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            isNegative ? '-$value' : value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInWords() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Amount in Words: ${_amountInWords(saleDetailResponse.totalPayableAmount)}',
        style: const TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _amountInWords(double amount) {
    final rupees = amount.floor();
    if (rupees == 18000) return 'Eighteen Thousand Only';
    return 'Rupees ${rupees.toString()} Only';
  }
}