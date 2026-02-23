import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';

/// Stats section for online products
/// Shows total products, categories, and brands count
class OnlineProductsStatsSection extends StatelessWidget {
  final OnlineProductsController controller;

  const OnlineProductsStatsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.all(16),
      child: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return _buildLoadingState();
        }

        return ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: _buildStatCards(),
        );
      }),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Container(
      height: 80,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E293B),
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build list of stat cards
  List<Widget> _buildStatCards() {
    return [
      FeatureVisitor(
              featureKey: FeatureKeys.PRODUCT.getProducts,
        child: BuildStatsCard(
          label: 'Total Products',
          value: controller.totalElements.value.toString(),
          icon: Icons.inventory_2,
          color: const Color(0xFF3B82F6),
          width: 180,
              isAmount:  false,
        ),
      ),
      const SizedBox(width: 12),
      FeatureVisitor(
              featureKey: FeatureKeys.PRODUCT.getProducts,
        child: BuildStatsCard(
          label: 'Categories',
          value: _getCategoriesCount(),
          icon: Icons.category,
          color: const Color(0xFF10B981),
          width: 180,
              isAmount:  false,
              featureKey: FeatureKeys.PRODUCT.getProductsFilters,
        ),
      ),
      const SizedBox(width: 12),
      FeatureVisitor(
              featureKey: FeatureKeys.PRODUCT.getProducts,
        child: BuildStatsCard(
          label: 'Brands',
          value: _getBrandsCount(),
          icon: Icons.business,
          color: const Color(0xFF8B5CF6),
          width: 180,
              isAmount:  false,
              featureKey: FeatureKeys.PRODUCT.getProductsFilters,
        ),
      ),
    ];
  }

  /// Get categories count
  String _getCategoriesCount() {
    return controller.categoryOptions.length > 1
        ? (controller.categoryOptions.length - 1).toString()
        : '0';
  }

  /// Get brands count
  String _getBrandsCount() {
    return controller.brandOptions.length > 1
        ? (controller.brandOptions.length - 1).toString()
        : '0';
  }
}