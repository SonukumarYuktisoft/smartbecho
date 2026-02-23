import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/sales%20management/components/sales%20details/sales%20details%20sections/sale_action_button_section.dart';
import 'package:smartbecho/views/sales%20management/components/sales%20details/sales%20details%20sections/sale_customer_info_section.dart';
import 'package:smartbecho/views/sales%20management/components/sales%20details/sales%20details%20sections/sale_emi_details_section.dart';
import 'package:smartbecho/views/sales%20management/components/sales%20details/sales%20details%20sections/sale_items_sold_section.dart';
import 'package:smartbecho/views/sales%20management/components/sales%20details/sales%20details%20sections/sale_pricing_details_section.dart';

class SaleDetailsPage extends StatefulWidget {
  @override
  _SaleDetailsPageState createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  final SalesManagementController controller =
      Get.find<SalesManagementController>();
  late int saleId;

  @override
  void initState() {
    super.initState();
    saleId = Get.arguments as int;
    controller.fetchSaleDetail(saleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sales Details"),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingDetail.value) {
            return _buildLoadingState();
          }

          if (controller.hasDetailError.value) {
            return _buildErrorState();
          }

          if (controller.saleDetail.value == null) {
            return _buildEmptyState();
          }

          return _buildDetailContent();
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B6CF6)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading sale details...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load sale details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.detailErrorMessage.value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.fetchSaleDetail(saleId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No sale details found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    final sale = controller.saleDetail.value!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Customer Section
            SaleCustomerInfoSection(sale: sale),
            const SizedBox(height: 16),

            // 2. Items Sold Section
            SaleItemsSoldSection(sale: sale),
            const SizedBox(height: 16),

            // 3. Pricing Details Section
            SalePricingDetailsSection(sale: sale),
            const SizedBox(height: 16),

            // 4. Profit Section (if needed)
            if (sale.totalProfit != null) _buildProfitSection(sale),

            // 5. EMI Section (if applicable)
            if (sale.emi != null) ...[
              const SizedBox(height: 16),
              SaleEmiDetailsSection(emi: sale.emi!),
            ],

            const SizedBox(height: 16),
            // 6. Action Buttons
            SaleActionButtonSection(sale: sale),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitSection(SaleDetailResponse sale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Profit Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProfitRow('Total Profit', sale.totalProfit ?? 0),
          const SizedBox(height: 12),
          _buildProfitRow(
            'Total Sale Margin',
            sale.overallProfitMargin ?? 0,
            isPercentage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitRow(
    String label,
    double value, {
    bool isPercentage = false,
  }) {
    Color color =
        value > 0
            ? const Color(0xFF10B981)
            : (value < 0 ? Colors.red : Colors.grey);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          isPercentage
              ? '${value.toStringAsFixed(2)}%'
              : '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
