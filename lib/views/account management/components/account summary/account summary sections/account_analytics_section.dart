// lib/views/account_management/components/sections/account_analytics_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';

/// GST Summary Section
class AccountGSTSummarySection extends StatelessWidget {
  final AccountManagementController controller;

  const AccountGSTSummarySection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
        boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(context)),
      ),
      child: Column(
        children: [
          _buildGSTItem(
            context,
            'GST on Sales',
            "+ ${controller.formattedGstOnSales}",
            Icons.add_circle_outline,
            const Color(0xFF1565C0),
            amountColor: Colors.green,
          ),
          Divider(height: 20, color: const Color(0xFFE0E0E0)),
          _buildGSTItem(
            context,
            'GST on Purchases',
            "– ${controller.formattedGstOnPurchases}",
            Icons.remove_circle_outline,
            const Color(0xFF0277BD),
            amountColor: Colors.redAccent,
          ),
          Divider(height: 20, color: const Color(0xFFE0E0E0)),
          _buildGSTItem(
            context,
            'Net GST',
            controller.netGst >= 0
                ? "+ ${controller.formattedNetGst}"
                : "– ${controller.formattedNetGst.replaceAll('-', '')}",
            Icons.account_balance,
            const Color(0xFF01579B),
            amountColor:
                controller.netGst >= 0 ? Colors.green : Colors.redAccent,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGSTItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isTotal = false,
    Color? amountColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              color:
                  isTotal
                      ? AppColors.textPrimary(context)
                      : AppColors.textSecondary(context),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            fontWeight: FontWeight.bold,
            color: amountColor ?? Colors.teal,
          ),
        ),
      ],
    );
  }
}

/// Account Activity Chart Section
class AccountActivityChartSection extends StatelessWidget {
  final AccountManagementController controller;

  const AccountActivityChartSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
        boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credit vs Debit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          _buildBarChart(context),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(context, 'Credit', AppColors.errorLight),
              _buildLegendItem(context, 'Debit', AppColors.successLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final credit = controller.totalCredit;
    final debit = controller.totalDebit;
    final maxValue = credit > debit ? credit : debit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildBar(context, 'Credit', credit, maxValue, AppColors.errorLight),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildBar(context, 'Debit', debit, maxValue, AppColors.successLight),
        ),
      ],
    );
  }

  Widget _buildBar(
    BuildContext context,
    String label,
    double value,
    double maxValue,
    Color color,
  ) {
    final percentage = maxValue > 0 ? (value / maxValue) : 0.0;
    final height = 150.0 * percentage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height < 30 ? 30 : height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}