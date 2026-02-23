import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';

class SaleActionButtonSection extends StatelessWidget {
  final SaleDetailResponse sale;

  SaleActionButtonSection({super.key, required this.sale});

  final SalesManagementController controller =
      Get.find<SalesManagementController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick Action Buttons (Call, WhatsApp, Share)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (sale.pdfUrl.isNotEmpty) ...[
                _buildQuickActionButton(
                  icon: Icons.download,
                  label: 'Download',
                  onTap: () => controller.downloadInvoiceFromDetail(sale),
                ),
                _buildQuickActionButton(
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'WhatsApp',
                  onTap: () => controller.shareInvoiceLinkToWhatsApp(sale),
                ),
                _buildQuickActionButton(
                  icon: Icons.print,
                  label: 'Print',
                  onTap:
                      () => controller.downloadAndPrintInvoiceFromDetail(sale),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,

    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
