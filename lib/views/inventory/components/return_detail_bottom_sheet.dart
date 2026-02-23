import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/models/inventory%20management/product_return_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnDetailBottomSheet extends StatelessWidget {
  final ProductReturn returnItem;

  const ReturnDetailBottomSheet({Key? key, required this.returnItem})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Return Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Return ID Card
                  _buildReturnIdCard(),
                  SizedBox(height: 20),

                  // Product Information Section
                  _buildSectionTitle('Product Information'),
                  SizedBox(height: 12),
                  _buildProductInfoSection(),
                  SizedBox(height: 20),

                  // Return Details Section
                  _buildSectionTitle('Return Details'),
                  SizedBox(height: 12),
                  _buildReturnDetailsSection(),
                  SizedBox(height: 20),

                  // Additional Information
                  if (returnItem.notes != null &&
                      returnItem.notes!.isNotEmpty) ...[
                    _buildSectionTitle('Notes'),
                    SizedBox(height: 12),
                    _buildNotesSection(),
                    SizedBox(height: 20),
                  ],

                  // Document Section
                  if (returnItem.returnDocumentUrl != null) ...[
                    _buildSectionTitle('Return Document'),
                    SizedBox(height: 12),
                    _buildDocumentSection(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnIdCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // colors: [AppColors.primaryLight, Color(0xFF59F0D2)],
          colors: AppColors.primaryGradientLight,

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Return ID',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '#${returnItem.returnSequence}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Return Date',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(returnItem.returnDate),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('Company', returnItem.company),
          SizedBox(height: 12),
          _buildInfoRow('Category', returnItem.itemCategory),
          SizedBox(height: 12),
          _buildInfoRow('Model', returnItem.model),
          SizedBox(height: 12),
          _buildInfoRow('RAM', returnItem.ram),
          SizedBox(height: 12),
          _buildInfoRow('ROM', returnItem.rom),
          SizedBox(height: 12),
          _buildInfoRow('Color', returnItem.color),
          if (returnItem.imei != null) ...[
            SizedBox(height: 12),
            _buildInfoRow('IMEI', returnItem.imei!),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnDetailsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Distributor',
                  returnItem.distributor,
                  isMultiline: true,
                ),
              ),
              _buildSource(source: returnItem.source),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Return Price',
            '₹${returnItem.returnPrice.toStringAsFixed(0)}',
            valueStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow('Quantity', returnItem.quantity.toString()),
          SizedBox(height: 12),
          _buildInfoRow('Source', returnItem.source),
          SizedBox(height: 12),
          _buildInfoRow('Reason', returnItem.reason, isMultiline: true),
        ],
      ),
    );
  }

  Widget _buildSource({required String source}) {
    bool isOnline = source == 'Online'.toUpperCase();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
          width: 1,
        ),
      ),
      child: Text(
        source,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        returnItem.notes!,
        style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
      ),
    );
  }

  Widget _buildDocumentSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(returnItem.returnDocumentUrl!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            Get.snackbar(
              'Error',
              'Could not open document',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.description,
                color: AppColors.primaryLight,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Document',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to open in browser',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isMultiline = false,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
