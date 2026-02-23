// modern_invoice.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/professional_invoice_controller.dart';

class ModernInvoice extends StatelessWidget {
  final dynamic saleDetailResponse;

  const ModernInvoice({
    Key? key,
    required this.saleDetailResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final invoiceController = Get.put(InvoiceSettingsController());
    invoiceController.loadSettingsFromCache();
    invoiceController.fetchInvoiceSettings();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModernHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickInfo(),
                const SizedBox(height: 16),
                _buildInfoCard('Customer Details', _buildCustomerInfo()),
                const SizedBox(height: 12),
                _buildInfoCard('Invoice Details', _buildInvoiceInfo()),
                const SizedBox(height: 16),
                _buildSectionTitle('Items'),
                const SizedBox(height: 12),
                _buildModernItemsList(),
                const SizedBox(height: 16),
                _buildPaymentMethod(),
                const SizedBox(height: 12),
                _buildSummary(),
                const SizedBox(height: 16),
                _buildPaymentAndSignatureSection(invoiceController),
                const SizedBox(height: 16),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAndSignatureSection(InvoiceSettingsController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.hasPaymentInfo || controller.hasQRScanner || controller.upiId.value.isNotEmpty) ...[
            _buildSectionTitle('Payment'),
            const SizedBox(height: 8),
            _buildModernPaymentBox(controller),
            const SizedBox(height: 12),
          ],
          _buildSectionTitle('Authorisation'),
          const SizedBox(height: 8),
          _buildModernSignatureBox(controller),
        ],
      );
    });
  }

  Widget _buildModernPaymentBox(InvoiceSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (controller.hasQRScanner) ...[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                controller.scannerImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.qr_code, size: 40)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.qr_code_2, size: 16, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      'Scan to Pay',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (controller.upiId.value.isNotEmpty) ...[
                  Text(
                    'UPI ID',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    controller.upiId.value,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: const [
                    Icon(Icons.phone_android, size: 14, color: Color(0xFF7E57C2)),
                    Text('PhonePe', style: TextStyle(fontSize: 10)),
                    Icon(Icons.payment, size: 14, color: Color(0xFF42A5F5)),
                    Text('GPay', style: TextStyle(fontSize: 10)),
                    Icon(Icons.account_balance_wallet, size: 14, color: Color(0xFF00ACC1)),
                    Text('Paytm', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSignatureBox(InvoiceSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (controller.hasStamp) ...[
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.network(
                controller.stampImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.approval, size: 28)),
                  );
                },
              ),
            ),
          ],
          if (controller.hasSignature) ...[
            Container(
              width: 120,
              height: 50,
              margin: const EdgeInsets.only(bottom: 6),
              child: Image.network(
                controller.signatureImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Container(width: 120, height: 1, color: Colors.grey.shade400),
          ],
          const SizedBox(height: 2),
          Text(
            'Authorised Signatory',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                    ),
                  ],
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GST: ${saleDetailResponse.shop.gstnumber}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  saleDetailResponse.shop.phone,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  saleDetailResponse.shop.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'INVOICE ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  saleDetailResponse.invoiceNumber,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoCard(
            Icons.calendar_today,
            saleDetailResponse.formattedDate,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickInfoCard(
            Icons.access_time,
            saleDetailResponse.formattedTime,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickInfoCard(
            Icons.check_circle,
            saleDetailResponse.paymentStatus,
            saleDetailResponse.paid ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernInfoRow(Icons.person, 'Name', saleDetailResponse.customer.name),
        const SizedBox(height: 8),
        _buildModernInfoRow(Icons.phone, 'Phone', saleDetailResponse.customer.primaryPhone),
        const SizedBox(height: 8),
        _buildModernInfoRow(Icons.location_on, 'Address', saleDetailResponse.customer.primaryAddress),
      ],
    );
  }

  Widget _buildInvoiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernInfoRow(Icons.receipt, 'Invoice No', saleDetailResponse.invoiceNumber),
        const SizedBox(height: 8),
        _buildModernInfoRow(Icons.calendar_today, 'Date', saleDetailResponse.formattedDate),
        const SizedBox(height: 8),
        _buildModernInfoRow(Icons.access_time, 'Time', saleDetailResponse.formattedTime),
      ],
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildModernItemsList() {
    return Column(
      children: saleDetailResponse.items.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final item = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    radius: 14,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.model,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    item.formattedPrice,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.specifications} • ${item.color}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.accessoryName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Accessory: ${item.accessoryName}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method: Cash',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${saleDetailResponse.paymentStatus}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', saleDetailResponse.formattedWithoutGst),
          _buildSummaryRow('Extra Charges', saleDetailResponse.formattedExtraCharges),
          _buildSummaryRow('Accessories', saleDetailResponse.formattedAccessoriesCost),
          _buildSummaryRow('Repair Charges', saleDetailResponse.formattedRepairCharges),
          _buildSummaryRow('Discount', saleDetailResponse.formattedTotalDiscount, isNegative: true),
          _buildSummaryRow('CGST (9%)', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}'),
          _buildSummaryRow('SGST (9%)', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}'),
          const Divider(thickness: 1, height: 16),
          _buildSummaryRow(
            'Total Amount',
            saleDetailResponse.formattedAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 12 : 11,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
          ),
          Text(
            isNegative ? '-$value' : value,
            style: TextStyle(
              fontSize: isTotal ? 13 : 11,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.blue.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Thank you for supporting a paperless world!',
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}