import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/controllers/customer%20controllers/customer_controller.dart';

/// Load more button for pagination
/// Shows button to load additional customers
class CustomerLoadMoreButton extends StatelessWidget {
  final CustomerController controller;

  const CustomerLoadMoreButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Hide button if on last page
      if (controller.currentPage.value >= controller.totalPages.value - 1) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoadingMore.value
              ? null
              : controller.loadMoreCustomers,
          style: _buildButtonStyle(),
          child: _buildButtonContent(),
        ),
      );
    });
  }

  /// Build button style
  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      elevation: 0,
    );
  }

  /// Build button content (loading or normal state)
  Widget _buildButtonContent() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return _buildLoadingContent();
      }
      return _buildNormalContent();
    });
  }

  /// Build loading state content
  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 12),
        const Text('Loading more customers...'),
      ],
    );
  }

  /// Build normal state content
  Widget _buildNormalContent() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.expand_more, size: 20),
        SizedBox(width: 8),
        Text('Load More Customers'),
      ],
    );
  }
}