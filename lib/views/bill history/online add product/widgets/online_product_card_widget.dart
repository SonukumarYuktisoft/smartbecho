import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/online_added_product_model.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20details%20page/online_added_product_details_page.dart';

/// Individual product card widget
/// Displays product information in a card format
class OnlineProductCardWidget extends StatelessWidget {
  final Product product;
  final OnlineProductsController controller;

  const OnlineProductCardWidget({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(),
      child: Container(
        decoration: _buildCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(),
                    const Spacer(),
                    _buildPriceSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to product details page
  void _navigateToDetails() {
    Get.to(
      () => ProductDetailsPage(product: product),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Build card decoration
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.08),
          spreadRadius: 0,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: controller
            .getCategoryColor(product.itemCategory)
            .withValues(alpha: 0.15),
        width: 1,
      ),
    );
  }

  /// Build product information section
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.categoryDisplayName.isNotEmpty)
          _buildSpecRow(
            label: "Category",
            value: product.categoryDisplayName,
          ),
        if (product.company.isNotEmpty)
          _buildSpecRow(
            label: "Company",
            value: product.company.toUpperCase(),
          ),
        if (product.model.isNotEmpty)
          _buildSpecRow(
            label: "Model",
            value: product.model,
          ),
        if (product.purchaseDate.isNotEmpty)
          _buildSpecRow(
            label: "Purchase Date",
            value: product.purchaseDate,
          ),
        if (product.purchasedFrom.isNotEmpty)
          _buildSpecRow(
            label: "Purchased From",
            value: product.purchasedFrom,
          ),
        _buildSpecRow(
          label: "Quantity",
          value: product.qty.toString(),
        ),
        if (product.ramRomDisplay.isNotEmpty)
          _buildSpecRow(
            label: "Storage",
            value: product.ramRomDisplay,
          ),
        if (product.color.isNotEmpty)
          _buildSpecRow(
            label: "Color",
            value: product.color,
          ),
      ],
    );
  }

  /// Build specification row
  Widget _buildSpecRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build price section
  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Price',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
          Text(
            product.formattedSellingPrice,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}