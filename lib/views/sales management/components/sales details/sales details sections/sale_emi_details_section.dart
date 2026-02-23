import 'package:flutter/material.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/constant/app_images_string.dart';

class SaleEmiDetailsSection extends StatelessWidget {
  final SaleEmi emi;

  const SaleEmiDetailsSection({Key? key, required this.emi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImagesString.detailsPagePatternImage),
          fit: BoxFit.cover,
        ),
        gradient: const LinearGradient(
          colors: AppColors.primaryGradientLight,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.schedule, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'EMI Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EMI Resources',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${emi.completionPercentage.toStringAsFixed(0)}% (${emi.paidMonths}/${emi.totalMonths} Months)',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: emi.completionPercentage / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFA500),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // EMI Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Monthly EMI', emi.formattedMonthlyEmi),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem('Total Month', '${emi.totalMonths}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('Address', emi.customer.displayAddress),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
