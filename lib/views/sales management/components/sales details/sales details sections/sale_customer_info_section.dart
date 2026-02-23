import 'package:flutter/material.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/constant/app_images_string.dart';

class SaleCustomerInfoSection extends StatelessWidget {
  final SaleDetailResponse sale;

  const SaleCustomerInfoSection({Key? key, required this.sale})
    : super(key: key);

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
        children: [
          // Profile Image & Name
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/customer.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sale.customer.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Customer Details
          _buildInfoRow('Phone', sale.customer.displayPhone, Icons.phone),

          if (sale.customer.email != null &&
              sale.customer.email!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Email', sale.customer.email!, Icons.phone),
          ],

          const SizedBox(height: 12),
          _buildInfoRow('Location', sale.customer.location, Icons.location_on),
          if (sale.customer.displayAddress != 'No address') ...[
            const SizedBox(height: 12),
            _buildInfoRow('Address', sale.customer.displayAddress, Icons.home),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon(icon, size: 18, color: Colors.white),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
