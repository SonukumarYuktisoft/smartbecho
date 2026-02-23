import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/bill_history_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/constant/app_images_string.dart';

class BillHeaderSection extends StatelessWidget {
  final Bill bill;

  const BillHeaderSection({
    Key? key,
    required this.bill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppImagesString.detailsPagePatternImage,),
        fit: BoxFit.cover,
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B68F4), Color(0xFF4A56E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distributor Label
          Center(
            child: Column(
              children: [
                Text(
                  'Distributor',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Company Name
                Text(
                  bill.companyName.isNotEmpty ? bill.companyName : 'N/A',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bill ID and Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                label: 'Bill ID',
                value: bill.billId.toString(),
                onTap: () => _copyToClipboard(
                  bill.billId.toString(),
                  'Bill ID',
                ),
              ),
              _buildInfoItem(
                label: 'Date',
                value: bill.formattedDate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.copy,
                  color: Colors.white.withOpacity(0.7),
                  size: 14,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      '$label copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      icon: const Icon(Icons.copy, color: Colors.white),
      margin: const EdgeInsets.all(16),
    );
  }
}