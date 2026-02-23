import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/online_product_added_controller.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/online%20add%20product%20sections/online_products_grid_states.dart';
import 'package:smartbecho/views/bill%20history/online%20add%20product/widgets/online_product_card_widget.dart';

class OnlineProductsGridSection extends StatelessWidget {
  final OnlineProductsController controller;

  const OnlineProductsGridSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: Obx(() {
        if (controller.error.value.isNotEmpty && controller.products.isEmpty) {
          return SliverToBoxAdapter(
            child: OnlineProductsGridStates.error(
              errorMessage: controller.error.value,
              onRetry: () => controller.loadProducts(refresh: true),
            ),
          );
        }

        if (controller.isLoading.value && controller.products.isEmpty) {
          return SliverToBoxAdapter(child: OnlineProductsGridStates.loading());
        }

        if (controller.products.isEmpty) {
          return SliverToBoxAdapter(
            child: OnlineProductsGridStates.empty(
              onRefresh: () => controller.loadProducts(refresh: true),
            ),
          );
        }

        return SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = controller.products[index];
            return OnlineProductCardWidget(
              product: product,
              controller: controller,
            );
          }, childCount: controller.products.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
        );
      }),
    );
  }
}
