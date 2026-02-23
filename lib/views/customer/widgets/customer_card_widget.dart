import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/models/customer%20management/customer_data_model.dart';

/// Individual customer card widget
/// Displays customer information in a compact card format
class CustomerCardWidget extends StatelessWidget {
  final Customer customer;
  final CustomerController controller;
  final Color? backgroundColor;

  const CustomerCardWidget({
    super.key,
    required this.customer,
    required this.controller,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetails(),
      child: Card.outlined(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        color: backgroundColor?.withValues(alpha: 0.5) ?? Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              _buildCustomerInfo(),
              const SizedBox(width: 16),
              _buildFinancialInfo(),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to customer details
  void _navigateToDetails() {
    Get.toNamed(AppRoutes.customerDetails, arguments: customer.id);
  }

  /// Build customer avatar with gradient background
  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            controller.getCustomerTypeColor(customer.customerType),
            controller
                .getCustomerTypeColor(customer.customerType)
                .withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildAvatarImage(),
      ),
    );
  }

  /// Build avatar image (network or placeholder)
  Widget _buildAvatarImage() {
    if (customer.profilePhotoUrl == null || customer.profilePhotoUrl.isEmpty) {
      return Image.asset(
        'assets/icons/customer.png',
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      customer.profilePhotoUrl,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/icons/customer.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        );
      },
    );
  }

  /// Build customer information section
  Widget _buildCustomerInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerName(),
          _buildCustomerPhone(),
          _buildCustomerAddress(),
        ],
      ),
    );
  }

  /// Build customer name
  Widget _buildCustomerName() {
    return Text(
      customer.name.toUpperCase(),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.orange.shade900,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build customer phone number
  Widget _buildCustomerPhone() {
    return Text(
      customer.primaryPhone,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build customer address
  Widget _buildCustomerAddress() {
    return Text(
      customer.primaryAddress,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build financial information section
  Widget _buildFinancialInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalPurchase(),
        const SizedBox(height: 8),
        _buildTotalDues(),
      ],
    );
  }

  /// Build total purchase row
  Widget _buildTotalPurchase() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF51CF66),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '₹ ${customer.totalPurchase.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF51CF66),
          ),
        ),
      ],
    );
  }

  /// Build total dues row
  Widget _buildTotalDues() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dues:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '₹ ${customer.totalDues.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}