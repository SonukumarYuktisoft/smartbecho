// ultra_modern_invoice.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/professional_invoice_controller.dart';

class UltraModernInvoice extends StatelessWidget {
  final dynamic saleDetailResponse;

  const UltraModernInvoice({
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
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUltraModernHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickInfo(),
                const SizedBox(height: 16),
                _buildStylishInfoCard('BILL TO', _buildCustomerInfo(), Colors.purple),
                const SizedBox(height: 12),
                _buildStylishInfoCard('INVOICE INFO', _buildInvoiceInfo(), Colors.orange),
                const SizedBox(height: 16),
                _buildUltraModernItems(),
                const SizedBox(height: 16),
                _buildAmountBreakdown(),
                const SizedBox(height: 16),
                _buildPromoSection(),
                const SizedBox(height: 16),
                _buildUltraPaymentAndSignature(invoiceController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraPaymentAndSignature(InvoiceSettingsController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.hasPaymentInfo || controller.hasQRScanner || controller.upiId.value.isNotEmpty) ...[
            _buildStylishInfoCard(
              'PAYMENT',
              _buildUltraPaymentBox(controller),
              Colors.teal,
            ),
            const SizedBox(height: 12),
          ],
          _buildStylishInfoCard(
            'AUTHORIZATION',
            _buildUltraSignatureBox(controller),
            Colors.deepPurple,
          ),
        ],
      );
    });
  }

  Widget _buildUltraPaymentBox(InvoiceSettingsController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (controller.hasQRScanner) ...[
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                controller.scannerImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.qr_code, size: 44)),
                  );
                },
              ),
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
                  Icon(Icons.qr_code_scanner, size: 16, color: Colors.teal),
                  SizedBox(width: 6),
                  Text('Scan to Pay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              if (controller.upiId.value.isNotEmpty) ...[
                Text('UPI ID', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 2),
                SelectableText(
                  controller.upiId.value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: const [
                  Icon(Icons.phone_android, size: 14, color: Color(0xFF8E24AA)),
                  Text('PhonePe', style: TextStyle(fontSize: 10)),
                  Icon(Icons.payment, size: 14, color: Color(0xFF1E88E5)),
                  Text('GPay', style: TextStyle(fontSize: 10)),
                  Icon(Icons.account_balance_wallet, size: 14, color: Color(0xFF00838F)),
                  Text('Paytm', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUltraSignatureBox(InvoiceSettingsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (controller.hasStamp) ...[
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                controller.stampImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.approval, size: 30)),
                  );
                },
              ),
            ),
          ),
        ],
        if (controller.hasSignature) ...[
          Container(
            width: 140,
            height: 54,
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
          Container(width: 140, height: 1, color: Colors.grey.shade400),
        ],
        const SizedBox(height: 2),
        Text(
          'Authorised Signatory',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildUltraModernHeader() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade700,
                Colors.purple.shade600,
                Colors.pink.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade100],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        saleDetailResponse.shopName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
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
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'GST: ${saleDetailResponse.shop.gstnumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                    child: Row(
                      children: [
                        Icon(Icons.phone_android, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            saleDetailResponse.shop.phone,
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.email, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            saleDetailResponse.shop.email,
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade500],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'INVOICE ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      saleDetailResponse.invoiceNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoCard(
            Icons.calendar_today,
            'Date',
            saleDetailResponse.formattedDate,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickInfoCard(
            Icons.access_time,
            'Time',
            saleDetailResponse.formattedTime,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickInfoCard(
            Icons.check_circle,
            'Status',
            saleDetailResponse.paymentStatus,
            saleDetailResponse.paid ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStylishInfoCard(String title, Widget content, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUltraInfoRow('👤', 'Name', saleDetailResponse.customer.name),
        const SizedBox(height: 8),
        _buildUltraInfoRow('📱', 'Phone', saleDetailResponse.customer.primaryPhone),
        const SizedBox(height: 8),
        _buildUltraInfoRow('📍', 'Address', saleDetailResponse.customer.primaryAddress),
      ],
    );
  }

  Widget _buildInvoiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUltraInfoRow('📄', 'Invoice No', saleDetailResponse.invoiceNumber),
        const SizedBox(height: 8),
        _buildUltraInfoRow('📅', 'Date', '${saleDetailResponse.formattedDate} ${saleDetailResponse.formattedTime}'),
        const SizedBox(height: 8),
        _buildUltraInfoRow('💳', 'Payment', 'Cash'),
      ],
    );
  }

  Widget _buildUltraInfoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
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

  Widget _buildUltraModernItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ITEMS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...saleDetailResponse.items.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade400, Colors.pink.shade400],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildItemBadge(item.specifications, Colors.blue),
                          _buildItemBadge(item.color, Colors.green),
                        ],
                      ),
                    ),
                    Text(
                      item.formattedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                if (item.accessoryName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.add_circle, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.accessoryName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildItemBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAmountBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade800.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBreakdownRow('Subtotal', saleDetailResponse.formattedWithoutGst, false),
          _buildBreakdownRow('Extras', saleDetailResponse.formattedExtraCharges, false),
          _buildBreakdownRow('Accessories', saleDetailResponse.formattedAccessoriesCost, false),
          _buildBreakdownRow('Repairs', saleDetailResponse.formattedRepairCharges, false),
          _buildBreakdownRow('Discount', saleDetailResponse.formattedTotalDiscount, false, isNegative: true),
          _buildBreakdownRow('CGST (9%)', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}', false),
          _buildBreakdownRow('SGST (9%)', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}', false),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          _buildBreakdownRow('TOTAL', saleDetailResponse.formattedAmount, true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, bool isTotal, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTotal ? 14 : 11,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
                letterSpacing: isTotal ? 0.5 : 0,
              ),
            ),
          ),
          Text(
            isNegative ? '-$value' : value,
            style: TextStyle(
              color: isTotal ? Colors.amber.shade400 : Colors.white,
              fontSize: isTotal ? 18 : 12,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Column(
      children: [
        _buildPromoCard(
          Icons.local_offer,
          'Up to 15% off',
          'on Insurance',
          [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          Colors.orange.shade700,
        ),
        const SizedBox(height: 10),
        _buildPromoCard(
          Icons.attach_money,
          'Instant Loan',
          'Up to ₹5 Lakh',
          [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          Colors.red.shade700,
        ),
      ],
    );
  }

  Widget _buildPromoCard(IconData icon, String title, String subtitle, List<Color> gradientColors, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}