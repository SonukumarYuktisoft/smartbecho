// invoice_controller.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum InvoiceType { classic, modern, ultraModern }

class InvoiceController {
  final dynamic saleDetailResponse;
  final InvoiceType invoiceType;

  InvoiceController({
    required this.saleDetailResponse,
    required this.invoiceType,
  });

  // Capture widget as image
  Future<Uint8List?> captureInvoiceAsImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing invoice: $e');
      return null;
    }
  }

  // Download invoice as image
  Future<void> downloadInvoice(GlobalKey key, BuildContext context) async {
    try {
      final imageBytes = await captureInvoiceAsImage(key);
      if (imageBytes == null) {
        _showSnackBar(context, 'Failed to generate invoice');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'invoice_${saleDetailResponse.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      _showSnackBar(context, 'Invoice saved to ${file.path}');

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          text: 'Invoice ${saleDetailResponse.invoiceNumber}');
    } catch (e) {
      debugPrint('Error downloading invoice: $e');
      _showSnackBar(context, 'Error saving invoice: $e');
    }
  }

  // Generate PDF invoice
  Future<void> generatePDF(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPDFContent();
          },
        ),
      );

      // Save and share PDF
      final output = await getTemporaryDirectory();
      final fileName =
          'invoice_${saleDetailResponse.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)],
          text: 'Invoice ${saleDetailResponse.invoiceNumber}');
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      _showSnackBar(context, 'Error generating PDF: $e');
    }
  }

  // Print invoice
  Future<void> printInvoice(GlobalKey key) async {
    try {
      final imageBytes = await captureInvoiceAsImage(key);
      if (imageBytes == null) return;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();
          final image = pw.MemoryImage(imageBytes);

          pdf.addPage(
            pw.Page(
              pageFormat: format,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image),
                );
              },
            ),
          );

          return pdf.save();
        },
      );
    } catch (e) {
      debugPrint('Error printing invoice: $e');
    }
  }

  // Build PDF content
  pw.Widget _buildPDFContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  saleDetailResponse.shopName,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text('GST No: ${saleDetailResponse.shop.gstnumber}'),
                pw.Text('Email: ${saleDetailResponse.shop.email}'),
                pw.Text('Phone: ${saleDetailResponse.shop.phone}'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                      fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Invoice No: ${saleDetailResponse.invoiceNumber}'),
                pw.Text('Date: ${saleDetailResponse.formattedDate}'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Divider(),

        // Customer details
        pw.SizedBox(height: 20),
        pw.Text('Customer Details:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Name: ${saleDetailResponse.customer.name}'),
        pw.Text('Phone: ${saleDetailResponse.customer.primaryPhone}'),
        pw.Text('Address: ${saleDetailResponse.customer.primaryAddress}'),

        pw.SizedBox(height: 20),

        // Items table
        pw.Table.fromTextArray(
          headers: ['S.No', 'Item', 'Qty', 'Rate', 'Amount'],
          data: saleDetailResponse.items
              .asMap()
              .entries
              .map((entry) => [
                    (entry.key + 1).toString(),
                    '${entry.value.model}\n${entry.value.specifications}\nColor: ${entry.value.color}',
                    entry.value.quantity.toString(),
                    entry.value.formattedPrice,
                    entry.value.formattedPrice,
                  ])
              .toList(),
        ),

        pw.SizedBox(height: 20),

        // Totals
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildPDFRow('Without GST:', saleDetailResponse.formattedWithoutGst),
                _buildPDFRow('CGST (9%):', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}'),
                _buildPDFRow('SGST (9%):', '₹${(saleDetailResponse.gst / 2).toStringAsFixed(2)}'),
                pw.Divider(),
                pw.Text(
                  'TOTAL: ${saleDetailResponse.formattedAmount}',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(width: 20),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Get invoice title based on type
  String getInvoiceTitle() {
    switch (invoiceType) {
      case InvoiceType.classic:
        return 'Template 1';
      case InvoiceType.modern:
        return 'Template 2';
      case InvoiceType.ultraModern:
        return 'Template 3';
    }
  }
}

// Add these dependencies to pubspec.yaml:
/*
dependencies:
  path_provider: ^2.1.1
  share_plus: ^7.2.1
  pdf: ^3.10.7
  printing: ^5.11.1
*/