import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';
import 'package:smartbecho/utils/common/common_search_bar.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20sections/online_products_filter_sheet.dart';

/// Search section for online products
/// Provides search bar and filter button
class OnlineProductsSearchSection extends StatelessWidget {
  final OnlineProductsController controller;

  const OnlineProductsSearchSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: CommonSearchBar(
        controller: TextEditingController(),
        searchQuery: RxString(''),
        hintText: 'Filter by brand, category, or product...',
        onTap: () => _showFilterBottomSheet(context),
        readOnly: true,
        onFilter: () => _showFilterBottomSheet(context),
       
      ),
    );
  }

  

  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      OnlineProductsFilterSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}