// invoice_view_page.dart

import 'package:flutter/material.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/invoice_controller.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/sales%20management/components/invoices/classic_invoice_page.dart';
import 'package:smartbecho/views/sales%20management/components/invoices/modern_invoice_page.dart';
import 'package:smartbecho/views/sales%20management/components/invoices/professional_invoice.dart';
import 'package:smartbecho/views/sales%20management/components/invoices/ultra_modern_invoice.dart';


class InvoiceViewPage extends StatefulWidget {
  final dynamic saleDetailResponse;
  final InvoiceType invoiceType;

  const InvoiceViewPage({
    Key? key,
    required this.saleDetailResponse,
    required this.invoiceType,
  }) : super(key: key);

  @override
  State<InvoiceViewPage> createState() => _InvoiceViewPageState();
}

class _InvoiceViewPageState extends State<InvoiceViewPage> {
  final GlobalKey _invoiceKey = GlobalKey();
  late InvoiceController controller;

  @override
  void initState() {
    super.initState();
    controller = InvoiceController(
      saleDetailResponse: widget.saleDetailResponse,
      invoiceType: widget.invoiceType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: controller.getInvoiceTitle(),
        actionItem: [
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () => controller.downloadInvoice(_invoiceKey, context),
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            onPressed: () => controller.generatePDF(context),
            tooltip: 'PDF',
          ),
          IconButton(
            icon: const Icon(Icons.print, size: 20),
            onPressed: () => controller.printInvoice(_invoiceKey),
            tooltip: 'Print',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: RepaintBoundary(
          key: _invoiceKey,
          child: _buildInvoiceWidget(),
        ),
      ),
    );
  }

  Widget _buildInvoiceWidget() {
    switch (widget.invoiceType) {
      case InvoiceType.classic:
        return ProfessionalInvoice(saleDetailResponse: widget.saleDetailResponse);
      case InvoiceType.modern:
        return ModernInvoice(saleDetailResponse: widget.saleDetailResponse);
      case InvoiceType.ultraModern:
        return UltraModernInvoice(saleDetailResponse: widget.saleDetailResponse);
    }
  }
}