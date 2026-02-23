import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/professional_invoice_controller.dart';

class ProfessionalInvoice extends StatelessWidget {
  final dynamic saleDetailResponse;

  const ProfessionalInvoice({
    Key? key,
    required this.saleDetailResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final invoiceController = Get.put(InvoiceSettingsController());
    
    // Load settings on init
    invoiceController.loadSettingsFromCache();
    invoiceController.fetchInvoiceSettings();

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
          const Divider(thickness: 2, height: 2),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceTitle(),
                const SizedBox(height: 16),
                _buildBillToShipTo(),
                const SizedBox(height: 16),
                _buildItemsTable(),
                const SizedBox(height: 16),
                _buildTaxSummary(),
                const SizedBox(height: 16),
                _buildAmountInWords(),
                const SizedBox(height: 16),
                _buildFooterSection(invoiceController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Safe getter for shop name
    String getShopName() {
      try {
        if (saleDetailResponse.shopName != null && saleDetailResponse.shopName.isNotEmpty) {
          return saleDetailResponse.shopName;
        }
      } catch (e) {}
      try {
        if (saleDetailResponse.shop?.shopStoreName != null && saleDetailResponse.shop!.shopStoreName.isNotEmpty) {
          return saleDetailResponse.shop!.shopStoreName;
        }
      } catch (e) {}
      return 'Shop Name';
    }

    // Safe getters for shop details
    String getShopPhone() {
      try {
        return saleDetailResponse.shop?.phone ?? '';
      } catch (e) {
        return '';
      }
    }

    String getShopEmail() {
      try {
        return saleDetailResponse.shop?.email ?? '';
      } catch (e) {
        return '';
      }
    }

    String getShopGST() {
      try {
        return saleDetailResponse.shop?.gstnumber ?? '';
      } catch (e) {
        return '';
      }
    }

    String getShopAddress() {
      try {
        final address = saleDetailResponse.shop?.shopAddress;
        if (address != null) {
          return '${address.addressLine1 ?? ''}, ${address.city ?? ''}, ${address.state ?? ''} - ${address.pincode ?? ''}';
        }
      } catch (e) {}
      return '';
    }

    final shopName = getShopName();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Logo/Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                shopName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Shop Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (getShopAddress().isNotEmpty) ...[
                  Text(
                    getShopAddress(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    if (getShopPhone().isNotEmpty) ...[
                      const Icon(Icons.phone, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        getShopPhone(),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (getShopEmail().isNotEmpty) ...[
                      const Icon(Icons.email, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          getShopEmail(),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (getShopGST().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'GSTIN: ${getShopGST()}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Text(
                'TAX INVOICE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ORIGINAL FOR RECIPIENT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildInfoItem('Invoice No.', saleDetailResponse.invoiceNumber, isBold: true),
            _buildInfoItem('Invoice Date', saleDetailResponse.formattedDate),
            _buildInfoItem('Due Date', _calculateDueDate(saleDetailResponse.formattedDate)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillToShipTo() {
    // Safe getters for customer data
    String getCustomerName() {
      try {
        return saleDetailResponse.customer?.name ?? saleDetailResponse.customerName ?? 'Customer';
      } catch (e) {
        return 'Customer';
      }
    }

    String getCustomerAddress() {
      try {
        return saleDetailResponse.customer?.primaryAddress ?? '';
      } catch (e) {
        return '';
      }
    }

    String getCustomerPhone() {
      try {
        return saleDetailResponse.customer?.primaryPhone ?? '';
      } catch (e) {
        return '';
      }
    }

    String getCustomerEmail() {
      try {
        return saleDetailResponse.customer?.email ?? '';
      } catch (e) {
        return '';
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildAddressBox(
            'Customer Info',
            getCustomerName(),
            getCustomerAddress(),
            getCustomerPhone(),
            getCustomerEmail(),
          ),
        ),
        // const SizedBox(width: 12),
        // Expanded(
        //   child: _buildAddressBox(
        //     'SHIP TO',
        //     getCustomerName(),
        //     getCustomerAddress(),
        //     getCustomerPhone(),
        //     '',
        //   ),
        // ),
      ],
    );
  }

  Widget _buildAddressBox(String title, String name, String address, String phone, String email) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: const TextStyle(fontSize: 10, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Mobile: $phone',
            style: const TextStyle(fontSize: 10, color: Colors.black87),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 10, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _getHSNCode(dynamic item) {
    // Try to get HSN code from different possible property names
    try {
      if (item.hsnCode != null) return item.hsnCode.toString();
    } catch (e) {}
    try {
      if (item.hsn != null) return item.hsn.toString();
    } catch (e) {}
    try {
      if (item.hsnNumber != null) return item.hsnNumber.toString();
    } catch (e) {}
    return ''; // Default HSN code for electronics
  }

  String _getIMEI(dynamic item) {
    // Try to get IMEI from different possible property names
    try {
      if (item.imei != null && item.imei.toString().isNotEmpty) {
        return item.imei.toString();
      }
    } catch (e) {}
    try {
      if (item.serialNumber != null && item.serialNumber.toString().isNotEmpty) {
        return item.serialNumber.toString();
      }
    } catch (e) {}
    try {
      if (item.serial != null && item.serial.toString().isNotEmpty) {
        return item.serial.toString();
      }
    } catch (e) {}
    return 'N/A'; // Default if no IMEI/Serial found
  }

  String _getWarrantyDate(dynamic item) {
    // Try to get warranty date from different possible property names
    try {
      if (item.warrantyExpiryDate != null && item.warrantyExpiryDate.toString().isNotEmpty) {
        return _formatWarrantyDate(item.warrantyExpiryDate.toString());
      }
    } catch (e) {}
    try {
      if (item.warrantyExpiry != null && item.warrantyExpiry.toString().isNotEmpty) {
        return _formatWarrantyDate(item.warrantyExpiry.toString());
      }
    } catch (e) {}
    try {
      if (item.warranty != null && item.warranty.toString().isNotEmpty) {
        return _formatWarrantyDate(item.warranty.toString());
      }
    } catch (e) {}
    return '-'; // Default if no warranty date found
  }

 Widget _buildItemsTable() {
    // Calculate actual GST amount
    final double gstAmount = saleDetailResponse.withGst - saleDetailResponse.withoutGst;
    final double cgstAmount = gstAmount / 2;
    final double sgstAmount = gstAmount / 2;
    
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              _buildTableHeader('S.NO.', flex: 1),
              _buildTableHeader('ITEMS', flex: 5),
              _buildTableHeader('HSN', flex: 2),
              _buildTableHeader('QTY.', flex: 1),
              _buildTableHeader('RATE', flex: 2),
              _buildTableHeader('AMOUNT', flex: 2),
            ],
          ),
        ),
        // Table Body
        ...saleDetailResponse.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableCell('${index + 1}', flex: 1),
                _buildTableCell(
                  '${item.model}\nIMEI/Serial No: ${_getIMEI(item)}\nRAM: ${item.ram} | ROM: ${item.rom} | Color: ${item.color}${item.accessoryName.isNotEmpty ? '\nAccessory: ${item.accessoryName}' : ''}',
                  flex: 5,
                  isLeft: true,
                ),
                _buildTableCell(_getHSNCode(item), flex: 2),
                _buildTableCell('${item.quantity} PCS', flex: 1),
                _buildTableCell(item.formattedPrice, flex: 2),
                _buildTableCell(item.formattedPrice, flex: 2, isBold: true),
              ],
            ),
          );
        }).toList(),
        // Tax Rows
        _buildTaxRow('CGST @${(saleDetailResponse.gst / 2).toStringAsFixed(1)}%', '₹${cgstAmount.toStringAsFixed(2)}'),
        _buildTaxRow('SGST @${(saleDetailResponse.gst / 2).toStringAsFixed(1)}%', '₹${sgstAmount.toStringAsFixed(2)}'),
        // Total Row
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade700,
            border: Border.all(color: Colors.purple.shade700),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 10,
                child: Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${saleDetailResponse.items.fold(0, (sum, item) => sum + item.quantity)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(flex: 2, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Text(
                  saleDetailResponse.formattedWithGst,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.purple.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1, bool isLeft = false, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTaxRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          const Expanded(flex: 10, child: SizedBox()),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildTaxSummary() {
    // Calculate actual GST amount from the difference
    final double gstAmount = saleDetailResponse.withGst - saleDetailResponse.withoutGst;
    final double cgstAmount = gstAmount / 2;
    final double sgstAmount = gstAmount / 2;
    final double gstPercent = saleDetailResponse.gst;
    final double cgstPercent = gstPercent / 2;
    final double sgstPercent = gstPercent / 2;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTaxSummaryRow('HSN/SAC', 'Taxable Value', 'CGST', 'SGST', 'Total Tax', isHeader: true),
                const Divider(height: 12),
                _buildTaxSummaryRow(
                  _getHSNCode(saleDetailResponse.items.first),
                  saleDetailResponse.formattedWithoutGst,
                  '${cgstPercent.toStringAsFixed(1)}%\n₹${cgstAmount.toStringAsFixed(2)}',
                  '${sgstPercent.toStringAsFixed(1)}%\n₹${sgstAmount.toStringAsFixed(2)}',
                  '₹${gstAmount.toStringAsFixed(2)}',
                ),
                const Divider(height: 12),
                _buildTaxSummaryRow(
                  'Total',
                  saleDetailResponse.formattedWithoutGst,
                  '₹${cgstAmount.toStringAsFixed(2)}',
                  '₹${sgstAmount.toStringAsFixed(2)}',
                  '₹${gstAmount.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSummaryRow(String hsn, String taxable, String cgst, String sgst, String total, {bool isHeader = false, bool isBold = false}) {
    final style = TextStyle(
      fontSize: 10,
      fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? Colors.purple.shade700 : Colors.black87,
    );

    return Row(
      children: [
        Expanded(flex: 2, child: Text(hsn, style: style, textAlign: TextAlign.center)),
        Expanded(flex: 2, child: Text(taxable, style: style, textAlign: TextAlign.center)),
        Expanded(flex: 2, child: Text(cgst, style: style, textAlign: TextAlign.center)),
        Expanded(flex: 2, child: Text(sgst, style: style, textAlign: TextAlign.center)),
        Expanded(flex: 2, child: Text(total, style: style, textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _buildAmountInWords() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Amount (in words)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _amountInWords(saleDetailResponse.totalPayableAmount),
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFooterSection(InvoiceSettingsController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (controller.hasPaymentInfo) ...[
                _buildPaymentQRCode(controller),
                const SizedBox(height: 12),
              ],
              _buildSignatureSection(controller),
            ],
          ),
          // Bank Details & Terms
          const SizedBox(height: 16),

          _buildTermsAndConditions(),
          // Payment QR Code & Signature
         
        ],
      );
    });
  }

  Widget _buildBankDetails(InvoiceSettingsController controller) {
    // Safe getter for shop name
    String getShopName() {
      try {
        if (saleDetailResponse.shopName != null && saleDetailResponse.shopName.isNotEmpty) {
          return saleDetailResponse.shopName;
        }
      } catch (e) {}
      try {
        if (saleDetailResponse.shop?.shopStoreName != null && saleDetailResponse.shop!.shopStoreName.isNotEmpty) {
          return saleDetailResponse.shop!.shopStoreName;
        }
      } catch (e) {}
      return 'Shop Name';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const Divider(height: 12),
          _buildBankDetailRow('Name:', getShopName()),
          _buildBankDetailRow('IFSC Code:', 'HDFC0000182'),
          _buildBankDetailRow('Account No:', '12345678915950'),
          _buildBankDetailRow('Bank:', 'HDFC Bank, MUMBAI - KANDIVALI EAST'),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentQRCode(InvoiceSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Text(
            'Payment QR Code',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          // QR Code Scanner Image
          if (controller.hasQRScanner)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.network(
                controller.scannerImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.qr_code, size: 48),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(Icons.qr_code, size: 48),
              ),
            ),
          const SizedBox(height: 8),
          if (controller.upiId.value.isNotEmpty) ...[
            const Text(
              'UPI ID:',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            ),
            Text(
              controller.upiId.value,
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: const [
              Icon(Icons.phone_android, size: 14, color: Colors.purple),
              Text('PhonePe', style: TextStyle(fontSize: 8)),
              Icon(Icons.payment, size: 14, color: Colors.blue),
              Text('GPay', style: TextStyle(fontSize: 8)),
              Icon(Icons.account_balance_wallet, size: 14, color: Colors.cyan),
              Text('Paytm', style: TextStyle(fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection(InvoiceSettingsController controller) {
    // Safe getter for shop name
    String getShopName() {
      try {
        if (saleDetailResponse.shopName != null && saleDetailResponse.shopName.isNotEmpty) {
          return saleDetailResponse.shopName;
        }
      } catch (e) {}
      try {
        if (saleDetailResponse.shop?.shopStoreName != null && saleDetailResponse.shop!.shopStoreName.isNotEmpty) {
          return saleDetailResponse.shop!.shopStoreName;
        }
      } catch (e) {}
      return 'Shop Name';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Stamp - Only show if enabled
          if (controller.hasStamp) ...[
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.network(
                controller.stampImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.approval, size: 32),
                    ),
                  );
                },
              ),
            ),
          ],
          
          if (controller.hasStamp || controller.hasSignature)
            const SizedBox(height: 40),
          
          // Signature - Only show if enabled
          if (controller.hasSignature) ...[
            Container(
              width: 120,
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              child: Image.network(
                controller.signatureImageUrl.value,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else if (!controller.hasStamp) ...[
            // Show placeholder line only if neither stamp nor signature
            Container(
              width: 120,
              height: 1,
              color: Colors.grey.shade400,
            ),
          ],
          
          const SizedBox(height: 4),
          Text(
            'Authorised Signatory For',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            getShopName(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    // Safe getter for city
    String getCity() {
      try {
        return saleDetailResponse.shop?.shopAddress?.city ?? 'Your City';
      } catch (e) {
        return 'Your City';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 6),
          _buildTermItem('Goods once sold will not be taken back or exchanged'),
          _buildTermItem('All disputes are subject to ${getCity()} jurisdiction only'),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '• $text',
        style: const TextStyle(fontSize: 9),
      ),
    );
  }

  String _calculateDueDate(String invoiceDate) {
    try {
      final parts = invoiceDate.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        final dueDate = date.add(const Duration(days: 30));
        return '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}';
      }
    } catch (e) {
      // Return default if parsing fails
    }
    return '14/02/2025';
  }

  String _formatWarrantyDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]} ${_getMonthName(int.parse(parts[1]))}, ${parts[0]}';
      }
    } catch (e) {
      // Return as is if parsing fails
    }
    return date;
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  String _amountInWords(double amount) {
    final rupees = amount.floor();
    return 'Rupees ${_numberToWords(rupees)} Only';
  }

  String _numberToWords(int number) {
    if (number == 0) return 'Zero';
    
    const ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
    const teens = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    
    if (number < 10) return ones[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      return tens[number ~/ 10] + (number % 10 != 0 ? ' ${ones[number % 10]}' : '');
    }
    if (number < 1000) {
      return '${ones[number ~/ 100]} Hundred${number % 100 != 0 ? ' ${_numberToWords(number % 100)}' : ''}';
    }
    if (number < 100000) {
      return '${_numberToWords(number ~/ 1000)} Thousand${number % 1000 != 0 ? ' ${_numberToWords(number % 1000)}' : ''}';
    }
    if (number < 10000000) {
      return '${_numberToWords(number ~/ 100000)} Lakh${number % 100000 != 0 ? ' ${_numberToWords(number % 100000)}' : ''}';
    }
    
    return number.toString(); // Fallback for very large numbers
  }
}